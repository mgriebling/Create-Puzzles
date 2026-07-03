//
//  AutoGridWidth.swift
//  Word Hunt
//
//  Created by Google AI on 30.06.2026.
//

import SwiftUI

struct GridWidthPreferenceKey: PreferenceKey {
	static var defaultValue: [Int: CGFloat] = [:]
	static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
		value.merge(nextValue(), uniquingKeysWith: { max($0, $1) })
	}
}

struct AutoGridWidth: View {
	let words = ["Apple", "Banana", "Pomegranate", "Kiwi", "Watermelon", "Fig", "Orange", "Blueberry", "Date"]
	let columnCount = 2
	
	@State private var columnWidths: [Int: CGFloat] = [:]
	
	var body: some View {
		// Fallback to 50 if width is not yet calculated
		let columns = (0..<columnCount).map { index in
			GridItem(.fixed(columnWidths[index] ?? 50), alignment: .leading)
		}
		
		ScrollView {
			LazyVGrid(columns: columns, alignment: .leading, spacing: 0) {
				ForEach(Array(words.enumerated()), id: \.offset) { index, word in
					let columnIndex = index % columnCount
					
					Text(word)
						.padding(.horizontal, 4)
						//.padding(.vertical, 4)
						// .background(Color.blue.opacity(0.5))
						.cornerRadius(8)
						// Measure text layout safely without layout loops
						.background(
							Text(word)
								.padding(.horizontal, 4) // Include paddings in calculation
								.fixedSize(horizontal: true, vertical: false)
								.hidden()
								.background(
									GeometryReader { geo in
										Color.clear
											.preference(
												key: GridWidthPreferenceKey.self,
												value: [columnIndex: geo.size.width]
											)
									}
								)
						)
				}
			}
			.padding()
			.onPreferenceChange(GridWidthPreferenceKey.self) { preferences in
				// Only update if values actually changed to stop unnecessary redraws
				if columnWidths != preferences {
					columnWidths = preferences
				}
			}
		}
	}
}

#Preview {
    AutoGridWidth()
		.flexibleSystemFont(maximum: 20)
}
