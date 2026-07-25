//
//  DependencyKey.swift
//  PauDependencies
//
//  Created by Pau Blanes on 22/07/2026.
//

/// A type that provides the default values for a single dependency.
///
/// Register the dependency by exposing it as a computed property on ``DependencyValues``:
///
///     private enum APIClientKey: DependencyKey {
///         static let liveValue: APIClient = .live
///     }
///
///     extension DependencyValues {
///         var apiClient: APIClient {
///             get { self[APIClientKey.self] }
///             set { self[APIClientKey.self] = newValue }
///         }
///     }
public protocol DependencyKey {
    /// The type of value the dependency provides.
    associatedtype Value: Sendable

    /// The value used in the `live` context (production).
    static var liveValue: Value { get }

    /// The value used in the `preview` context. Defaults to ``liveValue``.
    static var previewValue: Value { get }
}

extension DependencyKey {
    public static var previewValue: Value { liveValue }
}
