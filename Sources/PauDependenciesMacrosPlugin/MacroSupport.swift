//
//  MacroSupport.swift
//  PauDependencies
//
//  Created by Pau Blanes on 30/07/2026.
//

#if SwiftSyntaxTrait
import SwiftSyntax

extension PatternBindingSyntax {
    /// The dependency key type name derived from the property name, e.g. `apiClient` -> `ApiClientKey`.
    ///
    /// Deriving from the property name (rather than the value's type) keeps the key unique per
    /// declaration and always a valid identifier, even for `Foo?`, `Foo<Bar>` or two properties
    /// sharing a type.
    var dependencyKeyName: String? {
        guard let name = pattern.as(IdentifierPatternSyntax.self)?.identifier.text else { return nil }
        return "\(name.prefix(1).uppercased())\(name.dropFirst())Key"
    }
}
#endif
