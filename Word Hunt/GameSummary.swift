//
//  WordListSummary.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct GameSummary: View {
	@Binding var game: Game
	
	@Environment(\.horizontalSizeClass) var size

	var body: some View {
		let isCompact: Bool = size == .compact
		VStack(alignment: .center) {
			Text("\(game.board.words.name) Game (\(game.score, specifier: "%.0f")%)")
				.font(isCompact ? .title2 : .title)
			Text("\(game.size) rows ⨉ \(game.size) columns")
			// Text("Completion: \(game.score, specifier: "%.0f")%")
			HighlightedGridView(game: $game, scale: 0.5)
			Text(game.words.map({ $0.capitalized }).joined(separator: ", "))
				.font(isCompact ? .caption2 : .caption)
		}
		.padding()
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 14, words: SampleWordLists.all[0]))
	GameSummary(game: $game)
		.onAppear {
			game.board.highlightWord(0)
			game.board.highlightWord(5)
			game.board.highlightWord(10)
		}
}
