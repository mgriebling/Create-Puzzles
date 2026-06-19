//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
import Subsonic


struct BoardView: View {

    @ObservedObject var game: Game

    static let size = Game.maxSize
	static let gsize = 750.0
	static let rowInit: [Bool] = Array(repeating: false, count: size)
    
    let fontSize = CGFloat(30)
	let cellSize: CGFloat = gsize / CGFloat(size)
	
	@State private var wasSelected: [[Bool]] = Array(repeating: rowInit, count: size)
	@State private var isDragging: Bool = false
	@State private var start: (row: Int, col: Int) = (0, 0)
	@State private var offset: (row: Int, col: Int) = (0, 0)
	@State private var dragOffset: CGSize = .init(width: 0, height: 0)
	@State private var dragDirection: Direction?
	// @State private var word: String = ""
	@State private var prow: Int = -1
	@State private var pcol: Int = -1
	
	var body: some View {
        VStack {
			Spacer()
            Text("Word Search").font(.system(.largeTitle).bold())
				.padding(.bottom, 10)
            Text("Score: \(game.score) %").font(.system(size: fontSize)).bold()
				.padding(.bottom, 10)
			ZStack {
				Grid() {
					ForEach(0..<Self.size, id: \.self) { row in
						GridRow {
							ForEach(0..<Self.size, id: \.self) { col in
								Text(game.board[row,col].letter)
									.bold().font(.system(size: fontSize+5))
									.aspectRatio(1, contentMode: .fit)
									.frame(width: cellSize, height: cellSize)
									.gesture(dragGesture(col, row))
									.background(game.board.isHighlighted(game.board.indexOf(row, column: col)) ? .blue : .clear)
							}
						}
					}
				}
			}
			
			Spacer()
			
			let fg = GridItem(.flexible())
			LazyVGrid(columns: [fg, fg, fg, fg, fg], alignment: .leading) {
				ForEach(Game.words.indices, id:\.self) { index in
					let word = Game.words[index]
					Text(word.capitalized)
						.foregroundColor(game.found[index] ? .gray : .black)
						.bold()
						.font(.system(size: fontSize+2))
						.strikethrough(game.found[index])
				}
			}
			.padding(.leading, 75)
			
			Spacer()
        }
    }
	
	private func dragGesture(_ col: Int, _ row: Int) -> some Gesture {
		DragGesture()
			.onChanged { value in
				if !isDragging {
					isDragging = true
					start = (row, col)
					wasSelected[row][col] = true
					game.addLetter(game.board.indexOf(row, column: col))
					pcol = col
					prow = row
				}
				
				// determine drag direction
				if dragDirection == nil {
					if let direction = getDirection(value.translation) {
						print("Direction", direction)
						dragDirection = direction
					}
				} else {
					selectLetter(row, col, value)
					// print("Word = \(game.board.selectedWord)")
				}
			}
			.onEnded { value in
				print("Word = \(game.board.selectedWord)")
				if game.isWordMatch() {
					print("Matched word")
					game.removeActiveWord()
				}
				game.clearWord()
				dragDirection = nil
				isDragging = false
			}
	}
	
	private func selectLetter(_ row: Int, _ col: Int,_ value: DragGesture.Value) {
		let x = Int(abs(value.translation.width) / cellSize)
		let y = Int(abs(value.translation.height) / cellSize)
		let d = max(x, y)
		var row = row, col = col
		switch dragDirection {
			case .left:  			 col -= d
			case .right: 			 col += d
			case .down:  			 row += d
			case .up: 	 			 row -= d
			case .diagonalUpLeft: 	 row -= d; col -= d
			case .diagonalDownRight: row += d; col += d
			case .diagonalUpRight: 	 row -= d; col += d
			case .diagonalDownLeft:  row += d; col -= d
			default: break
		}
		game.addLetter(game.board.indexOf(row, column: col))
	}
	
	func getDirection(_ size: CGSize) -> Direction? {
		let dx = size.width
		let dy = size.height
		if abs(dx) < 2 && abs(dy) > cellSize {
			// direction is either up or down
			return dy > 0 ? .down : .up
		} else if abs(dy) < 2 && abs(dx) > cellSize {
			// direction is either left or right
			return dx > 0 ? .right : .left
		} else if abs(dx) > cellSize && abs(dy) > cellSize {
			if dx > 0 {
				return dy > 0 ? .diagonalDownRight : .diagonalUpRight
			} else {
				return dy > 0 ? .diagonalDownLeft : .diagonalUpLeft
			}
		}
		return nil
	}
}

#Preview {
	BoardView(game: Game())
}

