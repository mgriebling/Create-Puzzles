//
//  Badge.swift
//  Word Hunt
//
//  Created by Michael Griebling on 13.07.2026.
//

import Foundation

/// Use `timestamp` to determine if a badge is unlocked.
/// A `Game` may be deleted but the timestamp stays.
/// Once awarded, badges aren't relocked.
///
class Badge {
	var details: BadgeDetails
	var game: Game?
	var timestamp: Date?
	let id: UUID = UUID()
	
	init(details: BadgeDetails, game: Game? = nil, timestamp: Date? = nil) {
		self.details = details
		self.game = game
		self.timestamp = timestamp
	}
}

extension Badge: Identifiable { }

extension Badge {
	static var sample: Badge {
		Badge(details: .puzzle1, timestamp: .now)
	}
}
