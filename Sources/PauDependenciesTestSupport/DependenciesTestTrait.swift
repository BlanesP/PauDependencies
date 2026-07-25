//
//  DependenciesTestTrait.swift
//  PauDependencies
//
//  Created by Pau Blanes on 23/07/2026.
//

import PauDependencies
import Testing

/// A Swift Testing trait that overrides dependencies for the duration of a test or suite.
///
///     @Test(.dependencies { $0.apiClient = .mock })
///     func example() { ... }
public struct DependenciesTestTrait: TestTrait, SuiteTrait, TestScoping {
    let mutate: MutateDependenciesClosure

    public func provideScope(for test: Test, testCase: Test.Case?, performing testLogic: @Sendable () async throws -> Void) async throws {
        try await DependencyValues.dependencies(mutate, inScope: { try await testLogic() })
    }

    public func scopeProvider(for test: Test, testCase: Test.Case?) -> DependenciesTestTrait? {
        self
    }
}

extension Trait where Self == DependenciesTestTrait {
    /// Overrides dependencies for the annotated test or suite.
    public static func dependencies(_ mutate: @escaping MutateDependenciesClosure) -> Self {
        DependenciesTestTrait(mutate: mutate)
    }
}
