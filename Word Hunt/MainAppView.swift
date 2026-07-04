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
				WordListsTabView()
			}
			
			// Tab 3: Settings Ecosystem
			Tab("Settings", systemImage: "gear", value: .settings) {
				SettingsView()
			}

		}
		.tabViewStyle(.sidebarAdaptable)
	}
	
	enum Tabs: Int, CaseIterable {
		case wordHunt, wordLists, settings
	}
}

// MARK: - Home Tab Layout
struct GameTabView: View {
	@State private var games: [Game] = []
	@State private var selection: Game?
	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			GameList(selection: $selection)
		} detail: {
			if let game = selection {
				GameView(game: game)
					.id(UUID())
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
		.onAppear {
			if games.isEmpty {
				games = Game.loadGames()  // read back any saved games
			}
			addSampleGames()
		}
		.navigationTitle("Puzzles")
		.navigationSplitViewStyle(.prominentDetail)
	}
	
	private func addSampleGames() {
		if games.isEmpty {
			for i in 0..<4 {
				let game = Game(board: GameBoard(size: 14, words: SampleWordLists.all[i]))
				games.append(game)
			}
		}
	}
}

// MARK: - Settings Tab Layout
struct WordListsTabView: View {
	
	@State private var selection: WordList?
	@State private var wordLists: [WordList] = []
	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView {
			WordLists(selection: $selection)
		} detail: {
			if selection != nil {
				WordsEditor(words: $selection)
					.id(UUID())
					.padding(.bottom)
					.onTapGesture {
						// Tap in detail to hide puzzles list selector
						guard columnVisibility == .all else { return }
						columnVisibility = .detailOnly
					}
			} else {
				Text("Choose a word list on the left!")
					.flexibleSystemFont(maximum: 30).bold()
			}
		}
		
	}
}

// MARK: - Preview
#Preview {
	MainAppView()
}
