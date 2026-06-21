//
//  Game.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-09.
//

import SwiftUI

class Game : ObservableObject {
    
    static let maxSize = 18
    static let words =
        ["alpha"] /*, "bravo", "charlie", "delta", "echo", "foxtrot", "golf", "hotel",
         "india", "juliet", "kilo", "lima", "mike", "november", "oscar",
         "papa", "quebec", "romeo", "sierra", "tango", "uniform", "victor",
         "whiskey", "xray", "yankee", "zulu"] */
    
    var found = (1...Game.words.count).map { _ in false }
    
    static func newGame() -> GameBoard { GameBoard(size: maxSize, words: words)! }
    
    func isWordPartialMatch() -> Bool {
        let match = board.selectedWord.lowercased()
        if match.isEmpty { return true }  // assume the best
        for word in Game.words {
            if word.hasPrefix(match) { return true }
        }
        return false
    }

    func removeActiveWord(_ unhighlight: Bool = false) {
        if let index = Game.words.firstIndex(of: board.selectedWord.lowercased()) {
            found[index] = true
            board.clearWord(unhighlight)
        }
    }
    
    var score: Int {
        let x = found.filter { $0 }
        return (100 * x.count) / Game.words.count
    }
    
    func isWordMatch() -> Bool { Game.words.contains(board.selectedWord.lowercased()) }
    func isValidMove(_ index: Int) -> Bool { board.validMove(index) }
    func clearWord() { board.clearWord(false) }
    func addLetter(_ index: Int) { board.addLetter(index) }
    func isHighlighted(_ index: Int) -> Bool { board.isHighlighted(index) }
    
    @Published private(set) var board = newGame()
    
}
