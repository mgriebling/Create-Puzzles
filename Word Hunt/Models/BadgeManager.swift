//
//  BadgeManager.swift
//  Word Hunt
//
//  Created by Michael Griebling on 23.07.2026.
//

import Foundation

class BadgeManager {
	
	var badges = [Badge]()
	
	// create all the locked badges initially
	init() {
		loadBadgesIfNeeded()
	}
	
	func unlockBadges(newGame: Game, allGames: [Game]) {
		let lockedBadges = badges.filter { $0.timestamp == nil }
		var newlyUnlocked: [Badge] = []
		for badge in lockedBadges {
			switch badge.details {
				case .puzzle1 where allGames.count >= 1,
					 .puzzle3 where allGames.count >= 3 &&
						allGames.count(where: {$0.level >= 5}) >= 1,
					 .puzzle5 where allGames.count >= 5 &&
						allGames.count(where: {$0.level >= 6}) >= 2,
					 .puzzle7 where allGames.count >= 7 &&
						allGames.count(where: {$0.level >= 7}) >= 3,
					 .puzzle10 where allGames.count >= 10 &&
						allGames.count(where: {$0.level >= 8}) >= 4,
					 .puzzle20 where allGames.count >= 20 &&
						allGames.count(where: {$0.level >= 9}) >= 5,
					 .puzzle30 where allGames.count >= 30 &&
						allGames.count(where: {$0.level == 10}) >= 5,
					 .puzzle50 where allGames.count >= 50 &&
						allGames.count(where: {$0.level == 10}) >= 10,
					 .puzzle75 where allGames.count >= 75 &&
						allGames.count(where: {$0.level == 10}) >= 20,
					 .puzzle100 where allGames.count >= 100 &&
						lockedBadges.count == 1 &&
						allGames.count(where: {$0.level == 10}) >= 30:
					newlyUnlocked.append(badge)
					print("Unlocked \(badge.details.title)")
				default:
					continue
			}
		}
		for badge in newlyUnlocked {
			badge.game = newGame
			badge.timestamp = newGame.timer.startTime
		}
	}
	
	func loadBadgesIfNeeded() {
		if badges.isEmpty {
			for details in BadgeDetails.allCases {
				badges.append(Badge(details: details))
			}
		}
	}
	
}
