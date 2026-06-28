//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
//import Subsonic

struct GameChooser: View {
	@State private var selection: Game? = nil
	
	var body: some View {
		NavigationSplitView(columnVisibility: .constant(.all)) {
			GameList(selection: $selection)
		} detail: {
			if let game = selection {
				BoardView(game: game)
			} else {
				Text("Choose a game!")
			}
		}
    }
}

#Preview {
	NavigationStack {
		GameChooser()
	}
}

