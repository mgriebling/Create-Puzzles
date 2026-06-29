//
//  WordListSummary.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct GameSummary: View {
	let game: Game
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("\(game.board.words.name) Puzzle")
				.flexibleSystemFont(maximum: 30).bold()
			Text("Size: \(game.size)⨉\(game.size)")
			Text("Matched: ^[\(game.matched) word](inflect: true)")
			Text("Total: ^[\(game.words.count) word](inflect: true)")
			Text("Time: \(.seconds(game.timer.elapsedTime), format: .time(pattern: .minuteSecond))")
			Text("Difficulty: \(game.size - GameBoard.minimumSize)")
			Text("Language: \(game.board.words.language.description)")
			WordView(words: game.placedWords, style: .paragraph)
		}
		.flexibleSystemFont(maximum: 20)
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 10, words: SampleWordLists.all[0]))
	GameSummary(game: game)
		.onAppear {
			game.board.highlightWord(0)
			game.board.highlightWord(5)
			game.board.highlightWord(10)
		}
}
