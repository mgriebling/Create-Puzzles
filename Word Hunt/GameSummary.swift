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
		.overlay {
			let winner = game.matched == game.words.count
			Text("WINNER!")
				.font(.system(size: winner ? 50 : 20, weight: .heavy, design: .rounded))
				.padding(20)
				.foregroundStyle(Color.yellow)
				.background(Color(.gray).opacity(0.7))
				.cornerRadius(40)
				.rotationEffect(winner ? .degrees(0) : .degrees(360))
				.opacity(winner ? 1 : 0)
				.animation(.easeIn(duration: 1), value: winner)
		}
	}
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 20, words: SampleWordLists.all[0]))
	GameSummary(game: game)
		.onAppear {
			for i in game.board.wordPlacements.indices {
				game.board.highlightWord(i)
			}
//			game.board.highlightWord(0)
//			game.board.highlightWord(5)
//			game.board.highlightWord(10)
		}
}
