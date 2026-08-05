//
//  DependencyDeclarationMacro.swift
//  PauDependencies
//
//  Created by Pau Blanes on 30/07/2026.
//

#if SwiftSyntaxTrait
import Foundation
import SwiftSyntax
import SwiftSyntaxMacros
import SwiftDiagnostics

public struct DependencyDeclarationMacro {
}

extension DependencyDeclarationMacro: AccessorMacro {
    public static func expansion(
        of node: SwiftSyntax.AttributeSyntax,
        providingAccessorsOf declaration: some SwiftSyntax.DeclSyntaxProtocol,
        in context: some SwiftSyntaxMacros.MacroExpansionContext
    ) throws -> [SwiftSyntax.AccessorDeclSyntax] {
        guard
            let varDecl = declaration.as(VariableDeclSyntax.self),
            let binding = varDecl.bindings.first
        else { return [] }
        
        guard binding.typeAnnotation?.type.trimmedDescription != nil else {
            context.diagnose(
                Diagnostic(
                    node: binding,
                    message: MacroExpansionErrorMessage(
                        "@DependencyDeclaration requires an explicit type, e.g. `var service: Service`."
                    )
                )
            )
            return []
        }

        guard let keyName = binding.dependencyKeyName else { return [] }

        return [
          """
          get { self[\(raw: keyName).self] }
          """,
          """
          set { self[\(raw: keyName).self] = newValue }
          """
        ]
    }
}

extension DependencyDeclarationMacro: PeerMacro {
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
                        "@DependencyDeclaration requires an explicit type, e.g. `var service: Service`."
                    )
                )
            )
            return []
        }

        guard let keyName = binding.dependencyKeyName else { return [] }

        return [
            """
            public enum \(raw: keyName): DependencyDeclarationKey {
                public static var declarationValue: \(raw: typeName) { fatalError("No live implementation linked for \(raw: typeName)") }
            }
            """
        ]
    }
}
#endif
