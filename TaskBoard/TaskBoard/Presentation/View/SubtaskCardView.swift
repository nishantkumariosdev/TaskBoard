//
//  SubtaskCardView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 14/08/26.
//

import Foundation
import SwiftUI

struct SubtaskCardView: View {
    let subtask: SubTask
    let tint: Color

    let onToggle: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(tint.opacity(subtask.isCompleted ? 0.25 : 0.5))
                .frame(width: 3)

            content
        }
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemGroupedBackground))
        )
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color(.separator).opacity(0.5), lineWidth: 0.5)
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .contextMenu {
            Button(
                subtask.isCompleted ? "Mark as not done" : "Mark as done",
                systemImage: subtask.isCompleted ? "circle" : "checkmark.circle",
                action: onToggle
            )

            Button("Remove", systemImage: "trash", role: .destructive, action: onRemove)
        }
    }

    private var content: some View {
        HStack(spacing: 10) {
            Button(action: onToggle) {
                Image(systemName: subtask.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.body)
                    .foregroundStyle(subtask.isCompleted ? tint : Color.secondary)
                    .contentTransition(.symbolEffect(.replace))
                    .frame(width: 34, height: 34)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            Text(subtask.title)
                .font(.footnote)
                .strikethrough(subtask.isCompleted, color: .secondary)
                .foregroundStyle(subtask.isCompleted ? .secondary : .primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(.vertical, 4)
        .padding(.trailing, 10)
    }
}
