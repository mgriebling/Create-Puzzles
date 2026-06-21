//
//  Create_PuzzlesApp.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct Create_PuzzlesApp: App {
    
    @State var game = Game()
    
    var body: some Scene {
        WindowGroup {
            BoardView(game:game)
        }
    }
}
