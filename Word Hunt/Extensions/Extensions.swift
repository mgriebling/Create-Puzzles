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

extension Int {
	func signum() -> Int { (self > 0) ? 1 : ((self < 0) ? -1 : 0) }
}

extension CGPoint {
	// MARK: - Geometry Math Helpers
	func distance(to other: CGPoint) -> CGFloat { hypot(x - other.x, y - other.y) }
	
	func angle(to: CGPoint) -> CGFloat {
		// Offset by 90 degrees (pi/2) because SwiftUI capsules extend vertically by default
		atan2(to.y - self.y, to.x - self.x) - (.pi / 2)
	}
	
	func midPoint(to: CGPoint) -> CGPoint {
		CGPoint(x: (self.x + to.x) / 2, y: (self.y + to.y) / 2)
	}
}

extension String {
	var trailingDigits: String {
		String(self.reversed().prefix(while: { $0.isNumber }).reversed())
	}
	
	var removeTrailingDigits: String {
		let trailingDigits = self.trailingDigits
		return String(self.dropLast(trailingDigits.count))
	}
}
