// FILE: SubscriptionServiceAccessTests.swift
// Purpose: Verifies the local free-send gate allows 5 attempts before the hard paywall path.
// Layer: Unit Test
// Exports: SubscriptionServiceAccessTests
// Depends on: XCTest, CodexMobile

import XCTest
@testable import CodexMobile

@MainActor
final class SubscriptionServiceAccessTests: XCTestCase {
    func testFreshFreeUserStartsWithFiveAttempts() {
        let service = makeService(selfHostedAccessEnabled: false)

        XCTAssertEqual(service.freeSendCount, 0)
        XCTAssertEqual(service.remainingFreeSendAttempts, 5)
        XCTAssertTrue(service.hasFreeSendAccess)
        XCTAssertTrue(service.hasAppAccess)
    }

    func testFreeSendAttemptsStopAtLimit() {
        let service = makeService(selfHostedAccessEnabled: false)

        for _ in 0..<7 {
            service.consumeFreeSendAttemptIfNeeded()
        }

        XCTAssertEqual(service.freeSendCount, 5)
        XCTAssertEqual(service.remainingFreeSendAttempts, 0)
        XCTAssertFalse(service.hasFreeSendAccess)
        XCTAssertFalse(service.hasAppAccess)
    }

    func testSelfHostedSourceBuildKeepsAccessAfterFreeLimit() {
        let service = makeService(selfHostedAccessEnabled: true)

        for _ in 0..<7 {
            service.consumeFreeSendAttemptIfNeeded()
        }

        XCTAssertTrue(service.hasSelfHostedAccess)
        XCTAssertEqual(service.freeSendCount, 0)
        XCTAssertTrue(service.hasFreeSendAccess)
        XCTAssertTrue(service.hasAppAccess)
    }

    private func makeService(selfHostedAccessEnabled: Bool) -> SubscriptionService {
        let suiteName = "SubscriptionServiceAccessTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return SubscriptionService(defaults: defaults, selfHostedAccessEnabled: selfHostedAccessEnabled)
    }
}
