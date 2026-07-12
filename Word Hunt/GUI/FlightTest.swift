//
//  FlightTest.swift
//  Word Hunt
//
//  Created by Michael Griebling on 12.07.2026.
//

import SwiftUI

struct FlightAnimationView: View {
	@Namespace private var flightNamespace
	@State private var isDetailActive = false

	var body: some View {
		ZStack {
			if !isDetailActive {
				// Starting View (e.g., Compact Row/Card)
				VStack {
					Text("Flight AC123")
						.font(.headline)
						.matchedGeometryEffect(id: "title", in: flightNamespace)
					
					RoundedRectangle(cornerRadius: 10)
						.fill(Color.blue)
						.frame(width: 100, height: 60)
						.matchedGeometryEffect(id: "card", in: flightNamespace)
				}
				.onTapGesture {
					withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
						isDetailActive.toggle()
					}
				}
			} else {
				// Destination View (e.g., Full Screen/Expanded Detail)
				VStack(spacing: 20) {
					RoundedRectangle(cornerRadius: 25)
						.fill(Color.blue)
						.frame(maxWidth: .infinity, maxHeight: 300)
						.matchedGeometryEffect(id: "card", in: flightNamespace)
					
					Text("Flight AC123")
						.font(.largeTitle)
						.matchedGeometryEffect(id: "title", in: flightNamespace)
					
					Text("Details about your flight route and times go here.")
						.padding()
					
					Spacer()
				}
				.onTapGesture {
					withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
						isDetailActive.toggle()
					}
				}
			}
		}
	}
}

#Preview {
	FlightAnimationView()
}

