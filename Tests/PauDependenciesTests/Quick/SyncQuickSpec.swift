//
//  SyncQuickSpec.swift
//  Quick coverage for the synchronous `dependenciesAroundEach` / `it(dependencies:)` helpers.
//

#if QuickTrait
import Quick
import Nimble
import PauDependencies
import PauDependenciesQuickSupport

final class SyncDependenciesSpec: QuickSpec {
    override class func spec() {
        describe("dependenciesAroundEach") {
            dependenciesAroundEach { $0.counter = 42 }

            it("applies the override to every example") {
                expect(DependencyValues.current.counter).to(equal(42))
            }

            it("is overridden by a per-example it(dependencies:)", dependencies: { $0.counter = 13 }) {
                expect(DependencyValues.current.counter).to(equal(13))
            }

            it("restores the group override after a per-example override") {
                expect(DependencyValues.current.counter).to(equal(42))
            }
        }

        describe("allowsLiveValuesDuringTesting") {
            it("returns the live value when explicitly allowed",
               dependencies: { $0.allowsLiveValuesDuringTesting = true }) {
                expect(DependencyValues.current.counter).to(equal(0))
            }
        }

        describe("@MainActor dependencies in a sync spec") {
            it("calls a @MainActor helper directly, no await",
               dependencies: { $0.counter = 5 }) {
                expect(MainActorOnly.readCounter()).to(equal(5))
            }

            it(
                "calls a @MainActor dependency method directly, no await",
                dependencies: { $0.nameProvider = MockNameProvider(name: "sync mock") }
            ) {
                expect(DependencyValues.current.nameProvider.currentName()).to(equal("sync mock"))
            }
        }
    }
}
#endif
