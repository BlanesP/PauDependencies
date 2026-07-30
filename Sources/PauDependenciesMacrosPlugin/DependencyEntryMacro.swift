//
//  DependencyEntryMacro.swift
//  PauDependencies
//
//  Created by Pau Blanes on 30/07/2026.
//

#if SwiftSyntaxTrait
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct DependencyEntryMacro {
}

extension DependencyEntryMacro: AccessorMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard
            let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first
        else { return [] }
        
        guard let typeName = binding.typeAnnotation?.type.trimmedDescription else {
            context.diagnose(
                Diagnostic(
                    node: binding,
                    message: MacroExpansionErrorMessage(
                        "@DependencyEntry requires an explicit type, e.g. `var service: Service = ServiceImpl()`."
                    )
                )
            )
            return []
        }
        
        return [
          """
          get { self[\(raw: typeName)Key.self] }
          """,
          """
          set { self[\(raw: typeName)Key.self] = newValue }
          """
        ]
    }
}

extension DependencyEntryMacro: PeerMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingPeersOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.DeclSyntax] {
        guard
            let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first
        else { return [] }
        
        guard let typeName = binding.typeAnnotation?.type.trimmedDescription else {
            context.diagnose(
                Diagnostic(
                    node: binding,
                    message: MacroExpansionErrorMessage(
                        "@DependencyEntry requires an explicit type, e.g. `var service: Service = ServiceImpl()`."
                    )
                )
            )
            return []
        }
        
        guard let value = binding.initializer?.value else {
            context.diagnose(
                Diagnostic(
                    node: binding,
                    message: MacroExpansionErrorMessage(
                        "@DependencyEntry requires a default value, e.g. `= ServiceImpl()`."
                    )
                )
            )
            return []
        }
        
        return [
            """
            enum \(raw: typeName)Key: DependencyKey {
                static let liveValue: \(raw: typeName) = \(value)
            }
            """
        ]
    }
}
#endif
