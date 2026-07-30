# Changelog

## 1.1.0

- Add the `@DependencyEntry` macro, which generates both the `DependencyKey` (with its `liveValue`)
  and the `DependencyValues` get/set accessors from a single annotated property. The macro is behind
  the new `SwiftSyntaxTrait` package trait, so `swift-syntax` is only pulled in when opted into, via
  the new `PauDependenciesMacros` product.

## 1.0.1

- Fix a `@MainActor` isolation error in the synchronous Quick `it(dependencies:)` helper.
  The example body now runs through `MainActor.assumeIsolated`, so it builds correctly under
  Xcode's stricter closure-isolation inference (previously it compiled only under `swift build`).

## 1.0.0

- Initial release.
