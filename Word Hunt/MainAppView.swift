import SwiftUI

struct MainAppView: View {
	// Track the currently active tab
	@State private var selectedTab = Tabs.wordHunt
	
	var body: some View {
		TabView(selection: $selectedTab) {
			// Tab 1: Home Ecosystem
			Tab("Word Hunt Puzzles", systemImage: "rectangle.and.text.magnifyingglass", value: .wordHunt) {
				GameChooser()
			}
			
			// Tab 2: Settings Ecosystem
			Tab("Edit Word Lists", systemImage: "long.text.page.and.pencil.fill", value: .wordLists) {
				WordListsChooser()
			}
		}
		.tabViewStyle(.tabBarOnly)  //.sidebarAdaptable)
	}
}

enum Tabs: Int, CaseIterable, Identifiable {

	case wordHunt, wordLists // , settings
	
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

// MARK: - Settings Tab Layout


// MARK: - Preview
#Preview {
	MainAppView()
}
