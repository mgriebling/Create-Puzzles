//
//  ElapsedTime.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/28/25.
//

import SwiftUI

struct ElapsedTime: View {
    // MARK: Data In
	let text: String
	let timer: Timer
    
	@AppStorage(.settings) private var settings
	@Environment(\.horizontalSizeClass) var horizontalSizeClass
	
	@State var format: Duration.TimeFormatStyle = .time(pattern: .hourMinuteSecond)
    
    var body: some View {
		if settings.showTimer {
			HStack {
				Text(text)
				if let start = timer.startTime {
					let offset = start - timer.elapsedTime
					if let endTime = timer.endTime {
						Text(.seconds(offset.timeIntervalSince(endTime)), format: format)
					} else {
						Text(.durationOffset(to: offset), format: format)
					}
				} else {
					Text(.seconds(timer.elapsedTime), format: format)
				}
			}
			.onAppear {
				if horizontalSizeClass == .compact &&
					Duration.seconds(timer.elapsedTime) < Duration(attoseconds: Int128(60.0*60.0e18)) {
					format = .time(pattern: .minuteSecond)
				}
			}
		}
    }
}
