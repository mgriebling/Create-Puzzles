//
//  Game.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

@Observable class Game {
	
	var board: GameBoard
	
	// Convenience attributes
	var activeWord: String 		  { board.selectedWord }
	var words: [String] 		  { board.wordPlacements.map(\.word) }
	var placedWords: [PlacedWord] { board.wordPlacements }
	var size: Int		   		  { board.size }
	
	// Initializer
	init(board: GameBoard) { self.board = board }
	
	func copy() -> Game { Game(board: self.board) }

    func removeActiveWord() {
		if let index = words.firstIndex(of: activeWord.lowercased()) {
			board.highlightWord(index)
            board.clearWord()
        }
    }
    
    var score: Int {
		guard !board.wordPlacements.isEmpty else { return 0 }
		let x = board.wordPlacements.filter(\.highlighted)
		return (100 * x.count) / board.wordPlacements.count
    }
    
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
}
	
