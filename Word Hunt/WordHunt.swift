//
//  WordHunt.swift
//  Word Hunt
//
//  Created by Mike Griebling on 2022-11-06.
//

import SwiftUI

@main
struct WordHunt: App {
    var body: some Scene {
        WindowGroup {
			GameChooser()
        }
		#if os(macOS)
		Settings {
			SettingsView()
		}
		#endif
    }
}
