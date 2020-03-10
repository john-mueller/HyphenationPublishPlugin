// HyphenationPublishPlugin
// © 2020 John Mueller
// MIT license, see LICENSE.md for details

import Hyphenation
import Ink
import Publish
import SwiftSoup

public extension Plugin {
    /// Hyphenate text parsed from Markdown files.
    ///
    /// Text contained in paragraphs and blockquotes will be hyphenated with the `separator` character
    ///  according to the Knuth-Liang algorithm. Text inside `<pre>` or `<code>` elements will not be hyphenated.
    ///
    /// See https://github.com/john-mueller/Hyphenation for more information.
    ///
    /// - Parameters:
    ///   - separator: The character used to hyphenate words. Defaults to U+00AD (soft hyphen) if not specified.
    static func hyphenate(using separator: Character = "\u{00AD}") -> Self {
        Plugin(name: "Hyphenate") { context in
            makeHyphenationModifiers(using: separator).forEach { modifier in
                context.markdownParser.addModifier(modifier)
            }
        }
    }
}

/// Returns an array of Ink Modifiers which can be added to a MarkdownParser instance to enable automatic hyphenation.
///
/// Two modifiers, targeting paragraphs and blockquotes, will insert the `separator` character
///  according to the Knuth-Liang algorithm. Text inside `<pre>` or `<code>` elements will not be hyphenated.
///
/// See https://github.com/john-mueller/Hyphenation for more information.
///
/// - Attention: These modifiers each maintain a strong reference to a single `Hyphenator` instance
///    as long as they remain allocated.
///
/// - Parameters:
///   - separator: The character used to hyphenate words. Defaults to U+00AD (soft hyphen) if not specified.
public func makeHyphenationModifiers(using separator: Character) -> [Modifier] {
    let hyphenator = Hyphenator()
    hyphenator.separator = separator

    let closure: Modifier.Closure = { input in
        do {
            if let element = try SwiftSoup.parse(input.html).body()?.children().first() {
                element.recursivelyHyphenate(with: hyphenator)
                return try element.outerHtml()
            }
        } catch {
            print(error)
        }

        return input.html
    }

    return [
        Modifier(target: .paragraphs, closure: closure),
        Modifier(target: .blockquotes, closure: closure),
    ]
}

internal extension Element {
    /// Hyphenate the text in each HTML element, as well as in its children elements.
    ///  Text inside `<pre>` or `<code>` elements will not be hyphenated.
    ///
    /// - Parameters:
    ///   - hyphenator: The `Hyphenator` instance used to hyphenate text.
    func recursivelyHyphenate(with hyphenator: Hyphenator) {
        guard !["pre", "code"].contains(tagName()) else { return }

        children().forEach {
            $0.recursivelyHyphenate(with: hyphenator)
        }

        textNodes().forEach {
            $0.text(hyphenator.hyphenate(text: $0.text()))
        }
    }
}
