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
            Text("Score: \(game.score) %").font(.title2).bold()
			Spacer()

			HighlightedGridView(game: $game, noDrag: false)
			Spacer()
			
			WordView(words: game.board.wordPlacements)
        }
		.navigationTitle("\(game.board.words.name) Word Hunt")
		.navigationBarTitleDisplayMode(.automatic)
    }
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 12, words: SampleWordLists.all.randomElement()!))
	NavigationStack {
		BoardView(game: $game)
	}
}

