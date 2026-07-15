//
//  WordHunt.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct WordHunt: App {
	@Environment(\.openURL) private var openURL
	
	// State variable to control the visibility of the About screen sheet
	@State private var showAboutWindow = false
	
	var body: some Scene {
		WindowGroup {
			MainAppView()
			// Listen for state changes to display your About view as a sheet
				.sheet(isPresented: $showAboutWindow) {
					AboutView()
				}
		}
		.commands {
			CommandGroup(replacing: .appInfo) {
				Button("About Word Hunt") {
					showAboutWindow = true
				}
				// Optional: Provide a native keyboard shortcut (e.g., Command + I)
//				.keyboardShortcut("i", modifiers: .command)
			}
			
			// Replaces the system Help menu items
			CommandGroup(replacing: .help) {
				Button("My App User Guide") {
					if let url = URL(string: "https://yourwebsite.com") {
						openURL(url)
					}
				}
				.keyboardShortcut("?", modifiers: [.command]) // Standard help shortcut
				
				Button("Contact Support") {
					if let url = URL(string: "mailto:support@yourdomain.com") {
						openURL(url)
					}
				}
			}
		}
#if os(macOS)
		Settings {
			SettingsView()
		}
#endif
		
	}
}

