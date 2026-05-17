// FILE: SidebarPinnedSectionHeader.swift
// Purpose: Tappable header for the Pinned section. Hosts the pin glyph, label
//          and chevron that toggles the section open/closed. Built on top of
//          the shared `SidebarSectionHeader` so the slot grid (leading icon,
//          label, trailing 30pt slot) matches every other sidebar section.
// Layer: View Component
// Exports: SidebarPinnedSectionHeader
// Depends on: SwiftUI, SidebarSectionHeader, SidebarPinIcon, RemodexIcon, AppFont

import SwiftUI

struct SidebarPinnedSectionHeader: View {
    let label: String
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        SidebarSectionHeader(
            label: label,
            verticalPadding: (top: 10, bottom: 0),
            onToggle: onToggle,
            leadingIcon: {
                SidebarPinIcon(style: .header)
            },
            trailing: {
                // Match the chat/subagent expansion chevron weight and size;
                // the shared section slot handles alignment, while the glyph
                // itself should stay visually quiet.
                RemodexIcon.image(systemName: "chevron.right")
                    .font(AppFont.system(size: 11, weight: .semibold))
                    .foregroundStyle(.secondary.opacity(0.6))
                    .frame(width: 18, height: 18)
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    .animation(.easeInOut(duration: 0.2), value: isExpanded)
            },
            contextMenuContent: { EmptyView() }
        )
        .padding(.horizontal, 16)
    }
}

#if DEBUG
#Preview("Collapsed") {
    SidebarPinnedSectionHeader(label: "Pinned", isExpanded: false, onToggle: {})
}

#Preview("Expanded") {
    SidebarPinnedSectionHeader(label: "Pinned", isExpanded: true, onToggle: {})
}
#endif
