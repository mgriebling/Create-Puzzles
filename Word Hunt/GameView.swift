//
//  BoardView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 28.06.2026.
//

import SwiftUI

struct GameView: View {
	let game: Game
	
	@State private var isLandscape: Bool = false
	// @State private var activeWord: String = ""
	
	var body: some View {
		Group {
			if isLandscape {
				HStack(alignment: .center, spacing: 0) {
					VStack(alignment: .center) {
						Text("Words").font(.title2).fontWeight(.heavy)
						WordView(words: game.board.wordPlacements, columns: 4)
						Spacer()
					}
					.layoutPriority(-1)
					Spacer()
					HighlightedGridView(game: game, noDrag: false, isLandscape: isLandscape)
				}
				.padding()
			} else {
				VStack {
					HighlightedGridView(game: game, noDrag: false, isLandscape: isLandscape)
					Text("Words").font(.title2).fontWeight(.heavy)
					WordView(words: game.board.wordPlacements)
						.padding(.leading, 40)
				}
			}
		}
		.trackElapsedTime(in: game)
		.onAppear {
			checkOrientation()
		}
		#if os(iOS)
		.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
			checkOrientation()
		}
		#endif
		.toolbar {
			ToolbarItem(placement: .topBarLeading) {
				Text("Matched: ^[\(game.matched) of \(game.placedWords.count) word](inflect: true)")
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItem(placement: .principal) {
				Text("Selected: " + (game.board.selectedWord.isEmpty ? "..." : game.board.selectedWord))
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItem(placement:.topBarTrailing) {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fontDesign(.monospaced)
			}
		}
		.navigationTitle(game.name)
		.background(Color(.yellow.opacity(0.15)), ignoresSafeAreaEdges: .all)
	}
	
	private func checkOrientation() {
		#if os(iOS)
		if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
			isLandscape = windowScene.interfaceOrientation.isLandscape
		}
		#endif
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 20, words: SampleWordLists.all[0]))
	NavigationStack {
		GameView(game: game)
	}
}

