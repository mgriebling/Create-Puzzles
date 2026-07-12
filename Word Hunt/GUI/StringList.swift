//
//  StringList.swift
//  Word Hunt
//
//  Created by Michael Griebling on 23.06.2026.
//

import SwiftUI

struct ListItem: Identifiable, Hashable {
	let id: UUID
	var title: String
	
	init(_ title: String) {
		self.id = UUID()
		self.title = title
	}
}

struct StringList: View {
	let title: String
	@Binding var strings: [String]
	
	// MARK: Data (Function) In
	@Environment(\.dismiss) var dismiss
	@Environment(\.colorScheme) var colorScheme
	
	@State private var lstrings = [ListItem]()
	@State private var selectedItems = Set<UUID>()
	#if !os(macOS)
	@State private var editMode: EditMode = .inactive
	#endif
	
	var body: some View {
		let isDark = colorScheme == .dark
		
		NavigationStack {
			List(selection: $selectedItems) {
				ForEach(lstrings) { item in
					let index = lstrings.firstIndex(where: { $0.id == item.id })!
					HStack {
						Text("\(index+1))").frame(width: 50)
						// Note: .vertical axis prevent textfield from exiting on return
						TextField("Edit Word", text: $lstrings[index].title, axis: .vertical)
							.textEditorStyle(.plain)
							.autocorrectionDisabled(true)
							.onChange(of: lstrings[index].title) { _, newValue in
								if newValue.contains("\n") {
									lstrings[index].title = newValue.replacingOccurrences(of: "\n", with: "")
								}
							}
							.onSubmit {
								let edited = lstrings[index].title.capitalized
									.filter { $0.isLetter }
								withAnimation {
									lstrings[index].title = edited
									strings[index] = edited
								}
							}
							.padding(5)
							.frame(minWidth: 200)
							.textFieldStyle(.plain)
							.background(isDark ? Color(.darkGray) : Color(.lightGray), in: RoundedRectangle(cornerRadius: 12))
					}
					.listRowBackground(
						RoundedRectangle(cornerRadius: 12, style: .continuous)
							.fill(selectedItems.contains(item.id) ? .blue.opacity(0.4) : .clear)
					)
					.flexibleSystemFont(maximum: 20)
				}
			}
			.onAppear {
				lstrings = strings.map { ListItem($0) }
			}
			.navigationTitle("\(title) Word List")
			.listStyle(.plain)
			#if !os(macOS)
			.navigationBarTitleDisplayMode(.inline)
			.environment(\.editMode, $editMode)
			.listRowSpacing(-20)
			.navigationBarItems(
				leading:  editButton,
				trailing: addDelButton
			)
			#endif
		}
	}
	
#if os(iOS)
	private var editButton: some View {
		HStack {
			Button(action: { dismiss() }) {
				Image(systemName: "xmark")
			}
			Button(action: {
				self.editMode.toggle()
				self.selectedItems = Set<UUID>()
			}) {
				Text(self.editMode.title)
			}
		}
	}

	@ViewBuilder
	private var addDelButton: some View {
		if editMode == .inactive {
			HStack {
				Button(action: addItem) {
					Image(systemName: "plus")
				}
				Button(action: done) {
					Image(systemName: "checkmark")
				}
			}
		} else {
			Button(action: deleteItems) {
				Image(systemName: "trash")
			}
		}
	}
#endif

	private func deleteItems() {
		withAnimation {
			for id in selectedItems {
				if let index = lstrings.lastIndex(where: { $0.id == id }) {
					lstrings.remove(at: index)
					strings.remove(at: index)
				}
			}
			selectedItems = Set<UUID>()
		}
	}
		
	fileprivate func addItem() {
		// Add a unique name
		// let strings = lstrings.map(\.title)
		var postFix: Int = 1
		let itemName: String
		if let _ = strings.firstIndex(of: "untitled") {
			while strings.contains("untitled\(postFix)") {
				postFix += 1
			}
			itemName = "untitled\(postFix)"
		} else {
			itemName = "untitled"
		}
		withAnimation {
			lstrings.insert(ListItem(itemName), at: 0)
			strings.insert(itemName, at: 0)
		}
	}
	
	var addButton: some View {
		Button("Add Word", systemImage: "plus") {
			addItem()
		}
	}
	
	func done() {
		strings = lstrings.map(\.title.capitalized)
		dismiss()
	}
}

#if !os(macOS)
extension EditMode {
	var title: String {
		self == .active ? "Done" : "Edit"
	}

	mutating func toggle() {
		self = self == .active ? .inactive : .active
	}
}
#endif

#Preview {
	@Previewable @State var strings = SampleWordLists.all[0].words
	// NavigationStack {
		StringList(title: SampleWordLists.all[0].name, strings: $strings)
	// }
}
