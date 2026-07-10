import SwiftUI

struct MainAppView: View {
	// Track the currently active tab
	@State private var activeCategory: SidebarCategory = .puzzles
	@State private var selectedPuzzle: Game? = nil
	@State private var selectedWords: WordList? = nil
	
	@State private var game: Game?
	@State private var games: [Game] = []
	@State private var words: WordList?
	@State private var wordLists: [WordList] = []
	@State private var puzzlesExpanded: Bool = true
	@State private var wordsExpanded: Bool = false
	@State private var columnVisibility: NavigationSplitViewVisibility = .all
	
	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			Group {
				switch activeCategory {
					case .puzzles:
						List(selection: $selectedPuzzle) {
							ForEach(games) { game in
								NavigationLink(value: game) {
									GameSummary(game: game)
								}
							}
						}
					case .words:
						List(selection: $selectedWords) {
							ForEach(wordLists) { wordList in
								NavigationLink(value: wordList) {
									WordListSummary(wordList: wordList)
								}
							}
						}
				}
			}
			.listStyle(.plain)
			.navigationTitle(activeCategory.rawValue)
			.onChange(of: selectedPuzzle) { _, newValue in
				if newValue != nil {
					columnVisibility = .detailOnly
				}
			}
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Category", selection: $activeCategory.animation()) {
						ForEach(SidebarCategory.allCases) { category in
							Text(category.rawValue).tag(category)
						}
					}
					.pickerStyle(.segmented)
					.fixedSize()
				}
			}
		} detail: {
			Group {
				switch activeCategory {
					case .puzzles:
						if let game = selectedPuzzle {
							GameView(game: game)
						} else {
							ContentUnavailableView {
								Label("No puzzle selected yet!", systemImage: "exclamationmark.circle")
							} description: {
								Text("Select a puzzle on the left to get started.")
							}
						}
					case .words:
						if let words = selectedWords {
							WordsEditor(words: .constant(words))
						} else {
							ContentUnavailableView {
								Label("No word list selected yet!", systemImage: "exclamationmark.circle")
							} description: {
								Text("Select a word list on the left to get started.")
							}
						}
				}
			}
			.id(activeCategory)
		}
		.navigationSplitViewStyle(.balanced)
		.onAppear {
			if games.isEmpty {
				games = Game.loadGames()  // read back any saved games
			}
			addSampleGames()
			game = games.first
			wordLists = SampleWordLists.all
			words = wordLists.first
		}
	}
	
	private func addSampleGames() {
		if games.isEmpty {
			for i in 0..<4 {
				let game = Game(board: GameBoard(size: 14 + i*2,
								words: SampleWordLists.all[i]))
				games.append(game)
			}
		}
	}
}

enum SidebarCategory: String, CaseIterable, Identifiable {
	case puzzles = "Puzzles"
	case words = "Words"
	
	var id: Self { self }
}

enum SidebarSelection: Hashable {
	case wordHunt(Game)
	case wordLists(WordList)
	
	var name: String {
		switch self {
			case .wordHunt:  "Puzzles"
			case .wordLists: "Words"
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
