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
	@State private var selection: Game? = nil
	
	var body: some View {
		NavigationSplitView(columnVisibility: .constant(.all)) {
			GameList(selection: $selection)
		} detail: {
			if let game = selection {
				VStack {
					Text("Score: \(game.score) %").font(.title2).bold()
					Spacer()
					
					HighlightedGridView(game: $game, noDrag: false)
					Spacer()
					
					WordView(words: game.board.wordPlacements)
				}
				.navigationTitle(game.name)
				.navigationBarTitleDisplayMode(.automatic)
			} else {
				Text("Choose a game!")
			}
		}
    }
}

#Preview {
	@Previewable
	@State var game = Game(board: GameBoard(size: 12, words: SampleWordLists.all.randomElement()!))
	NavigationStack {
		BoardView(game: $game)
	}
}

