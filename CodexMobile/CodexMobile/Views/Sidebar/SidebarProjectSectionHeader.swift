// FILE: SidebarProjectSectionHeader.swift
// Purpose: Tappable header for a project section. Hosts the project glyph and
//          label on the leading edge and a trailing "new chat in project"
//          composer button. Exposes context-menu hooks for archive/delete.
//          Built on top of the shared `SidebarSectionHeader` so the leading
//          icon, label, and trailing slot share the same slot grid used by
//          every other sidebar section (Pinned, rootless Chats, ...).
// Layer: View Component
// Exports: SidebarProjectSectionHeader
// Depends on: SwiftUI, SidebarSectionHeader, HapticButton, SidebarThreadGroup,
//             RemodexIcon, CodexWorktreeIcon, AppFont

import SwiftUI

struct SidebarProjectSectionHeader: View {
    let group: SidebarThreadGroup
    let isExpanded: Bool
    let isConnected: Bool
    let isCreatingThread: Bool
    let onToggle: () -> Void
    let onCreate: () -> Void
    var onArchive: (() -> Void)? = nil
    var onDelete: (() -> Void)? = nil

    var body: some View {
        SidebarSectionHeader(
            label: group.label,
            onToggle: onToggle,
            leadingIcon: { leadingIcon },
            trailing: { composeButton },
            contextMenuContent: { contextMenuContent }
        )
    }

    @ViewBuilder
    private var leadingIcon: some View {
        if group.iconSystemName == "arrow.triangle.branch" {
            CodexWorktreeIcon(pointSize: 16, weight: .medium)
                .foregroundStyle(.primary)
        } else {
            RemodexIcon.image(systemName: resolvedIconName)
                .font(AppFont.body(weight: .medium))
                .foregroundStyle(.primary)
                .contentTransition(.symbolEffect(.replace))
        }
    }

    private var composeButton: some View {
        // The inner `.frame(width: 30, height: 30)` is what gives the
        // button a real 30pt tap surface (SwiftUI `.frame(...)` only
        // resizes the bounding box of a view, it does not extend the
        // button's content-shape tap area). The shared header wraps the
        // result in the same 30pt slot, so the visual frame matches every
        // other section trailing affordance — but the tap target lives on
        // the button itself.
        HapticButton(hapticStyle: .medium, action: onCreate) {
            RemodexIcon.image(systemName: "square.and.pencil", size: 20, weight: .medium)
                .foregroundStyle(.secondary.opacity(0.6))
                .frame(
                    width: SidebarSectionHeaderTrailingSlotSize.length,
                    height: SidebarSectionHeaderTrailingSlotSize.length
                )
        }
        .buttonStyle(.plain)
        .disabled(!isConnected || isCreatingThread)
    }

    @ViewBuilder
    private var contextMenuContent: some View {
        if let onArchive {
            HapticButton(action: onArchive) {
                RemodexIcon.menuLabel("Archive Project", systemName: "archivebox")
            }
        }

        if let onDelete {
            HapticButton(role: .destructive, action: onDelete) {
                Label("Remove from Phone", systemImage: "trash")
            }
        }
    }

    private var resolvedIconName: String {
        if isExpanded, group.iconSystemName == "folder" {
            return "folder.fill"
        }
        return group.iconSystemName
    }
}
