// HyphenationPublishPlugin
// © 2020 John Mueller
// MIT license, see LICENSE.md for details

import HyphenationPublishPlugin
import Ink
import XCTest

final class HyphenationPublishPluginTests: XCTestCase {
    func testHyphenatingParagraphs() {
        let parser = MarkdownParser(modifiers: makeHyphenationModifiers(using: "-"))
        let html = parser.html(from: "Hyphenate text, but not `inline code`.")

        XCTAssertEqual(html, "<p>Hy-phen-ate text, but not <code>inline code</code>.</p>")
    }

    func testHyphenatingBlockQuotes() {
        let parser = MarkdownParser(modifiers: makeHyphenationModifiers(using: "-"))
        let html = parser.html(from: "> An extended quote, including `inline code`.")

        XCTAssertEqual(html, """
        <blockquote>\n <p>An ex-tended quote, \
        in-clud-ing <code>inline code</code>.</p>\n</blockquote>
        """)
    }

    func testSkippingCodeBlocks() {
        let parser = MarkdownParser(modifiers: makeHyphenationModifiers(using: "-"))
        let html = parser.html(from: "```\nNo hyphenation in code blocks.\n```")

        XCTAssertEqual(html, "<pre><code>No hyphenation in code blocks.\n</code></pre>")
    }
}
