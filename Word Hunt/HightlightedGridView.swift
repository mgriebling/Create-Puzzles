//
//  HightlightedGridView.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 25.06.2026.
//

import SwiftUI

struct HighlightedGridView: View {
	@Binding var game: Game
	var scale: CGFloat = 1.0
	var noDrag: Bool = true
	
	@State private var actualSize: CGSize = .zero
	
	var body: some View {
		ZStack {
			LetterGridView(game: game, noDrag: noDrag, scale: scale)
				.onGeometryChange(for: CGSize.self) { $0.size }
					action: { self.actualSize = $0 }
			
			// Display the highlighted words
			ForEach(game.board.wordPlacements.indices, id: \.self) { index in
				let word = game.board.wordPlacements[index]
				if game.wordIsHighlighted(index) {
					HighlightView(word: word, size: actualSize, board: game.board,
					scale: scale)
				}
			}
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 12, words: SampleWordLists.all[0]))
	BoardView(game: $game)
}
