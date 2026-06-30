//
//  GameEdiroe.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI

struct GameEditor: View {
	@Binding var game: Game?
	
	// MARK: Action Function
	let onChoose: () -> Void
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	// MARK: Internal State
	@State private var lgame = Game(board: GameBoard()) // dummy board
	@State private var selectedWordList = WordList()    // empty list
	@State private var wordLists = [WordList]()
	@State private var placedWords = [PlacedWord]()
	@State private var size = GameBoard.range.lowerBound
	@State private var isLoading: Bool = false
	@State private var showWordList: Bool = true
	@State private var showEmptyAlert: Bool = false
	
	var body: some View {
		NavigationStack {
			Form {
				Section(header: Text("\(selectedWordList.name) Game")) {
					Text("\(Int(size)) Rows/Columns").bold()
					Slider(value: $size, in: GameBoard.range, step: 1) {
						Text("Rows/Columns:")
					} minimumValueLabel: {
						Text("\(GameBoard.minimumSize)")
					} maximumValueLabel: {
						Text("\(GameBoard.maximumSize)")
					}
					.onChange(of: size) { withAnimation { updateGame() } }
					
					Picker(wordHeader, selection: $selectedWordList) {
						ForEach(wordLists, id:\.self) { Text($0.name) }
					}
					.onChange(of: selectedWordList, updateWords)
					
					if showWordList && !placedWords.isEmpty {
						WordView(words: placedWords).onTapGesture(perform: toggleWordList)
					} else {
						if !placedWords.isEmpty {
							Button("Show Word List", action: toggleWordList)
						}
					}
				}
				Section(header: wordListTitle) {
					ZStack {
						LetterGridView(game: lgame)
						showLoading()
					}
				}
			}
			.onAppear(perform: setUpGame)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") { dismiss() }
						.tint(Color(.systemRed))
				}
				ToolbarItem(placement: .confirmationAction) {
					Button("Done") { done() }
						.tint(Color(.systemGreen))
						.alert(isPresented: $showEmptyAlert) {
							Alert(title: Text("Error"), message: Text("The game must contain a non-empty word list."), dismissButton: .cancel())
						}
				}
			}
			.navigationTitle(Text("Game Editor"))
			#if os(iOS)
			.navigationBarTitleDisplayMode(.inline)
			#endif
		}
    }
	
	func updateWords() {
		print("Updating words for \(selectedWordList.name)")
		withAnimation {
			placedWords = lgame.placeWords(words: selectedWordList.words)
			showWordList = true
			updateGame()
		}
	}
	
	func setUpGame() {
		if let game {
			lgame = game.copy()
			size = Double(game.board.size)
			if wordLists.isEmpty {
				wordLists = SampleWordLists.all
			}
			if !wordLists.contains(game.board.words) {
				wordLists.insert(game.board.words, at: 0)
			}
			selectedWordList = game.board.words
			updateGame()
		}
	}
	
	func toggleWordList() {
		withAnimation {
			showWordList.toggle()
		}
	}
	
	func done() {
		if lgame.board.words.words.isEmpty {
			showEmptyAlert = true
			return
		}
		game = lgame.copy()
		onChoose()
		dismiss()
	}
	
	var wordHeader: String {
		"Word List " + (showWordList && !placedWords.isEmpty ? "(Tap list to hide)" : "")
	}
	
	private var wordListTitle: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Game Board Layout")
				Button("New Layout") { withAnimation { updateGame() } }
			}
			let missing = lgame.board.missingWords
			if !missing.isEmpty {
				Text("Missing \(missing.count): \(missing.joined(separator: ", "))")
			}
		}
	}
	
	@ViewBuilder
	private func showLoading() -> some View {
		if isLoading {
			Color(.black).opacity(0.5)
				.ignoresSafeArea()
			ProgressView("Performing layout...")
				.padding(20)
				.background(Color(.black))
				.cornerRadius(10)
				.shadow(radius: 10)
				.offset(CGSize(width: 0, height: -100))
				.controlSize(.large)
		}
	}
	
	func updateGame() {
		isLoading = true

		Task.detached {
			let updatedGame = await Game(board: GameBoard(size: Int(size), words: selectedWordList))
			await MainActor.run {
				self.lgame = updatedGame
				isLoading = false
			}
		}
		
	}
}

#Preview {
	@Previewable
	@State var game : Game? = Game(board: GameBoard(size: 12))
	GameEditor(game: $game) {
		print("Updated game")
	}
}
