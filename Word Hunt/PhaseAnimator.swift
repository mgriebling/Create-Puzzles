//
//  PhaseAnimator.swift
//  Word Hunt
//
//  Created by Michael Griebling on 03.07.2026.
//

import SwiftUI

struct PhaseAnimatorExample: View {
	@State private var triggerCount = 0
	
	var body: some View {
		VStack(spacing: 40) {
			Text("Tap the button to trigger the animation sequence!")
				.font(.headline)
				.multilineTextAlignment(.center)
				.padding()
			
			// The view we want to animate
			Image(systemName: "bell.fill")
				.font(.system(size: 80))
				.foregroundColor(.blue)
				// 1. Attach the phase animator triggered by our state
				.phaseAnimator(
					AnimationPhase.allCases,
					trigger: triggerCount
				) { content, phase in
					// 2. Apply modifiers based on the current phase
					content
						.scaleEffect(phase.scale)
						.rotationEffect(phase.rotation)
						.offset(y: phase.offset)
						.foregroundColor(phase.color)
				} animation: { phase in
					// 3. Define the timing/smoothness for each step
					switch phase {
					case .initial: .smooth
					case .anticipation: .easeIn(duration: 0.15)
					case .pop: .spring(duration: 0.2, bounce: 0.4)
					case .settle: .spring(duration: 0.3)
					}
				}
			
			Button("Animate Bell") {
				triggerCount += 1
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

// MARK: - Animation Phases
// Define the steps of your animation in an enum
enum AnimationPhase: CaseIterable {
	case initial
	case anticipation
	case pop
	case settle
	
	var scale: CGFloat {
		switch self {
		case .initial: 1.0
		case .anticipation: 0.85  // Shrink down slightly
		case .pop: 2.0            // Burst larger
		case .settle: 1.0         // Return to normal
		}
	}
	
	var rotation: Angle {
		switch self {
		case .initial: .zero
		case .anticipation: .degrees(-15) // Tilt left
		case .pop: .degrees(20)          // Swing right
		case .settle: .zero
		}
	}
	
	var offset: CGFloat {
		switch self {
		case .initial, .anticipation, .settle: 0
		case .pop: -20 // Jump upward
		}
	}
	
	var color: Color {
		switch self {
		case .initial, .settle: .blue
		case .anticipation: .orange
		case .pop: .red
		}
	}
}

#Preview {
	PhaseAnimatorExample()
}
