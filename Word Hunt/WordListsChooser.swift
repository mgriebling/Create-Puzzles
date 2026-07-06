//
//  WordListsTabView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 05.07.2026.
//
import SwiftUI

struct WordListsChooser: View {
	
	@State private var selection: WordList?
	@State private var wordLists: [WordList] = []
//	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView {
			WordListEditor(selection: $selection)
		} detail: {
			if selection != nil {
				WordsEditor(words: $selection)
					.id(UUID())
					.padding(.bottom)
//					.onTapGesture {
//						// Tap in detail to hide puzzles list selector
//						guard columnVisibility == .all else { return }
//						columnVisibility = .detailOnly
//					}
			} else {
				Text("Choose a word list on the left!")
					.flexibleSystemFont(maximum: 30).bold()
			}
		}
		.navigationSplitViewStyle(.prominentDetail)
		//.navigationSplitViewStyle(.balanced)
		.navigationTitle(Text("Word Lists"))
		.navigationBarTitleDisplayMode(.inline)
		.listStyle(.plain)
	}
}
