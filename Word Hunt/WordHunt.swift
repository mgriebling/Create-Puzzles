//
//  WordHunt.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct WordHunt: App {
	@State var game = Game(board: GameBoard())
    
    var body: some Scene {
        WindowGroup {
			GeometryReader { geometry in
				BoardView(game: $game)
					.environment(\.sceneFrame, geometry.frame(in: .global))
			}
			.ignoresSafeArea()
        }
    }
}

extension EnvironmentValues {
	@Entry var sceneFrame: CGRect = UIScreen.main.bounds
}
