# Swift Webview

Cross platform [webview](https://github.com/webview/webview) bindings for swift.

## Dependencies

Depending on the target platform, you'll need to install a few things.

### macOs

It just works™

### Linux

You'll need to install `libgtk-3-dev` and `libwebkit2gtk-4.0-dev` or your distros equivalents.

```sh
sudo apt install libgtk-3-dev libwebkit2gtk-4.0-dev
```

### Windows

Windows is currently untested & not officially supported. Contributions are welcome here.

## Usage

See the generated documentation [here](https://jakenvac.github.io/SwiftWebview/).

### Basic Usage

```swift
import SwiftWebview

// create a new webview
let wv = WebView()
      // navigate to a URL
      .navigate("https://example.com")
      // directly set the HTML
      .setHtml("<h1>Hello World</h1>")
      // set the title of the window
      .setTitle("My Webview Window")
      // set the size of the window
      .setSize(800, 600, .None)
      // inject some javascript into every new page
      .inject("console.log('this happens before window.onload')")
      // asynchronously evaluate some JS in the current page
      .eval("console.log('this was evaled at runtime')")

// run the webview
wv.run()

// destroy the webview once we're done with it
wv.destroy()
```

### Binding functions

```swift
let wv = WebView()

let mySwiftFunction: JSCallback = { args in
  return "Hello \(args[0])"
}

wv.bind("boundFunction", mySwiftFunction)
wv.run()
```

```javascript
var result = window.boundFunction("World");
console.log(result); // Hello World
```
