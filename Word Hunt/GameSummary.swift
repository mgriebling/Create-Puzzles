//
//  WordListSummary.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct GameSummary: View {
	let game: Game
	
	@Environment(\.horizontalSizeClass) var size
	
	var body: some View {
		let isCompact: Bool = size == .compact
		VStack(alignment: .center) {
			Text("\(game.board.words.name) Game")
				.font(isCompact ? .title2 : .title)
			HStack {
				VStack(alignment: .leading) {
					Text("Size: \(game.size)⨉\(game.size)")
					Text("Matched: ^[\(game.matched) word](inflect: true)")
					Text("Total: ^[\(game.words.count) word](inflect: true)")
					Text("Time: \(.seconds(game.timer.elapsedTime), format: .time(pattern: .minuteSecond))")
					Text("Difficulty: \(game.size - GameBoard.minimumSize)")
					Text("Language: \(game.board.words.language.description)")
				}.font(isCompact ? .caption : .callout)
				HighlightedGridView(game: game, scale: 0.5)
			}
			WordView(words: game.placedWords, style: .paragraph)
				.padding()
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 14, words: SampleWordLists.all[0]))
	GameSummary(game: game)
		.onAppear {
			game.board.highlightWord(0)
			game.board.highlightWord(5)
			game.board.highlightWord(10)
		}
}
