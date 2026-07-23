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
	func mix(with target: Color, fraction: Double) -> Color {
		if #available(iOS 18.0, *) {
			return self.mix(with: target, by: fraction)
		} else {
			let components1 = self.components
			let components2 = target.components
			
			let red = components1.red + (components2.red - components1.red) * fraction
			let green = components1.green + (components2.green - components1.green) * fraction
			let blue = components1.blue + (components2.blue - components1.blue) * fraction
			//let alpha = components1.alpha + (components2.alpha - components1.alpha) * fraction
			
			return Color(red: red, green: green, blue: blue)
		}
	}

	private var components: (red: Double, green: Double, blue: Double, alpha: Double) {
		var r: CGFloat = 0
		var g: CGFloat = 0
		var b: CGFloat = 0
		var a: CGFloat = 0
		
		UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
		return (Double(r), Double(g), Double(b), Double(a))
	}
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
	
	static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
		CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
	}
	
	static func / (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		CGPoint(x: lhs.x / rhs, y: lhs.y / rhs)
	}
}

extension Bundle {
	var displayName: String? {
		if let bundleDisplayName = object(forInfoDictionaryKey: "CFBundleDisplayName") as? String {
			return bundleDisplayName
		}
		return object(forInfoDictionaryKey: "CFBundleName") as? String
	}
	var version: String? {
		if let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String,
		   let revision = object(forInfoDictionaryKey: "CFBundleShortVersionString" ) as? String {
			return revision + " (\(build))"
		}
		return nil
	}
	var copyright: String? {
		if let copy = object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String {
			return copy
		}
		return "Copyright © 2025 Computer Inspirations."
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
