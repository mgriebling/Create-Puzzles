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
    
    var format: SystemFormatStyle.DateOffset {
		.offset(to: timer.startTime! - timer.elapsedTime,
				allowedFields: [.minute, .second])
    }
    
    var body: some View {
		HStack {
			Text(text)
			if timer.startTime != nil {
				if let endTime = timer.endTime {
					Text(endTime, format: format)
				} else {
					Text(TimeDataSource<Date>.currentDate, format: format)
				}
			} else {
				// Text(timer.elapsedTime, format: )
				Text(.seconds(timer.elapsedTime), format: .time(pattern: .hourMinuteSecond))
				// Text(
				// Text("0:00:00")
				// Image(systemName: "pause")
			}
		}
    }
}
//
//#Preview {
//    ElapsedTime()
//}
