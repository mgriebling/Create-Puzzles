//
//  Extensions.swift
//  Word Hunt
//
//  Created by Michael Griebling on 25.06.2026.
//

import SwiftUI

extension View {
	func flexibleSystemFont(minimum: CGFloat = 8, maximum: CGFloat = 80) -> some View {
		self
			.font(.system(size: maximum))
			.minimumScaleFactor(minimum/maximum)
	}
}

extension Color {
	/// Converts a SwiftUI Color to a standard 24-bit RGB
	var toInt: Int? {
		// Resolve the color components in a standard sRGB space
		let resolved = self.resolve(in: .init())
		
		// Convert floating point channels (0.0 to 1.0) into integers (0 to 255)
		let r = Int(clamping: Int(resolved.red * 255))
		let g = Int(clamping: Int(resolved.green * 255))
		let b = Int(clamping: Int(resolved.blue * 255))
		
		// Combine channels using bit shifting
		return (r << 16) | (g << 8) | b
	}
	
	/// Initializes a SwiftUI Color from a 24-bit RGB Int
	init(_ hex: Int) {
		let red = Double((hex >> 16) & 0xFF) / 255.0
		let green = Double((hex >> 8) & 0xFF) / 255.0
		let blue = Double(hex & 0xFF) / 255.0
		
		self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1.0)
	}
}
