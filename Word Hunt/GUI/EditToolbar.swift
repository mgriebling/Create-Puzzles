//
//  EditToolbar.swift
//  Word Hunt
//
//  Created by Michael Griebling on 01.07.2026.
//

import SwiftUI

struct EditToolbar: ToolbarContent {
	let onDone: (() -> Void)?
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	
	var body: some ToolbarContent {
		ToolbarItem(placement: .cancellationAction) {
			Button(action: { dismiss() }) {
				Image(systemName: "xmark")
			}
		}
		ToolbarItem(placement: .confirmationAction) {
			Button(action: { onDone?(); dismiss() }) {
				Image(systemName: "checkmark")
			}
		}
	}
}
