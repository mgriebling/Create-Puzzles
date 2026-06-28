//
//  ElapsedTime.swift
//  CodeBreaker
//
//  Created by CS193p Instructor on 4/28/25.
//

import SwiftUI

struct ElapsedTime: View {
    // MARK: Data In
	let timer: Timer
    
    var format: SystemFormatStyle.DateOffset {
		.offset(to: timer.startTime! - timer.elapsedTime, allowedFields: [.minute, .second])
    }
    
    var body: some View {
		if timer.startTime != nil {
			if let endTime = timer.endTime {
                Text(endTime, format: format)
            } else {
                Text(TimeDataSource<Date>.currentDate, format: format)
            }
        } else {
            Image(systemName: "pause")
        }
    }
}
//
//#Preview {
//    ElapsedTime()
//}
