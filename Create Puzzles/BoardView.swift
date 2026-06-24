//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
import Subsonic

struct BoardView: View {
	@State var game: Game
	
    static let size = Game.maxSize
	static let gsize = 250.0
    
    let fontSize = CGFloat(14)  // ipad 30
	let cellSize: CGFloat = gsize / CGFloat(size)
	let boardSize: CGSize = CGSize(width: gsize, height: gsize)

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
				LetterGridView(game: game, fontSize: fontSize, cellSize: cellSize, actualSize: actualSize)
					.onGeometryChange(for: CGSize.self, of: { $0.size },
									  action: { actualSize = $0; print($0) })
				
				// Display the highlighted words
				ForEach(game.board.wordPlacements.indices, id: \.self) { index in
					let word = game.board.wordPlacements[index]
					if game.wordIsHighlighted(index) {
						HighlightView(word: word, size: actualSize, numberOfCells: Self.size)
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

