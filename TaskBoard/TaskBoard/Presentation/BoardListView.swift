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
            true
        } isTargeted: { targeted in
            
        }
        .overlay(
            Rectangle()
                .fill(column.status.tint.opacity(0))
                .allowsHitTesting(false)
        )
    }
    
    @ViewBuilder
    private func sectionBody(for column: BoardViewModel.Column) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(column.tasks.enumerated()), id: \.element.id) { index, task in
                VStack(spacing: 10) {
                    TaskCardView(task: task, onEdit: { onEdit(task) }, onDelete: { onDelete(task) }, onMove: { onMove(task, $0) })
                        .draggable(task.id) {
                            TaskCardView(task: task, onEdit: {}, onDelete: {}, onMove: { _ in })
                                .frame(width: 200)
                        }
                }
                .dropDestination(for: String.self) { items, _ in
                    true
                } isTargeted: { targeted in
                    
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 12)
        .padding(.bottom, 4)
    }
}
