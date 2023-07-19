import SwiftWebview

let wv = Webview(true)
    .setSize(500, 500, .None)
    .setHtml("<h1>Hello World</h1>")

wv.run()
