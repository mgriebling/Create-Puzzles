//
//  Game.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

@Observable class Game {
    
    static let maxSize = 12 // 18
    static let words = WordList(name: "Letter Code", words:
        ["alpha", "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel",
         "india", "juliet", "kilo", "lima", "mike", "november", "oscar",
         "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor",
		 "whiskey", "xray", "yankee", "zulu"])
	
	var board: GameBoard
	
	var activeWord: String { board.selectedWord }
	var words: [String]    { board.wordPlacements.map(\.word) }
	var size: Int		   { board.size }
	
	init(board: GameBoard) {
		self.board = board
	}

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

    func clearWord() { board.clearWord() }
	
	func addLetter(_ row: Int, col: Int) {
		board.addLetter(board.indexOf(row, column: col))
	}
	
	func charIsHighlighted(_ row: Int, col: Int) -> Bool {
		board.charIsHighlighted(board.indexOf(row, column: col))
	}
	
	func wordIsHighlighted(_ index: Int) -> Bool {
		board.ishighlighted(index)
	}
}
