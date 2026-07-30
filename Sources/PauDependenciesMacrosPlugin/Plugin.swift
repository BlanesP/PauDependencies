//
//  Plugin.swift
//  PauDependencies
//
//  Created by Pau Blanes on 30/07/2026.
//

#if SwiftSyntaxTrait
import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct MacrosPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        DependencyEntryMacro.self
    ]
}
#endif
