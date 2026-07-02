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
	@State private var showSettings = false
	
	var body: some View {
		Group {
			if isLandscape {
				HStack(alignment: .center, spacing: 0) {
					VStack(alignment: .center) {
						Text("Words").font(.title2).fontWeight(.heavy)
						ScrollView {
							WordView(words: game.board.wordPlacements, columns: 3)
						}
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
					Text("Words (\(game.matched) of \(game.placedWords.count))").font(.title2).fontWeight(.heavy)
					ScrollView(.vertical) {
						WordView(words: game.board.wordPlacements)
							.padding(.leading, 40)
					}
					.layoutPriority(-1)
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
			ToolbarItem(placement: .navigationBarLeading) {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
					.fontDesign(.monospaced)
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button(action: {
					self.showSettings.toggle()
				}) {
					Image(systemName: "gearshape")
				}
				.sheet(isPresented: $showSettings) {
					NavigationStack {
						SettingsView()
							.navigationTitle("Settings")
					}
				}
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

