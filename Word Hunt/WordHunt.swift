//
//  WordHunt.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct WordHunt: App {
	@State var game = Game(board: GameBoard(size: GameBoard.maximumSize))
    
    var body: some Scene {
        WindowGroup {
            BoardView(game: $game)
        }
    }
}
