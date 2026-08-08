//
//  SyncStatusView.swift
//  TaskBoard
//
//  Created by Nishant Kumar on 08/08/26.
//

import Foundation
import SwiftUI

struct SyncStatusView: View {

    let status: SyncStatus

    var body: some View {
        if let message {
            HStack(spacing: 6) {
                icon
                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.bar)
            .overlay(alignment: .bottom) { Divider() }
        }
    }

    @ViewBuilder
    private var icon: some View {
        if status.isSyncing {
            ProgressView().controlSize(.mini)
        } else if !status.isOnline {
            Image(systemName: "wifi.slash").font(.caption).foregroundStyle(.orange)
        } else if status.pendingCount > 0 {
            Image(systemName: "arrow.triangle.2.circlepath")
                .font(.caption).foregroundStyle(.orange)
        } else {
            Image(systemName: "checkmark.icloud").font(.caption).foregroundStyle(.green)
        }
    }

    private var message: String? {
        if status.isSyncing {
            return "Syncing…"
        }

        if !status.isOnline {
            return status.pendingCount == 0
                ? "Offline — your work is saved on this device"
                : "Offline — \(changes(status.pendingCount)) waiting to sync"
        }

        if status.pendingCount > 0 {
            return "\(changes(status.pendingCount)) waiting to sync"
        }

        if let lastSyncedAt = status.lastSyncedAt {
            return "Last synced \(RelativeTime.string(from: lastSyncedAt))"
        }

        return nil
    }

    private func changes(_ count: Int) -> String {
        "\(count) \(count == 1 ? "change" : "changes")"
    }
}

