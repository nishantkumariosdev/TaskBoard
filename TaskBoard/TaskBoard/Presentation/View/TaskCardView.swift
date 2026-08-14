//
//  TaskCardView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct TaskCardView: View {
    let task: BoardTask
    let onEdit: () -> Void
    let onDelete: () -> Void
    let onMove: (TaskStatus) -> Void
    let onArchive: () -> Void
    
    var isExpanded: Bool = false
    var onToggleExpand: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(task.status.tint)
                .frame(width: 4)
            
            cardContent
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(borderColor, lineWidth: 0.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .onTapGesture(perform: onEdit)
        .contextMenu {
            Button("Edit", systemImage: "pencil", action: onEdit)
            
            Menu {
                ForEach(TaskStatus.allCases.filter { $0 != task.status }) { status in
                    Button(status.displayName, systemImage: status.systemImage) {
                        onMove(status)
                    }
                }
            } label: {
                Label("Move to", systemImage: "arrow.left.arrow.right")
            }
            
            Button("Archive", systemImage: "archivebox", action: onArchive)
            
            Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
        }
    }
    
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(task.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if !task.details.isEmpty {
                Text(task.details)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            footerRow
        }
        .padding(12)
    }
    
    private var footerRow: some View {
        HStack(spacing: 6) {
            Image(systemName: timestampSymbol)
                .font(.caption2)
                .foregroundStyle(.secondary)

            Text(timestampLabel)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer(minLength: 8)

            if task.hasSubtasks {
                subtaskProgress
            }
        }
    }
    
    @ViewBuilder
    private var subtaskProgress: some View {
        if let onToggleExpand {
            Button {
                withAnimation { onToggleExpand() }
            } label: {
                progressRow(showsChevron: true)
            }
            .buttonStyle(.plain)
        } else {
            progressRow(showsChevron: false)
        }
    }
    
    private func progressRow(showsChevron: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: task.allSubtasksCompleted ? "checklist.checked" : "checklist")
                .font(.caption2)
                .foregroundStyle(progressTint)

            Text("\(task.completedSubtaskCount)/\(task.subtasks.count)")
                .font(.caption2.weight(.medium))
                .monospacedDigit()
                .foregroundStyle(progressTint)

            ProgressView(value: Double(task.completedSubtaskCount), total: Double(task.subtasks.count))
                .progressViewStyle(.linear)
                .tint(task.allSubtasksCompleted ? .green : task.status.tint)
                .frame(width: 48)

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .frame(width: 10)
            }
        }
        .padding(.vertical, 8)
        .padding(.leading, 10)
        .contentShape(Rectangle())
    }
    
    private var progressTint: Color {
        task.allSubtasksCompleted ? .green : .secondary
    }
    
    private var borderColor: Color {
        Color(.separator).opacity(0.6)
    }
    
    private var timestampSymbol: String {
        task.hasBeenEdited ? "clock.arrow.circlepath" : "calendar"
    }
    
    private var timestampLabel: String {
        task.hasBeenEdited ? "Updated \(RelativeTime.string(from: task.updatedAt))" : "Created \(RelativeTime.string(from: task.createdAt))"
    }
}
