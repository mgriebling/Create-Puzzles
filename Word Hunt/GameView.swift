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
	
	@State private var isLandscape: Bool = false
	@State private var showSettings = false
	
	var body: some View {
		Group {
			if isLandscape {
				HStack(alignment: .center, spacing: 0) {
					VStack(alignment: .center) {
						Text("Words").font(.title3)
						ScrollView {
							WordView(words: game.board.wordPlacements)
						}
						//Spacer()
					}
					//Spacer()
					LetterGridView(game: game, allowDrag: true, settings: settings)
						.layoutPriority(10)
				}
				//.padding()
			} else {
				VStack {
					LetterGridView(game: game, allowDrag: true, settings: settings)
						.layoutPriority(10)
					Text("Words").font(.title3)
					ScrollView(.vertical) {
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
//			ToolbarItem(placement: .principal) {
//				TabTitle(selectedTab: $selectedTab)
//			}
			ToolbarItem(placement: .automatic) {
				ElapsedTime(text: "", timer: game.timer)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
					.fontDesign(.monospaced)
			}
			ToolbarItem(placement: .navigation) {
				let text = (isLandscape ? "Matched: " : "") + "\(game.matched) of \(game.placedWords.count)"
				Text(text)
					.lineLimit(1)
					.fixedSize(horizontal: true, vertical: false)
			}
			ToolbarItem(placement: .navigationBarTrailing) {
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
		.navigationTitle(game.name)
		.navigationBarTitleDisplayMode(.inline)
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

