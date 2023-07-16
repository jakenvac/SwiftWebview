# Swift Webview

Multi platform webview implementation for swift

> A hard fork of, and based on, the popular [webview](https://github.com/webview/webview) library.
> See [more on this below](#fork).

## Usage

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

## Goals

The goals of this pacakge deviate from simply being a binding to [webview](https://github.com/webview/webview).
I would like this to become a goto for people wanting a quick way to make a cross platform desktop application
with swift.

- [ ] Port underlying webview code to swift
- [ ] Implement expanded browser features such as Next, Back etc.
- [ ] Fix memory leaks in the cocoa implementation of webview
  - [x] webview_set_html
  - [x] webview_navigate
  - [ ] Identify other sources of memory leaks
- [ ] Design an easier interface for two way interaction with web content
- [ ] Add support for OS theme detection
- [ ] Add multi window and UI abstraction
      ... loads more.

## Todo

Slightly different from the goals, the section outlines things left
to do to make a feature complete binding to the current webview library.

- [ ] Test on:
  - [ ] macOs - Cocoa/WebKit
  - [ ] Windows - EdgeHtml
  - [ ] Linux - Webkit2Gtk

<a id="fork"></a>

## Fork of webview

Why a hard fork?

I chose to hard fork the webview package as it is now largely unmaintained and there exists several bugs that
I intend to fix. If the original package starts accepting PR's again I will gladly contribute my fixes back but for
now I think my efforts are better spent on this work.

In the long term I also want to port as much of the webview code directly into swift.
