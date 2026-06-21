//
//  ContentView.swift
//  Create Puzzles
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI
import Subsonic


struct BoardView: View {

    @State var game: Game

    static let size = Game.maxSize
	static let gsize = 750.0
    
    let fontSize = CGFloat(30)
	let cellSize: CGFloat = gsize / CGFloat(size)
	let boardSize: CGSize = CGSize(width: gsize, height: gsize)
	
	@State private var isDragging: Bool = false
	@State private var start: (row: Int, col: Int) = (0, 0)
	@State private var dragDirection: Direction?
	@State private var actualSize: CGSize = .zero
	
	var body: some View {
        VStack {
            Text("Word Search")
				.font(.system(.largeTitle).bold())
				.padding(.bottom, 10)
            Text("Score: \(game.score) %")
				.font(.system(size: fontSize)).bold()
			
			Spacer()
			
			ZStack {
				Grid {
					ForEach(0..<Self.size, id: \.self) { row in
						GridRow {
							ForEach(0..<Self.size, id: \.self) { col in
								let index = game.board.indexOf(row, column: col)
								let highlighted = game.board.isHighlighted(index)
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
				.onGeometryChange(for: CGSize.self) { proxy in
					proxy.size
				} action: { newValue in
					actualSize = newValue
					print("New size: \(newValue.width) x \(newValue.height)")
				}
				
				// Display the highlighted words
				ForEach(game.board.wordPlacements.indices, id: \.self) { index in
					let word = game.board.wordPlacements[index]
					if word.highlighted {
						HighlightView(word: word, size: actualSize, numberOfCells: Self.size)
					}
				}
			}
			
			Spacer()
			
			let columns = Array(repeating: GridItem(.flexible()), count: 5)
			LazyVGrid(columns: columns, alignment: .leading) {
				ForEach(Game.words.indices, id:\.self) { index in
					let word = Game.words[index]
					let textColor = game.found[index] ? Color(.gray) : Color.primary
					Text(word.capitalized)
						.foregroundColor(textColor)
						.font(.system(size: fontSize+2, weight: .bold))
						.strikethrough(game.found[index])
				}
			}
			.padding(.leading, 75)
        }
    }
	
	private func dragGesture(_ col: Int, _ row: Int) -> some Gesture {
		DragGesture()
			.onChanged { value in
				if !isDragging {
					isDragging = true
					start = (row, col)
					game.addLetter(game.board.indexOf(row, column: col))
				}
				
				if dragDirection == nil {
					if let direction = getDirection(value.translation) {
						print("Direction", direction)
						dragDirection = direction
						selectLetter(row, col, value)
					}
				} else {
					selectLetter(row, col, value)
					// print("Word: \(game.board.selectedWord)")
				}
			}
			.onEnded { value in
				if game.isWordMatch() {
					print("Matched \(game.board.selectedWord)")
					game.removeActiveWord()
				}
				game.clearWord()
				isDragging = false
				dragDirection = nil
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
		let minDistance = 5.0
		if abs(dx) < minDistance && abs(dy) > cellSize {
			// direction is either up or down
			return dy > 0 ? .down : .up
		} else if abs(dy) < minDistance && abs(dx) > cellSize {
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

