//
//  DependencyContext.swift
//  PauDependencies
//
//  Created by Pau Blanes on 25/07/2026.
//

/// The environment a dependency is resolved in, which determines its default value.
public enum DependencyContext: Sendable {
    /// Production. Dependencies resolve to their `liveValue`.
    case live
    /// A running test. Reading a `liveValue` without an override reports an issue,
    /// unless `allowsLiveValuesDuringTesting` is set.
    case test
    /// An Xcode preview. Dependencies resolve to their `previewValue`.
    case preview
}
