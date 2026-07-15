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
		NavigationStack {
			VStack {
				VStack {
					Image("mac256")
				}
				.frame(height: 180, alignment: .center)
				.padding()
				
				VStack(alignment: .leading) {
					if let displayName = Bundle.main.displayName {
						Text(displayName).font(.system(size: 35))
					}
					if let version = Bundle.main.version {
						Text("Version: \(version)")
							.font(.headline)
							.fontWeight(.light)
							.foregroundColor(.gray)
							.padding(.bottom)
					}
					
					if let copyright = Bundle.main.copyright {
						Text(copyright)
							.font(.footnote)
							.foregroundColor(.gray)
							.padding(.bottom)
					}
					
					HStack {
						Button {
							dismiss()
						} label: {
							Text("Acknowledgements")
								.frame(maxWidth: .infinity)
						}
						Spacer()
						Button {
							dismiss()
						} label: {
							Text("License Agreement")
								.frame(maxWidth: .infinity)
						}
					}
					Spacer()
				}
				.frame(width: 350, alignment: .center)
			}
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button(action: { dismiss() }) {
						Image(systemName: "xmark")
					}
				}
			}
			.padding(40)
#if os(macOS)
			.frame(width: 350, height: 250) // Restrict size nicely for Mac popups
#endif
		}
	}
}

#Preview {
	NavigationView {
		AboutView()
	}
}
