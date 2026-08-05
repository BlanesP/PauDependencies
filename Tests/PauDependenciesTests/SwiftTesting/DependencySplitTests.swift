//
//  DependencySplitTests.swift
//  swift-testing coverage: the interface/implementation split — declaring a dependency via
//  `DependencyDeclarationKey` and supplying (or not) a linked `DependencyKey`/`liveValue`.
//

import Testing
@testable import PauDependencies

// MARK: - Mocks

/// An interface-only key: it declares a value but no `DependencyKey`/`liveValue` is ever linked,
/// simulating a dependency whose implementation module is absent from the binary.
private enum UnlinkedKey: DependencyDeclarationKey {
    static var declarationValue: String { "declaration" }
}

/// A split key: the "interface" declares a placeholder `declarationValue`, and a separate
/// `DependencyKey` conformance — as an implementation module would add, possibly retroactively —
/// supplies the live value.
private enum SplitKey: DependencyDeclarationKey {
    static var declarationValue: String { "declaration" }
}

extension SplitKey: DependencyKey {
    static var liveValue: String { "live" }
}

extension DependencyValues {
    var unlinked: String {
        get { self[UnlinkedKey.self] }
        set { self[UnlinkedKey.self] = newValue }
    }

    var split: String {
        get { self[SplitKey.self] }
        set { self[SplitKey.self] = newValue }
    }
}

// MARK: - Linked live implementation

@Test(.dependencies { $0.context = .live })
func explicitDeclarationValueShadowsTheLiveDefault() {
    // Reading `declarationValue` directly returns the interface placeholder: the explicit
    // declaration shadows the `DependencyKey` default that would forward to `liveValue`.
    #expect(SplitKey.declarationValue == "declaration")
}

@Test(.dependencies { $0.context = .live })
func linkedLiveValueResolvesOverDeclaration() {
    // Even though `declarationValue` is "declaration", resolution reaches the linked `liveValue`
    // through the runtime conformance check — this is why the cast can't be replaced by reading
    // `declarationValue`.
    #expect(DependencyValues.current.split == "live")
}

// MARK: - No linked implementation

@Test(.dependencies { $0.context = .preview })
func unlinkedKeyResolvesToDeclarationValue() {
    // No `DependencyKey` conformance is linked, so resolution falls back to `declarationValue`
    // (preview forwards to it, without touching the live path).
    #expect(DependencyValues.current.unlinked == "declaration")
}

@Test(.dependencies { $0.context = .live })
func unlinkedKeyInLiveContextReportsIssueAndFallsBack() {
    var resolved = ""
    withKnownIssue {
        // No live implementation linked → reports an issue, then falls back to `declarationValue`.
        resolved = DependencyValues.current.unlinked
    }
    #expect(resolved == "declaration")
}

// MARK: - Overrides

@Test(.dependencies { $0.split = "override" })
func overrideBeatsLinkedLiveValue() {
    #expect(DependencyValues.current.split == "override")
}

@Test(.dependencies { $0.unlinked = "override" })
func overrideBeatsDeclarationValue() {
    #expect(DependencyValues.current.unlinked == "override")
}
