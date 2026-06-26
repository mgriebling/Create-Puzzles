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
		VStack(alignment: .leading) {
			Text("\(game.board.words.name) Game")
				.font(isCompact ? .title2 : .title)
			Text("\(game.size) rows x \(game.size) columns")
			Text("Completion: \(game.score, specifier: "%.0f")%")
			HighlightedGridView(game: $game, scale: 0.5)
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 14, words: SampleWordLists.all.randomElement()!))
	GameSummary(game: $game)
}
