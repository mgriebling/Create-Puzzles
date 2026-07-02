//
//  Game.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

@Observable class Game: Codable {
	var board: GameBoard
	var timer: Timer
	
	// Convenience attributes
	var activeWord: String 		  { board.selectedWord }
	var words: [String] 		  { board.wordPlacements.map(\.word) }
	var placedWords: [PlacedWord] { board.wordPlacements }
	var size: Int		   		  { board.size }
	var name: String			  { board.words.name }
	
	// Initializer
	init(board: GameBoard) {
		self.board = board
		self.timer = Timer()
	}

	var matched: Int { placedWords.filter(\.highlighted).count }
	var score: Double { (100.0 * Double(matched)) / Double(words.count) }

    func removeActiveWord() {
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
            board.clearWord()
        }
    }
	
	static var documentDirectory: URL? {
		FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
	}
	
	/// Saves the game to a file
	func save(to fileName: String) {
		// 2. Get the URL for the user's Documents directory
		guard let documentsDirectory = Self.documentDirectory else { return }
		
		// 3. Append the desired filename to the directory path
		let fileURL = documentsDirectory.appendingPathComponent("\(fileName).json")
		
		// 4. Initialize JSONEncoder and format the output
		let encoder = JSONEncoder()
		// encoder.outputFormatting = .prettyPrinted // Makes the JSON file human-readable
		
		do {
			// 5. Encode the class instance into raw Data
			let jsonData = try encoder.encode(self)
			
			// 6. Write the raw Data to disk
			try jsonData.write(to: fileURL, options: .atomic)
//			print("Successfully saved JSON file to: \(fileURL.path)")
		} catch {
//			print("Failed to write JSON file: \(error.localizedDescription)")
		}
	}
	
	static func save(games: [Game]) {
		for game in games {
			game.save(to: game.name)
		}
	}
	
	static func loadGames() -> [Game] {
		guard let documentsURL = Self.documentDirectory else { return [] }
		let fileManager = FileManager.default
		do {
			let contents = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
			
			// Filter for files with "json" extension (case-insensitive)
			let gameURLs = contents.filter { $0.pathExtension.lowercased() == "json" }
			var games = [Game]()
			for url in gameURLs {
				if let game = load(from: url) {
//					print("Loading game from \(url.path)")
					games.append(game)
				}
			}
			return games
		} catch {
//			print("Error reading directory: \(error)")
			return []
		}
	}
	
	static func load(from file: URL) -> Game? {
		if let rawData = try? Data(contentsOf: file) {
			let decoder = JSONDecoder()
			return try? decoder.decode(Game.self, from: rawData)
		}
		return nil
	}
	
	func isWordMatch() -> Bool {
		guard !activeWord.isEmpty else { return false }
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
			return true
		}
		return false
	}
	
	func placeWords (words: [String]) -> [PlacedWord] {
		words.map { PlacedWord(word: $0) }
	}
	
	func copy() -> Game { Game(board: self.board) }
    func clearWord() { board.clearWord() }
	// func addLetter(_ letter: String) { board.addLetter(letter) }
	func wordIsHighlighted(_ index: Int) -> Bool { board.ishighlighted(index) }
	
	func charIsHighlighted(_ row: Int, col: Int) -> Bool {
		board.charIsHighlighted(row, column: col)
	}
}

extension Game: Identifiable { }  // auto-generated

extension Game: Equatable {
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.board == rhs.board && lhs.size == rhs.size
	}
}

extension Game: Hashable {
	func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
	
