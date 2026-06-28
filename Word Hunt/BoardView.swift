//
//  BoardView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 28.06.2026.
//

import SwiftUI

struct BoardView: View {
	let game: Game
	
	var body: some View {
		VStack {
			Text("Matched: ^[\(game.matched) word](inflect: true)").font(.title2).bold()
			Spacer()
			
			HighlightedGridView(game: game, noDrag: false)
			Spacer()
			
			WordView(words: game.board.wordPlacements)
		}
		.trackElapsedTime(in: game)
		.toolbar {
			ToolbarItem {
				ElapsedTime(timer: game.timer)
			}
		}
		.navigationTitle(game.name)
		.navigationBarTitleDisplayMode(.automatic)
	}
}

