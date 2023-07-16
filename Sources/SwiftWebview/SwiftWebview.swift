import cWebview
import Foundation

typealias CCallback = @convention(c) (UnsafePointer<CChar>?, UnsafePointer<CChar>?, UnsafeMutableRawPointer?) -> Void
public typealias JSCallback = ([Any]) throws -> Codable

func parseCallbackArgs(_ json: String) -> [Any]? {
    guard let data = json.data(using: .utf8) else {
        return nil
    }
    return try? JSONSerialization.jsonObject(with: data) as? [Any]
}

struct CallbackContext {
    var webview: webview_t
    var callback: JSCallback

    init(_ wv: webview_t, _ cb: @escaping JSCallback) {
        webview = wv
        callback = cb
    }
}

public enum SizeHint: Int32 {
    case None = 0
    case Fixed = 1
    case Min = 2
    case Max = 3
}

public class WebView {
    private var wv: webview_t
    private var callbacks: [String: CallbackContext] = [:]

    public init(_ debug: Bool = false) {
        wv = webview_create(debug ? 1 : 0, nil)
    }

    deinit {
        callbacks.forEach { key, _ in
            webview_unbind(wv, key)
        }
        callbacks.removeAll()
        webview_terminate(wv)
        webview_destroy(wv)
    }

    public func run() {
        webview_run(wv)
    }

    public func navigate(_ url: String) -> WebView {
        webview_navigate(wv, url)
        return self
    }

    public func setHtml(_ html: String) -> WebView {
        webview_set_html(wv, html)
        return self
    }

    public func setTitle(_ title: String) -> WebView {
        webview_set_title(wv, title)
        return self
    }

    public func setSize(_ width: Int32, _ height: Int32, _ hint: SizeHint) -> WebView {
        webview_set_size(wv, width, height, hint.rawValue)
        return self
    }

    public func inject(_ js: String) -> WebView {
        webview_init(wv, js)
        return self
    }

    public func eval(_ js: String) -> WebView {
        webview_eval(wv, js)
        return self
    }

    public func bind(_ name: String, _ callback: @escaping JSCallback) {
        var context = CallbackContext(wv, callback)
        callbacks[name] = context

        let bridge: CCallback = { seq, req, arg in
            guard let seq = seq, let req = req, let arg = arg else {
                return
            }

            let ctxPointer = arg.bindMemory(to: CallbackContext.self, capacity: 1)
            let ctx = ctxPointer.pointee

            let args = parseCallbackArgs(String(cString: req)) ?? []

            do {
                let encoder = JSONEncoder()
                let cbResult = try ctx.callback(args)
                let jsonData = try encoder.encode(cbResult)
                if let json = String(data: jsonData, encoding: .utf8) {
                    webview_return(ctx.webview, seq, 0, json)
                } else {
                    webview_return(ctx.webview, seq, 0, "{}")
                }
            } catch {
                webview_return(ctx.webview, seq, 1, "{\"error\":\"\(error)\"}")
            }
        }

        let contextPtr = withUnsafeMutablePointer(to: &context) { ptr in
            UnsafeMutableRawPointer(ptr)
        }

        webview_bind(wv, name, bridge, contextPtr)
    }
}
