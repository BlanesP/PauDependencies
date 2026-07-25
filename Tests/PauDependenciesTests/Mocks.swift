//
//  Mocks.swift
//  Shared test dependencies used by both the swift-testing and Quick suites.
//

import PauDependencies

// MARK: - counter

/// An `Equatable` dependency, so tests can tell the live value and an override apart.
private enum CounterKey: DependencyKey {
    static let liveValue = 0
}

extension DependencyValues {
    var counter: Int {
        get { self[CounterKey.self] }
        set { self[CounterKey.self] = newValue }
    }
}

// MARK: - greeting (a dependency with a distinct previewValue)

/// A dependency whose `previewValue` differs from its `liveValue`, so preview-context
/// resolution can be told apart from live.
private enum GreetingKey: DependencyKey {
    static let liveValue = "live"
    static let previewValue = "preview"
}

extension DependencyValues {
    var greeting: String {
        get { self[GreetingKey.self] }
        set { self[GreetingKey.self] = newValue }
    }
}

// MARK: - nameProvider (a @MainActor dependency)

@MainActor
protocol NameProviding: Sendable {
    func currentName() -> String
}

struct LiveNameProvider: NameProviding {
    func currentName() -> String { "live" }
}

struct MockNameProvider: NameProviding {
    let name: String
    nonisolated init(name: String) { self.name = name }
    func currentName() -> String { name }
}

private enum NameProviderKey: DependencyKey {
    static let liveValue: any NameProviding = LiveNameProvider()
}

extension DependencyValues {
    var nameProvider: any NameProviding {
        get { self[NameProviderKey.self] }
        set { self[NameProviderKey.self] = newValue }
    }
}

// MARK: - Helpers

/// A consumer that resolves its dependency lazily through `@Dependency`.
struct Consumer {
    @Dependency(\.counter) var counter
}

/// Reads a dependency from a synchronous, `@MainActor` context — used to prove the
/// sync `it(dependencies:)` body runs on the main actor (no `await`, no `assumeIsolated`).
@MainActor
enum MainActorOnly {
    static func readCounter() -> Int {
        DependencyValues.current.counter
    }
}
