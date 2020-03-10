# Hyphenation plugin for Publish

A [Publish](https://github.com/JohnSundell/Publish) plugin that automatically hyphenates the text of your website using [Hyphenation](https://github.com/john-mueller/Hyphenation).

## Installation

To install the plugin, add it as a dependency within your `Package.swift` manifest:

```swift
let package = Package(
    ...
    dependencies: [
        ...
        .package(url: "https://github.com/john-mueller/HyphenationPublishPlugin", from: "0.1.0")
    ],
    targets: [
        .target(
            ...
            dependencies: [
                ...
                "HyphenationPublishPlugin"
            ]
        )
    ]
    ...
)
```

Then import `HyphenationPublishPlugin` where you'd like to use it.

## Usage

The `hyphenate(using:)` plugin can be installed in a publishing pipeline using the `installPlugin(_:)` step. The default separator character is U+00AD (soft hyphen) if the parameter is omitted.

```swift
import HyphenationPublishPlugin
...
try DeliciousRecipes().publish(using: [
    .installPlugin(.hyphenate())
    ...
])
```

You can create the `Modifer`s for [Ink's](https://github.com/JohnSundell/Ink) `MarkdownParser` directly using the global  `makeHyphenationModifiers(using:)` method. 

```swift
import HyphenationPublishPlugin
import Ink

let parser = MarkdownParser(modifiers: makeHyphenationModifiers(using: "-"))
print(parser.html(from: "hyphenate")) // prints "<p>hy-phen-ate</p>"
```
