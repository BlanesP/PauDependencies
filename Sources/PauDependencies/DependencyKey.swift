//
//  DependencyKey.swift
//  PauDependencies
//
//  Created by Pau Blanes on 22/07/2026.
//

/// A type that *declares* a dependency without providing its live implementation.
///
/// Its purpose is to let a module expose a dependency through ``DependencyValues`` while the concrete
/// implementation lives elsewhere (typically a separate module). It supplies only a
/// ``declarationValue`` — the value resolved when no live implementation is linked — which is usually
/// a `fatalError`, since resolution expects a linked ``DependencyKey/liveValue`` to provide the real value.
///
/// Declare the key and expose it as a computed property on ``DependencyValues``:
///
///     public enum APIClientKey: DependencyDeclarationKey {
///         public static var declarationValue: APIClient {
///             fatalError("No live implementation linked for APIClient")
///         }
///     }
///
///     extension DependencyValues {
///         public var apiClient: APIClient {
///             get { self[APIClientKey.self] }
///             set { self[APIClientKey.self] = newValue }
///         }
///     }
///
/// A separate module supplies the implementation by conforming the same key to ``DependencyKey``.
public protocol DependencyDeclarationKey {
    /// The type of value the dependency provides.
    associatedtype Value: Sendable

    /// The value resolved when no live implementation is linked into the binary.
    ///
    /// In an interface-only module this is typically a `fatalError`, since a linked
    /// ``DependencyKey/liveValue`` is expected to supply the real value. When a key conforms directly
    /// to ``DependencyKey``, this defaults to its ``DependencyKey/liveValue``.
    static var declarationValue: Value { get }

    /// The value used in the `preview` context. Defaults to ``declarationValue``.
    static var previewValue: Value { get }
}

extension DependencyDeclarationKey {
    public static var previewValue: Value { declarationValue }
}

/// A type that provides the live implementation for a dependency.
///
/// Conform a key directly to `DependencyKey` when the implementation lives in the same module. To
/// split across modules, the interface declares the key as a ``DependencyDeclarationKey`` and a
/// separate module adds `DependencyKey` conformance (possibly retroactively) to supply ``liveValue``;
/// ``DependencyValues`` reaches it at runtime via a linked-conformance check.
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
public protocol DependencyKey: DependencyDeclarationKey {
    // Re-stating `Value` here anchors associated-type inference for the `DependencyKey`
    // conformance to `liveValue`. Without it, a key that declares only `liveValue` cannot
    // infer `Value` for the base `DependencyDeclarationKey` requirements and fails to conform.
    // The `= Self` default silences the "better expressed as a 'where' clause" warning that a
    // bare restatement triggers, and enables the value-is-the-key (struct-of-closures) style;
    // for keys whose value is a distinct type, inference from `liveValue` overrides it.
    associatedtype Value: Sendable = Self

    /// The value used in the `live` context (production).
    static var liveValue: Value { get }
}

extension DependencyKey {
    public static var declarationValue: Value { liveValue }
}
