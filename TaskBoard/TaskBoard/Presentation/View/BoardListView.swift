//
//  BoardListView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct BoardListView: View {
    let columns: [BoardViewModel.Column]
    let collapsedStatuses: Set<TaskStatus>
    
    let onToggleCollapse: (TaskStatus) -> Void
    let onEdit: (BoardTask) -> Void
    let onDelete: (BoardTask) -> Void
    let onMove: (BoardTask, TaskStatus) -> Void
    let onAdd: (TaskStatus) -> Void
    let onDropTask: (_ taskId: String, _ status: TaskStatus, _ visibleIndex: Int) -> Void
    let onRefresh: () async -> Void
    let onArchive: (BoardTask) -> Void
    
    let expandedTaskIDs: Set<String>
    let onToggleExpand: (BoardTask) -> Void
    let onToggleSubtask: (SubTask, BoardTask) -> Void
    let onRemoveSubtask: (SubTask, BoardTask) -> Void
    
    private struct DropSlot: Equatable {
        let status: TaskStatus
        let index: Int
    }
    @State private var targetedSlot: DropSlot?
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                ForEach(columns) { column in
                    Section {
                        if !collapsedStatuses.contains(column.status) {
                            sectionBody(for: column)
                        }
                    } header: {
                        header(for: column)
                    }
                }
            }
        }
        .scrollIndicators(.visible)
        .refreshable { await onRefresh() }
    }
    
    private func header(for column: BoardViewModel.Column) -> some View {
        let isCollapsed = collapsedStatuses.contains(column.status)
        
        return HStack(spacing: 8) {
            Button {
                withAnimation(.snappy(duration: 0.20)) {
                    onToggleCollapse(column.status)
                }
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.down")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                    
                    Image(systemName: column.status.systemImage)
                        .font(.subheadline)
                        .foregroundStyle(column.status.tint)
                    
                    Text(column.status.displayName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    
                    Text("\(column.tasks.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color(.tertiarySystemFill)))
                }
            }
            .buttonStyle(.plain)
            
            Spacer(minLength: 0)
            
            Button {
                onAdd(column.status)
            } label: {
                Image(systemName: "plus")
                    .font(.subheadline.weight(.semibold))
            }
            .buttonStyle(.plain)
            .foregroundStyle(column.status.tint)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
        .overlay(alignment: .bottom) { Divider() }
        .dropDestination(for: String.self) { items, _ in
            handleDrop(items, into: column.status, at: column.tasks.count)
        } isTargeted: { targeted in
            guard isCollapsed else { return }
            updateTarget(targeted, to: DropSlot(status: column.status, index: column.tasks.count))
        }
        .overlay(
            Rectangle()
                .fill(column.status.tint.opacity(
                    isCollapsed && targetedSlot?.status == column.status ? 0.2 : 0
                ))
                .allowsHitTesting(false)
        )
    }
    
    @ViewBuilder
    private func sectionBody(for column: BoardViewModel.Column) -> some View {
        VStack(spacing: 0) {
            ForEach(Array(column.tasks.enumerated()), id: \.element.id) { index, task in
                VStack(spacing: 10) {
                    insertionIndicator(
                        tint: column.status.tint,
                        visible: targetedSlot == DropSlot(status: column.status, index: index)
                    )
                    
                    TaskCardView(
                        task: task,
                        onEdit: { onEdit(task) },
                        onDelete: { onDelete(task) },
                        onMove: { onMove(task, $0) },
                        onArchive: { onArchive(task) },
                        isExpanded: expandedTaskIDs.contains(task.id),
                        onToggleExpand: { onToggleExpand(task) }
                    )
                    .draggable(task.id) {
                        TaskCardView(task: task, onEdit: {}, onDelete: {}, onMove: { _ in }, onArchive: {})
                            .frame(width: 280)
                    }
                }
                .padding(.top, 10)
                .contentShape(Rectangle())
                .dropDestination(for: String.self) { items, _ in
                    handleDrop(items, into: column.status, at: index)
                } isTargeted: { targeted in
                    updateTarget(targeted, to: DropSlot(status: column.status, index: index))
                }
                        
                if expandedTaskIDs.contains(task.id) {
                    checklist(for: task, tint: column.status.tint)
                }
            }
            
            trailingDropZone(for: column)
        }
        .padding(.horizontal, 16)
        .padding(.top, 2)
        .padding(.bottom, 4)
    }
    
    private func trailingDropZone(for column: BoardViewModel.Column) -> some View {
        let slot = DropSlot(status: column.status, index: column.tasks.count)
        let isTargeted = targetedSlot == slot
        
        return Group {
            if column.tasks.isEmpty {
                Text(column.status.emptyMessage)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(
                                column.status.tint.opacity(isTargeted ? 0.7 : 0.2),
                                style: StrokeStyle(lineWidth: 1.5, dash: [5])
                            )
                    )
            } else {
                VStack(spacing: 0) {
                    insertionIndicator(tint: column.status.tint, visible: isTargeted)
                    Color.clear.frame(height: 20)
                }
            }
        }
        .contentShape(Rectangle())
        .dropDestination(for: String.self) { items, _ in
            handleDrop(items, into: column.status, at: column.tasks.count)
        } isTargeted: { targeted in
            updateTarget(targeted, to: slot)
        }
    }
    
    private func insertionIndicator(tint: Color, visible: Bool) -> some View {
        Capsule()
            .fill(tint)
            .frame(height: 3)
            .opacity(visible ? 1 : 0)
            .animation(.easeInOut(duration: 0.12), value: visible)
    }
    
    private func updateTarget(_ targeted: Bool, to slot: DropSlot) {
        if targeted {
            targetedSlot = slot
        } else if targetedSlot == slot {
            targetedSlot = nil
        }
    }
    
    private func handleDrop(_ items: [String], into status: TaskStatus, at index: Int) -> Bool {
        targetedSlot = nil
        guard let id = items.first else { return false }
        onDropTask(id, status, index)
        return true
    }
    
    private func checklist(for task: BoardTask, tint: Color) -> some View {
        VStack(spacing: 6) {
            ForEach(task.subtasks) { subtask in
                SubtaskCardView(
                    subtask: subtask,
                    tint: tint,
                    onToggle: { onToggleSubtask(subtask, task) },
                    onRemove: { onRemoveSubtask(subtask, task) }
                )
            }
        }
        .padding(.leading, 28)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
}
