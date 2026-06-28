//
//  Game.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

@Observable class Game: Equatable, Identifiable, Codable {
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
	
	func copy() -> Game { Game(board: self.board) }

    func removeActiveWord() {
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
            board.clearWord()
        }
    }
	
	var matched: Int { placedWords.filter(\.highlighted).count }
    
    var score: Double { (100.0 * Double(matched)) / Double(words.count) }
    
	func isWordMatch() -> Bool {
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
			return true
		}
		return false
	}
	
	func placeWords (words: [String]) -> [PlacedWord] {
		words.enumerated().map { index, word in
			PlacedWord(word: word, id: index)
		}
	}

    func clearWord() { board.clearWord() }
	
	func addLetter(_ row: Int, col: Int) { board.addLetter(row, column: col) }
	
	func charIsHighlighted(_ row: Int, col: Int) -> Bool {
		board.charIsHighlighted(row, column: col)
	}
	
	func wordIsHighlighted(_ index: Int) -> Bool { board.ishighlighted(index) }
	
	static func == (lhs: Game, rhs: Game) -> Bool {
		lhs.board == rhs.board && lhs.size == rhs.size
	}
}

extension Game: Hashable {
	func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
	
