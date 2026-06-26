//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
//import Subsonic

struct BoardView: View {
	@Binding var game: Game
	
	var body: some View {
        VStack {
            Text("Word Search")
				.font(.system(.largeTitle).bold())
				.padding(.bottom, 10)
            Text("Score: \(game.score) %")
				.font(.system(.title2)).bold()
			
			Spacer()
			
			HighlightedGridView(game: $game, noDrag: false)
			
			Spacer()
			
			WordView(words: game.board.wordPlacements)
        }
    }
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 12, words: Game.words))
	BoardView(game: $game)
}

