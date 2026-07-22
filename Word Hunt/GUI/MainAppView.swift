import SwiftUI

struct MainAppView: View {
	// Track the currently active tab
	@State private var activeTab = Tabs.puzzle
	@State private var selectedPuzzle: Game? = nil
	@State private var selectedWords: WordList? = nil
	
	@State private var game: Game?
	@State private var games: [Game] = []
	@State private var words: WordList?
	@State private var wordLists: [WordList] = []
	@State private var puzzlesExpanded: Bool = true
	@State private var wordsExpanded: Bool = false
	@State private var showDetail: Bool = true
	@State private var columnVisibility: NavigationSplitViewVisibility = .detailOnly
	
	var body: some View {
		Group {
			if showDetail {
				baseSplitview()
					.navigationSplitViewStyle(.prominentDetail)
			} else {
				baseSplitview()
					.navigationSplitViewStyle(.automatic)
			}
		}
		.padding(.horizontal)
		.onChange(of: activeTab, showDetailOrAll)
		.onChange(of: selectedPuzzle, showDetailOnly)
		.focusEffectDisabled(true)
		.onAppear(perform: initialize)
	}
	
	private func showDetailOrAll() {
		if activeTab == .puzzle {
			showDetailOnly()
		} else {
			withAnimation {
				columnVisibility = .all
				showDetail = false
			}
		}
	}
	
	private func showDetailOnly() {
		withAnimation {
			columnVisibility = .detailOnly
			showDetail = true
		}
	}
	
	private func baseSplitview() -> some View {
		NavigationSplitView(columnVisibility: $columnVisibility) {
			sidebarView()
		} detail: {
			detailView()
		}
	}
	
	private func detailView() -> some View {
		Group {
			switch activeTab {
				case .puzzles:
					if let game = selectedPuzzle {
						GameView(game: game)
							.id(selectedPuzzle)
							.onTapGesture {
								columnVisibility = .detailOnly
							}
					} else {
						blankView(for: activeTab)
					}
				case .words:
					if let _ = selectedWords {
						WordsEditor(words: $selectedWords)
							.id(selectedWords)
					} else {
						blankView(for: activeTab)
					}
			}
		}
	}
	
	private func initialize() {
		withAnimation {
			addSampleGames()
			addSampleWords()
			selectedPuzzle = games.first
			selectedWords = wordLists.first
			activeTab = .puzzles(selectedPuzzle)
			columnVisibility = .detailOnly
		}
	}
	
	private func sidebarView() -> some View {
		Group {
			switch activeTab {
				case .puzzles:
					GameListView(selection: $selectedPuzzle,
								 games: $games,
								 wordLists: wordLists,
								 showToolbar: columnVisibility != .detailOnly)
				case .words:
					WordListView(selection: $selectedWords,
								 wordLists: $wordLists,
								 showToolbar: columnVisibility != .detailOnly)
			}
		}
		.toolbar {
			tabToolbar()
		}
	}
	
	@ToolbarContentBuilder
	private func tabToolbar() -> some ToolbarContent {
		if columnVisibility != .detailOnly {
			ToolbarItem(placement: .principal) {
				Picker("Tabs", selection: $activeTab) {
					Text(Tabs.puzzle.name)
						.tag(Tabs.puzzle)
					Text(Tabs.wordList.name)
						.tag(Tabs.wordList)
				}
				.pickerStyle(.segmented)
				.fixedSize()
			}
		}
	}

	@ViewBuilder
	private func blankView(for category: Tabs?) -> some View {
		let name = category?.name ?? "item"
		ContentUnavailableView {
			Label("No \(name) selected yet!", systemImage: "exclamationmark.circle")
		} description: {
			Text("Select a \(name) on the left to get started.")
		}
	}
	
	private func addSampleGames() {
		games = []
		if games.isEmpty {
			for _ in 0..<10 {
				let game = Game(size: Int.random(in: 8...20), words: SampleWordLists.all.randomElement()!)
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

enum Tabs: Hashable {
	case puzzles(Game?)
	case words(WordList?)
	
	static var puzzle: Self { .puzzles(nil) }
	static var wordList: Self { .words(nil) }
	
	var name: String {
		switch self {
			case .puzzles: "Puzzles"
			case .words: "Words"
		}
	}
	
	var image: String {
		switch self {
			case .puzzles: "rectangle.and.text.magnifyingglass"
			case .words: "long.text.page.and.pencil.fill"
		}
	}
}

// MARK: - Preview
#Preview {
	MainAppView()
}
