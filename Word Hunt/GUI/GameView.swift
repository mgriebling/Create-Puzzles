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
	@AppStorage(.settings) private var settings
	
	@State private var showSettings = false
	@State private var showAbout = false
	@State private var showAwards = false
	
	var body: some View {
		Group {
			// let ratio = horizontalSizeClass == .compact ? 0.3 : 0.6
			ViewThatFits(in: .horizontal) {
				// landscape mode
				HStack(alignment: .center) {
					Spacer()
					VStack(alignment: .center) {
						Text("Words").font(.title3)
						WordView(words: game.board.wordPlacements)
					}
					Spacer()
					LetterGridView(game: game, allowDrag: true, settings: $settings)
						.layoutPriority(10)
				}
				
				// portrait mode
				VStack {
					LetterGridView(game: game, allowDrag: true, settings: $settings)
						.layoutPriority(10)
					Text("Words").font(.title3)
					WordView(words: game.board.wordPlacements)
						.containerRelativeFrame(.horizontal) { length, axis in
							length
						}
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
			ToolbarItem {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
					.fontDesign(.monospaced)
			}
			ToolbarItem(placement: .navigation) {
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
			ToolbarItem {
				Button(action: highlightWord) {
					Image(systemName: "lightbulb")
				}
			}
			ToolbarItem {
				Button(action: { showSettings = true } ) {
					Image(systemName: "gearshape")
				}
				.sheet(isPresented: $showSettings) {
					SettingsView()
						.navigationTitle("Settings")
				}
			}
			ToolbarItem {
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
		}
		.navigationTitle(game.name + " Puzzle")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
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
	@State var game = Game(board: GameBoard(size: 20, words: SampleWordLists.all[0]))
	NavigationStack {
		GameView(game: game)
	}
}

