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
	@State private var columnVisibility: NavigationSplitViewVisibility = .automatic
	
	var body: some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			Group {
				switch activeCategory {
					case .puzzles:
						GameListView(selection: $selectedPuzzle, games: $games)
					case .words:
						WordListView(selection: $selectedWords, wordLists: $wordLists)
				}
			}
			.navigationTitle(activeCategory.rawValue)
			.onChange(of: selectedPuzzle) { _, newValue in
				if newValue != nil {
					withAnimation {
						columnVisibility = .detailOnly
					}
				}
			}
			.toolbar {
				ToolbarItem(placement: .principal) {
					Picker("Category", selection: $activeCategory) {
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
								.id(selectedPuzzle)
								.onTapGesture {
									columnVisibility = .detailOnly
								}
						} else {
							blankView(for: activeCategory)
						}
					case .words:
						if let _ = selectedWords {
							WordsEditor(words: $selectedWords)
								.id(selectedWords)
						} else {
							blankView(for: activeCategory)
						}
				}
			}
			.id(activeCategory)
		}
		.onAppear {
//			if games.isEmpty {
//				games = Game.loadGames()  // read back any saved games
//			}
			addSampleGames()
			addSampleWords()
		}
	}
	
	@ViewBuilder
	private func blankView(for category: SidebarCategory?) -> some View {
		let name = category?.rawValue.lowercased().dropLast(1) ?? "item"
		ContentUnavailableView {
			Label("No \(name) selected yet!", systemImage: "exclamationmark.circle")
		} description: {
			Text("Select a \(name) on the left to get started.")
		}
	}
	
	private func addSampleGames() {
		games = []
		if games.isEmpty {
			for i in 0..<4 {
				let game = Game(board: GameBoard(size: Int.random(in: 6...20),
								words: SampleWordLists.all[i]))
				games.append(game)
			}
		}
	}
	
	private func addSampleWords() {
		wordLists = []
		if wordLists.isEmpty {
			wordLists = SampleWordLists.all
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
