# PauDependencies

A lightweight dependency-injection library for Swift, built for Swift 6 strict concurrency.
Inspired by [swift-dependencies](https://github.com/pointfreeco/swift-dependencies) and SwiftUI's `EnvironmentValues`.

## Why

Injecting dependencies through initializers works, but it becomes noisy when a value has to be
threaded through many layers. `PauDependencies` lets any type reach a dependency directly while
keeping it fully replaceable — without global mutable state.

It solves a few specific problems:

- **Testability** — swap any dependency for a mock, scoped to a single test.
- **Safe overrides** — overrides are task-local, so they're isolated per test and safe under
  parallel execution and strict concurrency (no shared mutable state to reset).
- **Context-aware defaults** — dependencies resolve differently in `live`, `test`, and `preview`.
- **Test safety net** — using a real `liveValue` in a test is reported as a failure unless you
  opt in, so you never hit the network by accident.
- **First-class testing** — integrations for both [Swift Testing](https://developer.apple.com/documentation/testing) and [Quick](https://github.com/Quick/Quick).

## Defining a dependency

Conform a key with its `liveValue`, then expose it on `DependencyValues`:

```swift
import PauDependencies

private enum APIClientKey: DependencyKey {
    static let liveValue: APIClient = APIClient()
    // Optional: static let previewValue: APIClient = .preview  (defaults to liveValue)
}

extension DependencyValues {
    var apiClient: APIClient {
        get { self[APIClientKey.self] }
        set { self[APIClientKey.self] = newValue }
    }
}
```

## Using a dependency

Read it anywhere with `@Dependency`. Resolution is lazy, so overrides are always reflected:

```swift
struct PokemonRepository {
    @Dependency(\.apiClient) var apiClient

    func fetch(id: Int) async throws -> Pokemon {
        try await apiClient.fetch(id)
    }
}
```

## Overriding

Override for the duration of a scope — the previous values are restored automatically:

```swift
let pokemon = try await DependencyValues.dependencies {
    $0.apiClient = .mock
} inScope: {
    try await MyRepository.fetch(id: 1)
}
```

A synchronous overload is available too.

## Contexts

Each dependency resolves against a `DependencyContext`, detected automatically:

| context | resolves to | when |
|---------|-------------|------|
| `.live` | `liveValue` | production |
| `.test` | `liveValue`, but reports an issue if not overridden | running tests |
| `.preview` | `previewValue` | Xcode previews |

You can override the context like any other value:

```swift
DependencyValues.dependencies { $0.context = .live } inScope: { ... }
```

In `.test`, reading a `liveValue` without an override fails the test — override the dependency, or
allow it explicitly with `$0.allowsLiveValuesDuringTesting = true`.

## Testing

### Swift Testing

Use the `.dependencies` trait on a test or a whole suite:

```swift
import PauDependenciesTestSupport

@Test(.dependencies { $0.apiClient = .mock })
func loadsPokemon() async throws { ... }

@Suite(.dependencies { $0.apiClient = .mock })
struct RepositoryTests { ... }
```

### Quick

Override for every example in a group, or for a single example:

```swift
import PauDependenciesQuickSupport

describe("PokemonRepository") {
    dependenciesAroundEach { $0.apiClient = .mock }

    it("loads a pokemon") { ... }

    it("handles an error", dependencies: { $0.apiClient = .failing }) { ... }
}
```

## Installation

Add the package to your `Package.swift`:

```swift
.package(url: "https://github.com/BlanesP/PauDependencies.git", from: "1.0.0")
```

Then add the products you need:

```swift
// app / library target
.product(name: "PauDependencies", package: "PauDependencies")

// test target — Swift Testing integration
.product(name: "PauDependenciesTestSupport", package: "PauDependencies")
```

### Quick support (optional)

Quick support is behind a package **trait**, so `Quick` is only pulled in if you ask for it.
Enable the `QuickTrait` trait on the dependency, and add the product to your test target:

```swift
.package(url: "https://github.com/BlanesP/PauDependencies.git", from: "1.0.0", traits: ["QuickTrait"])
```

```swift
// test target
.product(name: "PauDependenciesQuickSupport", package: "PauDependencies")
```

> Consumers who don't enable `QuickTrait` never resolve or link Quick.

## Requirements

- Swift 6.1+ (Xcode 16.3+)
- macOS 10.15+ / iOS 13+

## License

MIT — see [LICENSE](LICENSE).
