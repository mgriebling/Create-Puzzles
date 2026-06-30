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
	
	var body: some View {
		Group {
			if isLandscape {
				HStack(alignment: .center, spacing: 0) {
					Spacer()
					VStack(alignment: .center) {
						Text("Words").fontWeight(.heavy)
						WordView(words: game.board.wordPlacements, columns: 3)
						Spacer()
					}
					HighlightedGridView(game: game, noDrag: false, isLandscape: isLandscape)
					Spacer()
				}
				.padding()
			} else {
				VStack {
					HighlightedGridView(game: game, noDrag: false, isLandscape: isLandscape)
					Spacer()
					ScrollView {
						Text("Words").fontWeight(.heavy)
						WordView(words: game.board.wordPlacements)
							.padding(.leading, 40)
					}
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
			ToolbarItem(placement: .navigation) {
				Text("Matched: ^[\(game.matched) word](inflect: true)")
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItem {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
			}
		}
		.navigationTitle(game.name)
		#if os(iOS)
		.navigationBarTitleDisplayMode(.inline)
		#endif
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

