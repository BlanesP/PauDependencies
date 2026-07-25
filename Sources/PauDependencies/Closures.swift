//
//  Closures.swift
//  PauDependencies
//
//  Created by Pau Blanes on 24/07/2026.
//

/// A closure that mutates a copy of ``DependencyValues`` to override dependencies for a scope.
public typealias MutateDependenciesClosure = @Sendable (inout DependencyValues) -> Void
