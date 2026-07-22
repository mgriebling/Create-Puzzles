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
	@Environment(\.verticalSizeClass) var verticalSizeClass
	@Environment(\.colorScheme) var colorScheme
	
	@AppStorage(.settings) private var settings
	
	@State private var showSettings = false
	@State private var showAbout = false
	@State private var showAwards = false
	
	#if os(iOS)
	typealias HSView = HStack
	typealias VSView = VStack
	#else
	typealias HSView = HSplitView
	typealias VSView = VSplitView
	#endif
	
	var body: some View {
		ViewThatFits(in: .horizontal) {
			landscapeView()
			portraitView()
		}
//		.onAppear {
//			print("Horizontal size class: \(horizontalSizeClass ?? .compact)")
//			print("Vertical size class: \(verticalSizeClass ?? .compact)")
//		}
		.sheet(isPresented: $showAbout) {
			AboutView()
		}
		.sheet(isPresented: $showAwards) {
			AchievementsView()
		}
		.trackElapsedTime(in: game)
		.toolbar {
			ToolbarItemGroup(placement: .principal) { // macOS uses .status
				HStack(spacing: 10) {
					Text("Found: \(game.matched)")
					ElapsedTime(text: "Time:", timer: game.timer)
						.lineLimit(1)
						.fixedSize(horizontal: true, vertical: false)
						.fontDesign(.monospaced)
				}
			}
			ToolbarItem(placement: .topBarLeading) {
				Text(game.name + " Puzzle")
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItemGroup(placement: .primaryAction) {
				Button(action: highlightWord) {
					Image(systemName: "lightbulb")
				}
				.disabled(game.isOver)
				Button(action: { showSettings = true } ) {
					Image(systemName: "gearshape")
				}
				.sheet(isPresented: $showSettings) {
					SettingsView()
						.navigationTitle("Settings")
				}
				Menu {
					ShareLink(item: game.url)
					Button(action: {} ) {
						Label("Save Puzzle", systemImage: "arrow.down.document")
					}
					Button(action: {} ) {
						Label("Load Puzzle", systemImage: "arrow.up.document")
					}
					Button(action: { showAwards = true }) {
						Label("My Awards", systemImage: "trophy")
					}
					Button(action: { showAbout = true }) {
						Label("About Word Hunt", systemImage: "info.circle")
					}
				} label: {
					Image(systemName: "ellipsis")
				}
			}
		}
//		#if os(ios)
		.navigationTitle("")
		.navigationBarTitleDisplayMode(.inline)
///		#endif
	}
	
	private func landscapeView() -> some View {
		// landscape mode
		HSView {
			if settings.horizontal == .left {
				wordsList
				divider()
			}
			LetterGridView(game: game, allowDrag: true, settings: $settings)
				.layoutPriority(1)
				.fixedSize(horizontal: true, vertical: false)
			if settings.horizontal == .right {
				divider()
				wordsList
			}
		}
	}
	
	private func portraitView() -> some View {
		// portrait mode
		VSView {
			if settings.vertical == .above {
				wordsList
				divider()
			}
			LetterGridView(game: game, allowDrag: true, settings: $settings)
				.layoutPriority(1)
				.fixedSize(horizontal: false, vertical: true)
			if settings.vertical == .below {
				divider()
				wordsList
					.padding(.top)
			}
		}
	}
	
	var wordsList: some View {
		ZStack {
			VStack {
				GeometryReader { proxy in
					Text("Words (\(game.placedWords.count))").font(.headline)
						.offset(x: (proxy.size.width - WordView.width)/2, y: -8)
				}
				.fixedSize(horizontal: false, vertical: true)
				WordView(words: game.board.wordPlacements)
			}
			.frame(minWidth: WordView.width, maxWidth: WordView.width * 7)
			floatingWord()
		}
	}
	
	/// the custom styled dividing line block by Google AI
	func divider() -> some View {
		#if os(macOS)
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
		#else
		Spacer()
		#endif
	}
	
	/// Floating selected name
	@ViewBuilder
	private func floatingWord() -> some View {
		let cellSize: CGFloat = 35 // : 50
		let fontSize = cellSize * 0.6
		let mix = colorScheme == .dark ? 0.4 : 0.2
		let back = Color.backColor
		let gray = back.mix(with: .primary, fraction: mix)
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
	@State var game = Game(size: 18, words: SampleWordLists.all[0])
	NavigationStack {
		GameView(game: game)
	}
}

