//
//  LetterGridView.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI

struct LetterGridView: View {
	let game: Game
	let fontSize: CGFloat
	let cellSize: CGFloat
	var actualSize: CGSize = .zero
	var noDrag: Bool = true
	
	@State private var isDragging: Bool = false
	@State private var start: (row: Int, col: Int) = (0, 0)
	@State private var dragDirection: Direction?
	
	var body: some View {
		Grid {
			ForEach(0..<game.board.size, id: \.self) { row in
				GridRow {
					ForEach(0..<game.board.size, id: \.self) { col in
						let highlighted = game.charIsHighlighted(row, col: col)
						let backColor = highlighted ? Color.accentColor : .clear
						Text(game.board[row, col].letter)
							.font(.system(size: fontSize+5, weight: .bold))
							.aspectRatio(1, contentMode: .fit)
							.frame(width: cellSize, height: cellSize)
							.gesture(dragGesture(col, row))
							.background(backColor)
					}
				}
			}
		}
	}
	
	private func dragGesture(_ col: Int, _ row: Int) -> some Gesture {
		// guard !noDrag else { return nil }
		DragGesture()
			.onChanged { value in
				if !isDragging {
					isDragging = true
					start = (row, col)
					game.addLetter(row, col: col)
				}
				
				if dragDirection == nil {
					if let direction = getDirection(value.translation) {
						dragDirection = direction
						selectLetter(row, col, value)
					}
				} else {
					selectLetter(row, col, value)
				}
			}
			.onEnded { value in
				if game.isWordMatch() {
					print("Matched \(game.activeWord)")
					game.removeActiveWord()
					// play(sound: "ding-47489.mp3")
				}
				game.clearWord()
				isDragging = false
				dragDirection = nil
			}
	}
	
	private func selectLetter(_ row: Int, _ col: Int,_ value: DragGesture.Value) {
		let cellSize = actualSize.width / CGFloat(game.board.size)
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
		game.addLetter(row, col: col)
	}
	
	func getDirection(_ size: CGSize) -> Direction? {
		let dx = size.width
		let dy = size.height
		let minDistance = 5.0
		if abs(dx) < minDistance && abs(dy) > cellSize {
			// direction is either up or down
			return dy > 0 ? .down : .up
		} else if abs(dy) < minDistance && abs(dx) > cellSize {
			// direction is either left or right
			return dx > 0 ? .right : .left
		} else if abs(dx) > cellSize && abs(dy) > cellSize {
			// diagonal directions
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
	@Previewable @State var game = Game(board: GameBoard(size: 12, words: Game.words)!)
	NavigationStack {
		LetterGridView(game: game, fontSize: 14, cellSize: 20.8)
	}
}

