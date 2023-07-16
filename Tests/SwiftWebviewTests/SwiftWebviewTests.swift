@testable import SwiftWebview
import XCTest

final class swift_webviewTests: XCTestCase {
    func testExample() throws {
        let wv = WebView()
            .setHtml("<h1>some title</h1>")

        wv.run()
    }
}
