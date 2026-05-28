// FILE: SettingsSubscriptionCard.swift
// Purpose: Presents Remodex Pro subscription status and purchase actions.
// Layer: Settings UI component
// Exports: SettingsSubscriptionCard
// Depends on: SwiftUI, StoreKit, SubscriptionService, RevenueCatPaywallView

import StoreKit
import SwiftUI

struct SettingsSubscriptionCard: View {
    @Environment(SubscriptionService.self) private var subscriptions
    let onShowPaywall: () -> Void
    let onRedeemCode: () -> Void

    var body: some View {
        SettingsCard(
            title: "Remodex Pro",
            footer: footerText
        ) {
            SettingsValueRow(
                title: "Plan",
                value: planValue,
                valueColor: subscriptions.hasAppAccess ? .green : .secondary
            )

            if !subscriptions.hasSelfHostedAccess {
                SettingsButton(subscriptions.hasProAccess ? "View Pro Benefits" : "Upgrade to Pro") {
                    onShowPaywall()
                }

                SettingsButton("Redeem Code") {
                    onRedeemCode()
                }
                .disabled(subscriptions.isPurchasing || subscriptions.isRestoring)

                SettingsButton(
                    subscriptions.isRestoring ? "Restoring…" : "Restore Purchases",
                    isLoading: subscriptions.isRestoring
                ) {
                    Task {
                        await subscriptions.restorePurchases()
                    }
                }
                .disabled(subscriptions.isPurchasing)
            } else {
                SettingsInlineMessage(
                    text: "Purchases are disabled in this local source build.",
                    tint: .green
                )
            }

            if let error = subscriptions.lastErrorMessage, !error.isEmpty {
                SettingsInlineMessage(text: error, tint: .red)
            }
        }
        .task {
            guard subscriptions.bootstrapState == .idle else {
                return
            }
            await subscriptions.bootstrap()
        }
    }

    private var planValue: String {
        if subscriptions.hasSelfHostedAccess {
            return "Self-hosted"
        }
        return subscriptions.hasProAccess ? "Active" : "Free"
    }

    private var footerText: String {
        if subscriptions.hasSelfHostedAccess {
            return "This source build uses your self-hosted relay without RevenueCat billing."
        }
        if subscriptions.hasProAccess {
            return "Manage billing through your Apple ID subscription settings."
        }
        return "Unlock voice mode, unlimited threads, and more."
    }
}
