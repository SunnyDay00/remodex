// FILE: SidebarSectionHeader.swift
// Purpose: Shared section-header shell for sidebar groups (Pinned, Project,
//          rootless Chats). Centralizes leading icon + label + trailing slot
//          treatment so every section sits in the same horizontal slot grid
//          and every trailing affordance (chevron, new-chat pencil, …) is
//          framed identically. Variations across sections (vertical padding,
//          context menu, what goes into the trailing slot) are exposed as
//          parameters so callers keep local intent without re-implementing
//          the layout.
// Layer: View Component
// Exports: SidebarSectionHeader, SidebarSectionHeaderTrailingSlotSize
// Depends on: SwiftUI, HapticButton, AppFont

import SwiftUI

// Square frame used for every trailing slot (chevron, compose button, ...).
// Matches the tap target the project compose pencil already used (30pt) so
// both passive and active trailing icons sit in the same slot footprint.
enum SidebarSectionHeaderTrailingSlotSize {
    static let length: CGFloat = 30
}

struct SidebarSectionHeader<Leading: View, Trailing: View, MenuContent: View>: View {
    let label: String
    var labelWeight: Font.Weight = .regular
    var verticalPadding: (top: CGFloat, bottom: CGFloat) = (18, 0)
    let onToggle: () -> Void
    @ViewBuilder let leadingIcon: () -> Leading
    @ViewBuilder let trailing: () -> Trailing
    // Pass `{ EmptyView() }` when the section has no context menu (Pinned).
    @ViewBuilder let contextMenuContent: () -> MenuContent

    var body: some View {
        HStack(spacing: 12) {
            HapticButton(action: onToggle) {
                HStack(spacing: 8) {
                    leadingIcon()
                    Text(label)
                        .font(AppFont.body(weight: labelWeight))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .contextMenu {
                contextMenuContent()
            }

            // Unified trailing slot — any icon, chevron, or button the caller
            // passes ends up in the same 30pt square so adjacent sections
            // line up visually even though the inner content differs.
            trailing()
                .frame(
                    width: SidebarSectionHeaderTrailingSlotSize.length,
                    height: SidebarSectionHeaderTrailingSlotSize.length
                )
        }
        .padding(.leading, 6)
        .padding(.trailing, 0)
        .padding(.top, verticalPadding.top)
        .padding(.bottom, verticalPadding.bottom)
    }
}
