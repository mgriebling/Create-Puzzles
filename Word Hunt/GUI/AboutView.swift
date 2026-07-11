//
//  AboutView.swift
//  Word Hunt
//
//  Created by Michael Griebling on 11.07.2026.
//

import SwiftUI

struct AboutView: View {
	@Environment(\.dismiss) var dismiss
	
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "info.circle.fill")
				.resizable()
				.frame(width: 60, height: 60)
				.foregroundColor(.blue)
			
			Text("My Awesome App")
				.font(.title)
				.bold()
			
			Text("Version 1.0.0 (Build 42)")
				.font(.subheadline)
				.foregroundColor(.secondary)
			
			Text("© 2026 Your Company Name. All rights reserved.")
				.font(.caption)
				.multilineTextAlignment(.center)
			
			Button("Close") {
				dismiss()
			}
			.buttonStyle(.borderedProminent)
		}
		.padding(40)
		#if os(macOS)
		.frame(width: 350, height: 250) // Restrict size nicely for Mac popups
		#endif
	}
}

#Preview {
    AboutView()
}
