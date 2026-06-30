//
//  CellGridView.swift
//  Word Hunt
//
//  Created by Google AI on 30.06.2026.
//

import SwiftUI

struct CellGridView: View {
	// A fixed grid of letters to fill the screen perfectly
	//let columnsCount = 5
	//let rowsCount = 5
	let letters = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
	let spacing: CGFloat = 4
	
	var body: some View {
		let rowsCount = Int(sqrt(Double(letters.count)))
		let columnsCount = rowsCount
		GeometryReader { geometry in
			// 1. Calculate how much total space is taken up by the gaps between cells
			let totalHorizontalSpacing = spacing * CGFloat(columnsCount - 1)
			let totalVerticalSpacing = spacing * CGFloat(rowsCount - 1)
			
			// 2. Subtract the gaps from the screen size, then divide by rows/columns to get raw cell size
			let availableWidth = geometry.size.width - totalHorizontalSpacing
			let availableHeight = geometry.size.height - totalVerticalSpacing
			
			let cellWidth = availableWidth / CGFloat(columnsCount)
			let cellHeight = availableHeight / CGFloat(rowsCount)
			
			// 3. Use the smaller size to ensure the cells stay perfect squares and fit the screen
			let cellSize = min(cellWidth, cellHeight)
			
			// 4. Create standard fixed columns using our calculated size
			let columns = Array(repeating: GridItem(.fixed(cellSize), spacing: spacing), count: columnsCount)
			
			// 5. Center the grid inside the geometry reader
			VStack {
				Spacer()
				LazyVGrid(columns: columns, spacing: spacing) {
					ForEach(0..<letters.count, id: \.self) { index in
						Text(letters[index])
							// Dynamically scale font to match the square size
							.font(.system(size: cellSize * 0.6, weight: .bold))
							.foregroundColor(.white)
							.frame(width: cellSize, height: cellSize)
							.background(.pink)
							.onTapGesture {
								print("Tapped on \(letters[index])")
							}
					}
				}
				Spacer()
			}
			.frame(maxWidth: .infinity, maxHeight: .infinity)
		}
		.padding(spacing) // Keep a consistent margin around the entire grid
	}
}


#Preview {
    CellGridView()
}
