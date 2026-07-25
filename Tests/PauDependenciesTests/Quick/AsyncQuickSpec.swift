//
//  AsyncQuickSpec.swift
//  Quick coverage for the asynchronous `dependenciesAroundEach` / `it(dependencies:)` helpers.
//

#if QuickTrait
import Quick
import Nimble
import PauDependencies
import PauDependenciesQuickSupport

final class AsyncDependenciesSpec: AsyncSpec {
    override class func spec() {
        describe("dependenciesAroundEach") {
            context("a plain async example") {
                dependenciesAroundEach { $0.counter = 7 }

                it("sees the override after awaiting") {
                    await Task.yield()
                    expect(DependencyValues.current.counter).to(equal(7))
                }
            }

            context("a @MainActor dependency") {
                dependenciesAroundEach { $0.nameProvider = MockNameProvider(name: "mock 1") }

                it("applies the group override and awaits its @MainActor method") {
                    let name = await DependencyValues.current.nameProvider.currentName()
                    expect(name).to(equal("mock 1"))
                }

                it(
                    "is overridden by a per-example it(dependencies:)",
                    dependencies: { $0.nameProvider = MockNameProvider(name: "mock 2") }
                ) {
                    let name = await DependencyValues.current.nameProvider.currentName()
                    expect(name).to(equal("mock 2"))
                }
            }
        }
    }
}
#endif
