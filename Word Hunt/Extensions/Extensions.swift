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
