import SwiftUI

struct MainAppView: View {
	// Track the currently active tab
	@State private var selectedTab = Tabs.wordHunt
	@State private var game: Game?
	@State private var words: WordList?
	@State private var wordLists: [WordList] = []
	
	var body: some View {
		if selectedTab == .wordHunt {
			GameChooser(selectedTab: $selectedTab.animation(), selection: $game)
		} else {
			WordListsChooser(selectedTab: $selectedTab.animation(), selection: $words)
		}
	}
}

struct TabTitle: View {
	@Binding var selectedTab: Tabs
	
	var body: some View {
		HStack {
			ForEach(Tabs.allCases) { tab in
				Button(action: {
					selectedTab = tab
				}) {
					Image(systemName: tab.image)
				}
			}
		}
	}
}

enum Tabs: Int, CaseIterable, Identifiable {

	case wordHunt, wordLists
	
	var id: Int { rawValue }
	
	var name: String {
		switch self {
			case .wordHunt:  "Word Hunt Puzzles"
			case .wordLists: "Edit Word Lists"
		}
	}
	
	var image: String {
		switch self {
			case .wordHunt:  "rectangle.and.text.magnifyingglass"
			case .wordLists: "long.text.page.and.pencil.fill"
		}
	}
	
}

// MARK: - Preview
#Preview {
	MainAppView()
}
