//
//  BoardView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 28.06.2026.
//

import SwiftUI

struct GameView: View {
	let game: Game
	
	@AppStorage(.settings) private var settings
	@State private var showSettings = false
	
	var body: some View {
		Group {
			ViewThatFits(in: .horizontal) {
				// landscape mode
				HStack(alignment: .center) {
					Spacer()
					VStack(alignment: .center) {
						Text("Words").font(.title3)
						WordView(words: game.board.wordPlacements)
							.containerRelativeFrame(.horizontal) { length, axis in
								length * 0.3
							}
					}
					Spacer()
					LetterGridView(game: game, allowDrag: true, settings: settings)
				}
				
				// portrait mode
				VStack {
					LetterGridView(game: game, allowDrag: true, settings: settings)
						.layoutPriority(10)
					Text("Words").font(.title3)
					WordView(words: game.board.wordPlacements)
						.containerRelativeFrame(.horizontal) { length, axis in
							length * 0.9
						}
				}
			}
		}
		.padding()
		.trackElapsedTime(in: game)
		.toolbar {
			ToolbarItem(placement: .automatic) {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
					.fontDesign(.monospaced)
			}
			ToolbarItem(placement: .navigation) {
				let text = "Matched: \(game.matched) of \(game.placedWords.count)"
				Text(text)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItem(placement: .primaryAction) {
				Button(action: {
					self.showSettings.toggle()
				}) {
					Image(systemName: "gearshape")
				}
				.sheet(isPresented: $showSettings) {
					SettingsView()
						.navigationTitle("Settings")
				}
			}
		}
		.navigationTitle(game.name + " Puzzle")
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
//		.background(Color(.yellow.opacity(0.15)), ignoresSafeAreaEdges: .all)
	}
	
//	private func checkOrientation() {
//		#if os(iOS)
//		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//			isLandscape = windowScene.interfaceOrientation.isLandscape
//		}
//		#endif
//	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 20, words: SampleWordLists.all[0]))
	NavigationStack {
		GameView(game: game)
	}
}

