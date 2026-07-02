//
//  ContentView.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
//import Subsonic

struct GameChooser: View {
	@State private var selection: Game? = nil
	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			GameList(selection: $selection)
		} detail: {
			if let game = selection {
				GameView(game: game)
					.padding(.bottom)
					.onTapGesture {
						// Tap in detail to hide puzzles list selector
						guard columnVisibility == .all else { return }
						columnVisibility = .detailOnly
					}
			} else {
				Text("Choose a puzzle on the left!")
					.flexibleSystemFont(maximum: 30).bold()
			}
		}
		.navigationSplitViewStyle(.prominentDetail)
    }
}

#Preview {
	GameChooser()
}

