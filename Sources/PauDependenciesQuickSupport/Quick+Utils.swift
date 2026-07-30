//
//  Quick+Utils.swift
//  PauDependencies
//
//  Created by Pau Blanes on 24/07/2026.
//

#if QuickTrait
import PauDependencies
import Quick

extension SyncDSLUser {
    /// Overrides dependencies for every example in the current group, for the duration of each example.
    public static func dependenciesAroundEach(_ mutate: @escaping MutateDependenciesClosure) {
        aroundEach { runExample in
            DependencyValues.dependencies(mutate) {
                runExample()
            }
        }
    }

    /// Declares a synchronous example that overrides dependencies for the duration of its body.
    public static func it(
        _ description: String,
        file: FileString = #file,
        line: UInt = #line,
        dependencies mutate: @escaping MutateDependenciesClosure,
        closure: @escaping @MainActor () throws -> Void
    ) {
        it(description, file: file, line: line) {
            try DependencyValues.dependencies(mutate) {
                try MainActor.assumeIsolated {
                    try closure()
                }
            }
        }
    }
}

extension AsyncDSLUser {
    /// Overrides dependencies for every example in the current group, for the duration of each example.
    public static func dependenciesAroundEach(_ mutate: @escaping MutateDependenciesClosure) {
        aroundEach { runExample in
            await DependencyValues.dependencies(mutate) {
                await runExample()
            }
        }
    }

    /// Declares an asynchronous example that overrides dependencies for the duration of its body.
    public static func it(
        _ description: String,
        file: FileString = #file,
        line: UInt = #line,
        dependencies mutate: @escaping MutateDependenciesClosure,
        closure: @escaping () async throws -> Void
    ) {
        it(description, file: file, line: line) {
            try await DependencyValues.dependencies(mutate) {
                try await closure()
            }
        }
    }
}
#endif
