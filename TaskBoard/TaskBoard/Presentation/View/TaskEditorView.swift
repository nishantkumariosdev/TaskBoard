//
//  TaskEditorView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct TaskEditorView: View {
    @State var viewModel: TaskEditorViewModel
    @Environment(\.dismiss) private var dismiss
    @FocusState private var titleFocused: Bool
    @FocusState private var newSubtaskFocused: Bool
    @State private var isAddingSubtask = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Title") {
                    TextField("Add title here", text: $viewModel.title, axis: .vertical)
                        .lineLimit(1...3)
                        .focused($titleFocused)
                        .submitLabel(.done)
                }
                
                Section("Description") {
                    TextField("Add any details (optional)", text: $viewModel.details, axis: .vertical)
                        .lineLimit(3...8)
                }
                
                subTaskSection
                
                Section("Status") {
                    Picker("Status", selection: $viewModel.status) {
                        ForEach(TaskStatus.allCases) { status in
                            Label(status.displayName, systemImage: status.systemImage)
                                .tag(status)
                        }
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                }
                
                if let createdAt = viewModel.createdAt {
                    Section("Created") {
                        Text(AbsoluteTime.string(from: createdAt))
                            .foregroundStyle(.secondary)
                    }
                    if let updatedAt = viewModel.updatedAt, viewModel.hasBeenEdited {
                        Section("Last Updated") {
                            Text(AbsoluteTime.string(from: updatedAt))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .navigationTitle(viewModel.screenTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() { dismiss() }
                    }
                    .disabled(!viewModel.canSave)
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                titleFocused = !viewModel.isEditing
            }
        }
    }
    
    private var subTaskSection: some View {
        Section {
            ForEach(viewModel.subtasks) { subtask in
                SubtaskRow(subtask: subtask) {
                    withAnimation {
                        viewModel.toggleSubtask(id: subtask.id)
                    }
                }
                .swipeActions(edge: .trailing) {
                    Button(role: .destructive) {
                        withAnimation { viewModel.removeSubtask(id: subtask.id) }
                    } label: {
                        Label("Remove", systemImage: "trash")
                    }
                }
            }
            .onDelete { offsets in
                withAnimation { viewModel.removeSubtasks(at: offsets) }
            }

            if isAddingSubtask {
                addSubtaskField
            }
        } header: {
            subtaskHeader
        } footer: {
            if viewModel.subtasks.isEmpty && !isAddingSubtask {
                Text("Add your subtasks here.")
            } else if !viewModel.subtasks.isEmpty {
                Text("Tap to toggle complete or incomplete")
            }
        }
    }
    
    private var subtaskHeader: some View {
        HStack(spacing: 8) {
            Text("SUBTASKS")

            if !viewModel.subtasks.isEmpty {
                Text("\(viewModel.completedSubtaskCount)/\(viewModel.subtasks.count)")
                    .font(.caption.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 2)
                    .background(Capsule().fill(Color(.tertiarySystemFill)))
            }

            Spacer(minLength: 0)

            Button {
                withAnimation { toggleAddField() }
            } label: {
                Image(systemName: isAddingSubtask ? "xmark" : "plus")
                    .font(.subheadline.weight(.semibold))
                    .frame(width: 50, height: 40, alignment: .trailing)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.tint)
        }
        .textCase(nil)
    }

    private var addSubtaskField: some View {
        HStack(spacing: 12) {
            TextField("New subtask", text: $viewModel.newSubtaskTitle)
                .focused($newSubtaskFocused)
                .submitLabel(.done)
                .onSubmit(addSubtask)

            Button("Add", action: addSubtask)
                .buttonStyle(.borderless)
                .font(.subheadline.weight(.semibold))
                .disabled(!viewModel.canAddSubtask)
        }
    }

    private func toggleAddField() {
        if isAddingSubtask {
            closeAddField()
        } else {
            isAddingSubtask = true
            newSubtaskFocused = true
        }
    }

    private func closeAddField() {
        isAddingSubtask = false
        newSubtaskFocused = false
        viewModel.newSubtaskTitle = ""
    }

    private func addSubtask() {
        withAnimation {
            if viewModel.canAddSubtask {
                viewModel.addSubtask()
            }
            closeAddField()
        }
    }
}

private struct SubtaskRow: View {
    let subtask: SubTask
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(subtask.isCompleted ? Color.accentColor : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))

                Text(subtask.title)
                    .font(.subheadline)
                    .strikethrough(subtask.isCompleted, color: .secondary)
                    .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
