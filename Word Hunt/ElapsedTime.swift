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
    
	let format: Duration.TimeFormatStyle = .time(pattern: .hourMinuteSecond)
    
    var body: some View {
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
    }
}
