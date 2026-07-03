//
//  WordListSummary.swift
//  Word Hunt
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct GameSummary: View {
	let game: Game
	
	var body: some View {
		VStack(alignment: .leading) {
			Text("\(game.board.words.name) Puzzle").font(.title2).bold()
			Text("Size: \(game.size)⨉\(game.size)")
			Text("Matched: \(game.matched) of ^[\(game.words.count) word](inflect: true)")
			ElapsedTime(text: "Time: ", timer: game.timer)
			Text("Difficulty: \(game.level)")
			Text("Language: \(game.board.words.language.description)")
			WordView(words: game.placedWords, style: .paragraph)
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 20, words: SampleWordLists.all[0]))
	GameSummary(game: game)
		.onAppear {
			game.board.highlightWord(0)
			game.board.highlightWord(5)
			game.board.highlightWord(10)
		}
}
