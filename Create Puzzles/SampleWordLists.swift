//
//  SampleWordLists.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 26.06.2026.
//

import Foundation

struct SampleWordLists {
	
	static var all: [WordList] { [
		WordList(name: "Animal",
				 words: ["dog", "cat", "snake", "elephant", "kangaroo", "penguin",
						 "octopus", "penguin", "koala", "penguin", "horse", "cow", "donkey"]),
		WordList(name: "Color",
				 words: ["red", "blue", "green", "yellow", "orange", "purple",
						 "pink", "brown", "black", "white"]),
		WordList(name: "Letter Code",
				 words:	["alpha", "bravo", "charlie", "delta", "echo", "foxtrot",
						 "golf", "hotel", "india", "juliet", "kilo", "lima", "mike",
						 "november", "oscar", "papa", "quebec", "romeo", "sierra",
						 "tango", "uniform", "victor", "whiskey", "xray", "yankee", "zulu"]),
		WordList(name: "Number",
				 words: ["one", "two", "three", "four", "five", "six", "seven",
						 "eight", "nine", "ten"])
	]}
	
}
