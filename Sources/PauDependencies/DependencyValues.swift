//
//  DependencyValues.swift
//  PauDependencies
//
//  Created by Pau Blanes on 22/07/2026.
//

import Foundation
import IssueReporting

/// A container of dependency values, resolved by ``DependencyKey`` and read through `@Dependency`.
///
/// The values in effect are held in a task-local, so overrides applied with
/// ``dependencies(_:inScope:)`` are scoped to the running task and restored on exit.
public struct DependencyValues: Sendable {

    /// The values in effect for the current task.
    @TaskLocal public static var current = DependencyValues()

    /// The context used to resolve defaults. When `nil`, the context is detected automatically.
    public var context: DependencyContext?

    /// Allows a `liveValue` to be used in the `test` context without reporting an issue.
    public var allowsLiveValuesDuringTesting = false

    private var overrides: [ObjectIdentifier: any Sendable] = [:]

    // MARK: - Subscripts

    /// Resolves the value for the given key: the override if one is set, otherwise the
    /// default for the current ``context``.
    public subscript<Key>(key: Key.Type) -> Key.Value where Key: DependencyDeclarationKey {
        get {
            if let override = overrides[ObjectIdentifier(key)] as? Key.Value {
                return override
            }

            switch context ?? Self.detectedContext {
            case .live:
                return liveValue(for: key) ?? key.declarationValue

            case .test:
                if !allowsLiveValuesDuringTesting {
                    reportIssue("Using liveValue ('\(key)') in a test is forbidden. Override it or set allowsLiveValuesDuringTesting.")
                }
                return liveValue(for: key) ?? key.declarationValue

            case .preview:
                return key.previewValue
            }
        } set {
            overrides[ObjectIdentifier(key)] = newValue
        }
    }

    // MARK: - Public methods

    /// Runs `scope` with dependencies overridden by `mutate`, restoring them when it returns.
    public static func dependencies<Value>(
        _ mutate: MutateDependenciesClosure,
        inScope scope: () throws -> Value
    ) rethrows -> Value {
        var copy = DependencyValues.current
        mutate(&copy)
        return try DependencyValues.$current.withValue(copy, operation: scope)
    }

    /// Runs the asynchronous `scope` with dependencies overridden by `mutate`, restoring them when it returns.
    public static func dependencies<Value>(
        _ mutate: MutateDependenciesClosure,
        inScope scope: () async throws -> Value
    ) async rethrows -> Value {
        var copy = DependencyValues.current
        mutate(&copy)
        return try await DependencyValues.$current.withValue(copy, operation: scope)
    }

    // MARK: - Private

    /// Best-effort detection of the running environment. Computed once per process,
    /// since the environment can't change during a run.
    private static let detectedContext: DependencyContext = {
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return .preview
        }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
            || NSClassFromString("XCTestCase") != nil {
            return .test
        }
        return .live
    }()
    
    /// Resolves the linked live value for `key`, if any.
    ///
    /// A key statically only guarantees ``DependencyDeclarationKey``; its ``DependencyKey/liveValue``
    /// may be supplied by another module that conforms the same key to ``DependencyKey`` — possibly
    /// retroactively — so it can't be reached through the static type. This performs a runtime check
    /// for that conformance and, when present, returns the linked `liveValue`.
    ///
    /// The cast is required rather than simply reading ``DependencyDeclarationKey/declarationValue``:
    /// a split key defines `declarationValue` explicitly in its interface, which *shadows* the
    /// ``DependencyKey`` default that would otherwise forward to `liveValue`. So for such keys
    /// `declarationValue` keeps returning its placeholder even when a live implementation is linked —
    /// only this cast reaches the real value.
    ///
    /// - Returns: the linked ``DependencyKey/liveValue``, or `nil` (after reporting an issue) when no
    ///   ``DependencyKey`` conformance is linked, so the caller can fall back to `declarationValue`.
    private func liveValue<Key: DependencyDeclarationKey>(for key: Key.Type) -> Key.Value? {
        guard let liveKey = key as? any DependencyKey.Type else {
            reportIssue("No live implementation linked for \(key); using declarationValue.")
            return nil
        }

        return liveKey.liveValue as? Key.Value
    }
}
