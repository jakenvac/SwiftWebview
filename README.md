# Swift Webview

Multi platform webview implementation for swift

> A hard fork of, and based on, the popular [webview](https://github.com/webview/webview) library.
> See [more on this below](#fork).

## Usage

TODO

## Goals

The goals of this pacakge deviate from simply being a binding to [webview](https://github.com/webview/webview).
I would like this to become a goto for people wanting a quick way to make a cross platform desktop application
with swift.

- [ ] Port underlying webview code to swift
- [ ] Implement expanded browser features such as Next, Back etc.
- [ ] Fix memory leaks in the cocoa implementation of webview
  - [ ] webview_set_html
  - [ ] webview_navigate
  - [ ] Identify other sources of memory leaks
- [ ] Design an easier interface for two way interaction with web content
- [ ] Add support for OS theme detection
      ... loads more.

<a id="fork"></a>

## Fork of webview

Why a hard fork?

I chose to hard fork the webview package as it is now largely unmaintained and there exists several bugs that
I intend to fix. If the original package starts accepting PR's again I will gladly contribute my fixes back but for
now I think my efforts are better spent on this work.

In the long term I also want to port as much of the webview code directly into swift.
