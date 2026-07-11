//
//  GameEdiroe.swift
//  Word Hunt
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
	
	@AppStorage(.settings) private var settings
	
	// MARK: Internal State
	@State private var lgame = Game(board: GameBoard(size: 4)) // dummy board
	@State private var selectedWordList = WordList()    // active word list
	@State private var wordLists = [WordList]()			// all the word lists
	@State private var showWordList: Bool = true
	@State private var showEmptyAlert: Bool = false
	@State private var gameID: UUID = UUID()			// forces letter grid updates
	
	var body: some View {
		NavigationStack {
			Form {
				let size = Int(settings.gridDefaultSize)
				Section(header: Text("\(selectedWordList.name) Game (\(size) Rows/Columns)")) {
					let range = SettingsType.maxGridRange
					Slider(value: $settings.gridDefaultSize, in: range, step: 1) {
						Text("Rows/Columns:")
					} minimumValueLabel: {
						Text("\(Int(range.lowerBound))")
					} maximumValueLabel: {
						Text("\(Int(range.upperBound))")
					}
					.onChange(of: settings.gridDefaultSize) {
						print("Updating grid size & game")
						withAnimation { updateGame() }
					}
				}
					
				Section(wordHeader, isExpanded: $showWordList) {
					Picker("Word List Selection:", selection: $selectedWordList) {
						ForEach(wordLists, id:\.self) { Text($0.name) }
					}
					.onChange(of: selectedWordList, updateWords)
								
					WordView(words: lgame.placedWords, style: .paragraph)
						.padding(.top, -15)
				}
				.onTapGesture(perform: toggleWordList)

				Section(header: wordListTitle) {
					LetterGridView(game: lgame, settings: settings).id(gameID)
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
			showWordList = true
			print("Selected word list: \(selectedWordList.words)")
			updateGame()
		}
	}
	
	func setUpGame() {
		if let game {
			lgame = game.copy()
			settings.gridDefaultSize = Double(game.board.size)
			if wordLists.isEmpty {
				wordLists = SampleWordLists.all
			}
			if !game.board.words.words.isEmpty, !wordLists.contains(game.board.words) {
				wordLists.insert(game.board.words, at: 0)
			}
			selectedWordList = game.board.words.words.isEmpty ? wordLists.first! : game.board.words
			updateGame()
		}
	}
	
	func toggleWordList() { withAnimation { showWordList.toggle() }	}
	
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
		"Word List " + (showWordList && !lgame.placedWords.isEmpty ? "(Tap to hide)" : "(Tap to show)")
	}
	
	private var wordListTitle: some View {
		VStack(alignment: .leading, spacing: 0) {
			HStack {
				Text("Game Board Layout")
				Button("Update") { withAnimation { updateGame() } }
			}
			let missing = lgame.board.missingWords
			if !missing.isEmpty {
				Text("Missing \(missing.count): \(missing.joined(separator: ", "))")
					.lineLimit(1)
					.font(.caption)
			}
		}
	}
	
	func updateGame() {
		print("Grid size: \(settings.gridDefaultSize)")
		print("Updating game with \(selectedWordList.words.count) words")
		lgame = Game(board: GameBoard(size: Int(settings.gridDefaultSize), words: selectedWordList))
		gameID = UUID()
		print("Finished game update")
	}
}

#Preview {
	@Previewable
	@State var game : Game? = Game(board: GameBoard(size: 12))
	GameEditor(game: $game) {
		print("Updated game")
	}
}
