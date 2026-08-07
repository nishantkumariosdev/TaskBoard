//
//  BoardEmptyStateView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 07/08/26.
//

import Foundation
import SwiftUI

struct BoardEmptyStateView: View {
    let onCreate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "square.stack.3d.up")
                .font(.system(size: 44))
                .foregroundStyle(.tint)
            
            VStack(spacing: 6) {
                Text("Your board is empty")
                    .font(.title3.weight(.semibold))
                Text("Add a task to get started")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Button(action: onCreate) {
                Label("Add your first task", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(32)
        .frame(maxWidth: 420)
    }
}
