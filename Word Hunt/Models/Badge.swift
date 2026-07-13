//
//  Badge.swift
//  Word Hunt
//
//  Created by Michael Griebling on 13.07.2026.
//

import Foundation

/// Use `timestamp` to determine if a badge is unlocked.
/// A `Moment` may be deleted but the timestamp stays.
/// Once awarded, badges aren't relocked.
///
struct Badge {
	var details: BadgeDetails
	// var moment: Moment?
	var timestamp: Date?
	let id: UUID = UUID()
	
	init(details: BadgeDetails) {
		self.details = details
//		self.moment = nil
		self.timestamp = nil
	}
}

extension Badge: Identifiable { }

extension Badge {
	static var sample: Badge {
		var badge = Badge(details: .first)
		badge.timestamp = .now
		return badge
	}
}
