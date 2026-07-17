//
//  BoardView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 28.06.2026.
//

import SwiftUI

struct GameView: View {
	let game: Game
	
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	@Environment(\.colorScheme) var colorScheme
	
	@AppStorage(.settings) private var settings
	
	@State private var showSettings = false
	@State private var showAbout = false
	@State private var showAwards = false
	@State private var isHovering: Bool = false
	
	var body: some View {
		ViewThatFits(in: .horizontal) {
			// landscape mode
			HSplitView {
				if settings.horizontal == .left {
					wordsList
					divider()
				}
				LetterGridView(game: game, allowDrag: true, settings: $settings)
					.layoutPriority(10)
					.frame(minWidth: 250, maxWidth: .infinity)
				if settings.horizontal == .right {
					divider()
					wordsList
				}
			}
			
			// portrait mode
			VSplitView {
				if settings.vertical == .above {
					Spacer()
					wordsList
					divider()
				}
				LetterGridView(game: game, allowDrag: true, settings: $settings)
					.layoutPriority(10)
					.frame(minHeight: 250, maxHeight: .infinity)
				if settings.vertical == .below {
					divider()
					wordsList
						.padding(.top, 10)
				}
			}
		}
		.sheet(isPresented: $showAbout) {
			AboutView()
		}
		.sheet(isPresented: $showAwards) {
			AchievementsView()
		}
		.padding()
		.trackElapsedTime(in: game)
		.toolbar {
			//#if os(iOS)
			ToolbarItemGroup(placement: .status) {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
					.fontDesign(.monospaced)
					.padding(.trailing, 10)
				Group {
					if horizontalSizeClass == .compact {
						Text("\(game.matched)/\(game.placedWords.count)")
					} else {
						Text("Matched: \(game.matched) of \(game.placedWords.count)")
					}
				}
				.lineLimit(1)
				.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItemGroup(placement: .primaryAction) {
				Button(action: highlightWord) {
					Image(systemName: "lightbulb")
				}
				Button(action: { showSettings = true } ) {
					Image(systemName: "gearshape")
				}
				.sheet(isPresented: $showSettings) {
					SettingsView()
						.navigationTitle("Settings")
				}
				Menu("Miscellaneous", systemImage: "ellipsis") {
					ShareLink(item: game.url)
					Button(action: {} ) {
						Label("Save Puzzle", systemImage: "square.and.arrow.down")
					}
					Button("Load Game") {
						
					}
					Button(action: { showAwards = true }) {
						Label("My Awards", systemImage: "trophy")
					}
					Button(action: { showAbout = true }) {
						Label("About Word Hunt", systemImage: "info.circle")
					}
				}
			}
			//#endif
		}
		.navigationTitle(game.name + " Puzzle")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
	}
	
	var wordsList: some View {
		ZStack {
			VStack {
				Text("Words").font(.headline)
				WordView(words: game.board.wordPlacements)
			}
			floatingWord()
		}
		.frame(minWidth: 250, maxWidth: 350)
	}
	
	// PANE 2: THE CUSTOM STYLED DIVIDING LINE BLOCK
	func divider() -> some View {
		Group {
			Rectangle()
				// Changes color dynamically when the cursor hovers over the area
				.fill(isHovering ? Color.accentColor : Color(.separatorColor))
				.frame(width: isHovering ? 3 : 1)
				.animation(.easeOut(duration: 0.1), value: isHovering)
		}
		// Strict sizing so this "middle pane" acts as a slim dividing bar
		.frame(width: 8)
		.contentShape(Rectangle()) // Expands hover asset detection region
		.onHover { inside in
			isHovering = inside
			if inside {
				NSCursor.resizeLeftRight.push()
			} else {
				NSCursor.pop()
			}
		}
	}
	
	/// Floating selected name
	@ViewBuilder
	private func floatingWord() -> some View {
		let cellSize: CGFloat = horizontalSizeClass == .compact ? 35 : 50
		let fontSize = cellSize * 0.6
		let mix = colorScheme == .dark ? 0.4 : 0.2
		let back = Color(.windowBackgroundColor)
		let gray = back.mix(with: .primary, by: mix)
		let frameWidth = game.activeWord.count/2 + 1
		Text(game.activeWord)
			.font(.system(size: fontSize, weight: .bold))
			.lineLimit(1)
			.fixedSize(horizontal: true, vertical: false)
			.frame(width: cellSize * CGFloat(frameWidth), height: fontSize)
			.padding(10)
			.background(gray)
			.cornerRadius(15)
			.zIndex(10)
			.opacity(game.activeWord.isEmpty ? 0.0 : 1.0)
			.animation(.none, value: frameWidth)
	}
	
	private func highlightWord() {
		let unselected = game.board.wordPlacements.filter { !$0.highlighted }
		let word = unselected.randomElement()!
		let index = game.board.wordPlacements.firstIndex(of: word)!
		Task {
			withAnimation {
				game.board.highlightWord(index)
			}
			try? await Task.sleep(for: .seconds(1))
			withAnimation {
				game.board.unhighlightWord(index)
			}
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 10, words: SampleWordLists.all[0]))
	NavigationStack {
		GameView(game: game)
	}
}

