//
//  LetterGridView.swift
//  Create Puzzles
//
//  Created by Michael Griebling on 24.06.2026.
//

import SwiftUI

struct LetterGridView: View {
	let game: Game
	var noDrag: Bool = true
	var scale: CGFloat = 1
	
	@State private var isDragging: Bool = false
	@State private var start: (row: Int, col: Int) = (0, 0)
	@State private var dragDirection: Direction?
	@State private var contentHeight: CGFloat = 0
	
	var body: some View {
		let cellSize = cellSize(with: game.size) * scale
		let fontSize = scale < 1 ? cellSize * 1.4 : cellSize * 1.1
		Grid {
			ForEach(0..<game.board.size, id: \.self) { row in
				GridRow {
					ForEach(0..<game.board.size, id: \.self) { col in
						let highlighted = game.charIsHighlighted(row, col: col)
						let backColor = highlighted ? Color.accentColor : .clear
						Text(game.board[row, col].letter)
							.font(.system(size: fontSize, weight: .bold))
							.aspectRatio(1, contentMode: .fit)
							.frame(width: cellSize, height: cellSize)
							.gesture(dragGesture(col, row), isEnabled: !noDrag)
							.background(backColor)
					}
				}
			}
		}
		.onGeometryChange(for: CGSize.self) { $0.size }
			action: { self.contentHeight = $0.height }
		.presentationDetents([.height(contentHeight)])
	}
	
	private func cellSize(with cells: Int) -> CGFloat {
		let size = CGFloat(cells)
		return ((-0.0239 * size + 1.2211) * size - 21.607) * size + 144.82
	}
	
	private func dragGesture(_ col: Int, _ row: Int) -> some Gesture {
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
					game.removeActiveWord()
					// play(sound: "ding-47489.mp3")
				}
				game.clearWord()
				isDragging = false
				dragDirection = nil
			}
	}
	
	private func selectLetter(_ row: Int, _ col: Int,_ value: DragGesture.Value) {
		let cellSize = contentHeight / CGFloat(game.board.size)
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
		let cellSize = contentHeight / CGFloat(game.board.size)
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
	@Previewable
	@State var game = Game(board: GameBoard(size: 12))
	NavigationStack {
		LetterGridView(game: game)
	}
}

