//
//  ContentView.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

//struct GameChooser: View {
//	@Binding var selection: Game?
//	@Binding var selectedTab: SidebarSelection
//	
//	@State private var columnVisibility: NavigationSplitViewVisibility = .all
//	
//	var body: some View {
//		NavigationSplitView(columnVisibility: $columnVisibility) {
//			GameList(selection: $selection)
//		} detail: {
//			if let game = selection {
//				GameView(game: game)
//					.id(UUID())
//					.onTapGesture {
//						// Tap in detail to hide puzzles list selector
//						guard columnVisibility == .all else { return }
//						columnVisibility = .detailOnly
//					}
//			} else {
//				Text("Choose a puzzle on the left!")
//					.flexibleSystemFont(maximum: 30).bold()
//			}
//		}
//		.navigationSplitViewStyle(.prominentDetail)
//    }
//}
//
//#Preview {
//	@Previewable @State var game: Game?
//	GameChooser(selection: $game, selectedTab: .constant(SidebarSelection.wordHunt(game!)))
//}

