//
//  AchievementsView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 13.07.2026.
//

import SwiftUI

struct AchievementsView: View {
	
	@State private var unlockedBadges: [Badge] = []
	@State private var lockedBadges: [Badge] = []
//	private var moments: [Moment]
	
	@AppStorage(.settings) private var settings
	
	var body: some View {
		NavigationStack {
			ScrollView {
				contentStack
			}
			.onAppear() {
				lockedBadges = createBadges()
				unlockedBadges = createUnlockedBadges()
			}
			.navigationTitle("Achievements")
		}
		.dynamicTypeSize(...DynamicTypeSize.xxxLarge)
	}
	
	private var contentStack: some View {
		VStack(alignment: .leading) {
			header("Earned Points: \(settings.player.points)")
			Text("Earn points for each completed puzzle. More difficult puzzles award more points. You can also earn points by completing puzzles in a row. Compete with friends to see who has the most points!")
				.font(.caption)

			if !unlockedBadges.isEmpty {
				header("Your Awards")
				ScrollView(.horizontal) {
					HStack {
						ForEach(sortedUnlockedBadges) { badge in
							UnlockedAwardView(badge: badge)
						}
					}
				}
				.scrollClipDisabled(true)
				.scrollIndicators(.hidden)
			}
			
			if !lockedBadges.isEmpty {
				header("Locked Awards")
				ForEach(sortedLockedBadges) { badge in
					LockedAwardView(badge: badge)
				}
			}
		}
		
		.padding()
		.frame(maxWidth: .infinity)
	}
	
	func header(_ text: String) -> some View {
		Text(text)
			.font(.subheadline.bold())
			.padding()
	}
	
	func createBadges() -> [Badge] {
		var badges: [Badge] = []
		for id in BadgeDetails.allCases { // .dropFirst(3) {
			badges.append(Badge(details: id))
		}
		return badges
	}
	
	func createUnlockedBadges() -> [Badge] {
		var badges: [Badge] = []
		for id in [BadgeDetails.first, .bright, .skillful] {
			badges.append(Badge(details: id))
		}
		return badges
	}
	
	private var sortedUnlockedBadges: [Badge] {
		unlockedBadges.sorted {
			$0.details.rawValue < $1.details.rawValue
		}
	}
	
	private var sortedLockedBadges: [Badge] {
		lockedBadges.sorted {
			$0.details.rawValue < $1.details.rawValue
		}
	}
}

#Preview {
	AchievementsView()
}
