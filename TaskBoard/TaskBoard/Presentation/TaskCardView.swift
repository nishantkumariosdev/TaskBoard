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
    
    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(task.status.tint)
                .frame(width: 4)
            
            cardContent
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color(.white))
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
            
            if !task.description.isEmpty {
                Text(task.description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Text(RelativeTime.string(from: task.updatedAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                
                Spacer(minLength: 0)
            }
        }
        .padding(12)
    }
    
    private var borderColor: Color {
        Color(.separator).opacity(0.6)
    }
}

#Preview {
    VStack(spacing: 12) {
        TaskCardView(task: BoardTask(id: "1", title: "Hello", description: "This is task 1", status: .inProgress, createdAt: .now, updatedAt: .now.addingTimeInterval(-600)), onEdit: {}, onDelete: {}, onMove: {_ in})
        
        TaskCardView(task: BoardTask(id: "2", title: "Hi", description: "This is task 1", status: .done, createdAt: .now, updatedAt: .now.addingTimeInterval(-600)), onEdit: {}, onDelete: {}, onMove: {_ in})
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    
}
