//
//  Dependency.swift
//  PauDependencies
//
//  Created by Pau Blanes on 22/07/2026.
//

/// A property wrapper that resolves a dependency from the current ``DependencyValues``.
///
/// The value is resolved lazily on every access, so overrides applied for the current
/// scope are always reflected.
///
///     @Dependency(\.apiClient) var apiClient
@propertyWrapper
public struct Dependency<Value: Sendable>: Sendable {
    private let keyPath: KeyPath<DependencyValues, Value> & Sendable

    public var wrappedValue: Value {
        DependencyValues.current[keyPath: keyPath]
    }

    /// Creates a dependency for the given key path into ``DependencyValues``.
    public init(_ keyPath: KeyPath<DependencyValues, Value> & Sendable) {
        self.keyPath = keyPath
    }
}
