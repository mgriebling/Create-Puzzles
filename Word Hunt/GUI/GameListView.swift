//
//  GameList.swift
//  Word Hunt
//
//  Created by Michael Griebling on 27.06.2026.
//

import SwiftUI

struct GameListView: View {
	// MARK: Data shared with me
	@Binding var selection: Game?
	@Binding var games: [Game]
	let wordLists: [WordList]
	let showToolbar: Bool
	
	// MARK: Data Owned by me
	@State private var gameToEdit: Game?
	@State private var showGameEditor: Bool = false
	@State private var showOptions: Bool = false
	
    var body: some View {
		List(selection: $selection) {
			ForEach(games) { game in
				NavigationLink(value: game) {
					GameSummary(game: game)
				}
				.tag(game)
			}
			.onDelete { offsets in
				for offset in offsets.reversed() {
					games[offset].delete() // remove the external file
				}
				games.remove(atOffsets: offsets)
			}
			.onMove { source, destination in
				games.move(fromOffsets: source, toOffset: destination)
			}
		}
		.listStyle(.plain)
		.onChange(of: selection) {
			if let selection, !games.contains(selection) {
				self.selection = nil
			}
		}
		.toolbar {
			if showToolbar {
				addButton
			}
		}
    }
	
	var addButton: some View {
		Button("Add Game", systemImage: "plus") {
//			gameToEdit = Game(board: GameBoard(size: 14,
//				words: WordList(name: "Unnamed", words: ["Word1", "Word2"])))
			showOptions = true
		}
		.sheet(isPresented: $showOptions, content: {
			GameCreationView(games: $games, wordLists: wordLists)
		})
		.sheet(isPresented: $showGameEditor) {
			GameEditor(game: $gameToEdit) {
				if let gameToEdit {
					if !games.contains(gameToEdit) {
						games.insert(gameToEdit, at: 0)
					}
				}
			}
		}
	}
	
	private func addSampleGames() {
		if games.isEmpty {
			for i in 0..<4 {
				let game = Game(board: GameBoard(size: 14 + i*2,
						   words: SampleWordLists.all.randomElement()!))
				games.append(game)
			}
		}
	}
}

#Preview {
	@Previewable @State var selection: Game?
	@Previewable @State var games: [Game] = [
		Game(board: GameBoard(size: 14, words: SampleWordLists.all[0]))
	]
	NavigationStack {
		GameListView(selection: $selection, games: $games, wordLists: SampleWordLists.all, showToolbar: true)
	}
}
