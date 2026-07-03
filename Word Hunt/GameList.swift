//
//  GameList.swift
//  Word Hunt
//
//  Created by Michael Griebling on 27.06.2026.
//

import SwiftUI

struct GameList: View {
	// MARK: Data shared with me
	@Binding var selection: Game?
	
	@Environment(\.scenePhase) private var scenePhase
	@State private var games: [Game] = []
	
	// MARK: Data Owned by me
	@State private var gameToEdit: Game?
	@State private var showGameEditor: Bool = false
	
    var body: some View {
		List(selection: $selection) {
			ForEach(games) { game in
				NavigationLink(value: game) {
					GameSummary(game: game)
				}
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
		.navigationTitle("Puzzle")
		.listStyle(.plain)
		.onAppear {
			if games.isEmpty {
				games = Game.loadGames()  // read back any saved games
			}
			addSampleGames()
		}
		.onDisappear {
			Game.save(games: games)
		}
		.onChange(of: scenePhase) { oldPhase, newPhase in
			if newPhase == .background {
				Game.save(games: games)
			}
		}
		.onChange(of: selection) {
			if let selection, !games.contains(selection) {
				self.selection = nil
			}
		}
		.toolbar {
			addButton
			#if os(iOS)
			EditButton() // editing the List of games
			#endif
		}
    }
	
	var addButton: some View {
		Button("Add Game", systemImage: "plus") {
			gameToEdit = Game(board: GameBoard(size: 14, words: WordList(name: "Unnamed", words: ["Word1", "Word2"])))
			showGameEditor.toggle()
		}
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
				let game = Game(board: GameBoard(size: 14, words: SampleWordLists.all[i]))
				games.append(game)
			}
		}
	}
}

#Preview {
	@Previewable @State var selection: Game?
	NavigationStack {
		GameList(selection: $selection)
	}
}
