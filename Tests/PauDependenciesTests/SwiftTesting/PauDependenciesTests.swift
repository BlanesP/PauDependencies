//
//  PauDependenciesTests.swift
//  swift-testing coverage: context resolution, overrides, and the `.dependencies` trait.
//

import Testing
@testable import PauDependencies
import PauDependenciesTestSupport

// MARK: - Context resolution

@Test(.dependencies { $0.context = .live })
func liveContextReturnsLiveValue() {
    #expect(DependencyValues.current.counter == 0)
}

@Test func liveValueInTestContextReportsIssue() {
    withKnownIssue {
        _ = DependencyValues.current.counter   // live value in a test is forbidden
    }
}

@Test(.dependencies { $0.allowsLiveValuesDuringTesting = true })
func liveValueAllowedDuringTestingReturnsLiveValue() {
    #expect(DependencyValues.current.counter == 0)
}

@Test(.dependencies { $0.context = .preview })
func previewContextReturnsPreviewValue() {
    #expect(DependencyValues.current.greeting == "preview")
}

@Test(.dependencies { $0.context = .preview })
func previewValueDefaultsToLiveValue() {
    #expect(DependencyValues.current.counter == 0)   // counter has no custom previewValue
}

// MARK: - Overrides

@Test(.dependencies { $0.counter = 42 })
func traitOverrideReplacesValue() {
    #expect(DependencyValues.current.counter == 42)
}

@Test(.dependencies { $0.counter = 55 })
func dependencyWrapperResolvesOverride() {
    #expect(Consumer().counter == 55)
}

@Test(.dependencies { $0.context = .live })
func nestedScopeOverridesThenRestores() {
    #expect(DependencyValues.current.counter == 0)

    DependencyValues.dependencies { $0.counter = 99 } inScope: {
        #expect(DependencyValues.current.counter == 99)
    }

    #expect(DependencyValues.current.counter == 0)
}

@Test func overridesAreIndependentPerInstance() {
    var overridden = DependencyValues()
    overridden.counter = 42

    var untouched = DependencyValues()
    untouched.context = .live   // no override, so allow reading the live value

    #expect(overridden.counter == 42)
    #expect(untouched.counter == 0)
}

// MARK: - @MainActor dependency

@Test(.dependencies { $0.nameProvider = MockNameProvider(name: "mock") })
func mainActorDependencyResolvesOverride() async {
    let name = await DependencyValues.current.nameProvider.currentName()
    #expect(name == "mock")
}

// MARK: - Suite-wide overrides

@Suite(.dependencies { $0.counter = 18 })
struct SuiteWideOverride {
    @Test func inheritsSuiteOverride() {
        #expect(DependencyValues.current.counter == 18)
    }

    @Test(.dependencies { $0.counter = 13 })
    func perTestOverrideBeatsSuite() {
        #expect(DependencyValues.current.counter == 13)
    }
}
