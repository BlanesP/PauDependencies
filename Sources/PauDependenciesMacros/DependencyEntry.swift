//
//  DependencyEntry.swift
//  PauDependencies
//
//  Created by Pau Blanes on 30/07/2026.
//

import Foundation

#if SwiftSyntaxTrait
@attached(peer, names: arbitrary)
@attached(accessor)
public macro DependencyEntry() = #externalMacro(
    module: "PauDependenciesMacrosPlugin", type: "DependencyEntryMacro"
)

@attached(peer, names: arbitrary)
@attached(accessor)
public macro DependencyDeclaration() = #externalMacro(
    module: "PauDependenciesMacrosPlugin", type: "DependencyDeclarationMacro"
)
#endif
