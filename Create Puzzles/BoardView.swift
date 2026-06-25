//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
//import Subsonic

struct BoardView: View {
	@State var game: Game
	
	// Internal State
	@State private var actualSize: CGSize = .zero
	
	var body: some View {
        VStack {
            Text("Word Search")
				.font(.system(.largeTitle).bold())
				.padding(.bottom, 10)
            Text("Score: \(game.score) %")
				.font(.system(.title2)).bold()
			
			Spacer()
			
			ZStack {
				LetterGridView(game: game, noDrag: false)
					.onGeometryChange(for: CGSize.self) { proxy in
						proxy.size
					} action: { newValue in
						self.actualSize = newValue
						print("Width: \(newValue.width)")
					}
				
				// Display the highlighted words
				ForEach(game.board.wordPlacements.indices, id: \.self) { index in
					let word = game.board.wordPlacements[index]
					if game.wordIsHighlighted(index) {
						HighlightView(word: word, size: actualSize, board: game.board)
					}
				}
			}
			
			Spacer()
			
			WordView(words: game.board.wordPlacements)
        }
    }
}

#Preview {
	BoardView(game: Game(board: GameBoard(size: 12, words: Game.words)!))
}

