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

/// Used to set the width & height properties of a webview
public enum SizeHint: Int32 {
    /// Width and Height are the default size.
    case None = 0
    /// Window size cannot be changed by the user.
    case Fixed = 1
    /// Width and height are the minimum bounds.
    case Min = 2
    /// Width and height are the maximum bounds.
    case Max = 3
}

public class Webview {
    private var wv: webview_t
    private var destroyed: Bool = false
    private var callbacks: [String: CallbackContext] = [:]

    /// Initializes a Webview
    /// - Parameter debug: Debug mode flag.
    public init(_ debug: Bool = false) {
        wv = webview_create(debug ? 1 : 0, nil)
    }

    deinit {
        if !destroyed {
            destroy()
        }
    }

    /// Runs the webview. This is blocks the main thread
    public func run() {
        if !destroyed {
            webview_run(wv)
        }
    }

    /// Navigates the webview to the specified URL.
    /// - Parameter url: The URL to navigate to.
    /// - Returns: The current instance of Webview for chaining.
    public func navigate(_ url: String) -> Webview {
        if !destroyed {
            webview_navigate(wv, url)
        }
        return self
    }

    /// Sets the HTML content of the webview.
    /// - Parameter html: The HTML content to set.
    /// - Returns: The current instance of Webview for chaining.
    public func setHtml(_ html: String) -> Webview {
        if !destroyed {
            webview_set_html(wv, html)
        }
        return self
    }

    /// Sets the title of the webview.
    /// - Parameter title: The title to set.
    /// - Returns: The current instance of Webview for chaining.
    public func setTitle(_ title: String) -> Webview {
        if !destroyed {
            webview_set_title(wv, title)
        }
        return self
    }

    /// Sets the title of the webview.
    /// - Parameter title: The title to set.
    /// - Returns: The current instance of Webview for chaining.
    public func setSize(_ width: Int32, _ height: Int32, _ hint: SizeHint) -> Webview {
        if !destroyed {
            webview_set_size(wv, width, height, hint.rawValue)
        }
        return self
    }

    /// Injects & executes JavaScript code into every new page in the webview.
    /// It is guaranteed that this will execute before `window.onload`
    /// - Parameter js: The JavaScript code to inject.
    /// - Returns: The current instance of Webview for chaining.
    public func inject(_ js: String) -> Webview {
        if !destroyed {
            webview_init(wv, js)
        }
        return self
    }

    /// Evaluates JavaScript code in the webview. Evaluation happens asynchronously.
    /// The result of the JavaScript is ignored.
    /// Execute a function bound with `bind` if you need two way communication.
    /// - Parameter js: The JavaScript code to evaluate.
    /// - Returns: The current instance of Webview for chaining.
    public func eval(_ js: String) -> Webview {
        if !destroyed {
            webview_eval(wv, js)
        }
        return self
    }

    /// Binds a swift function to a named JavaScript function in the global scope.
    /// - Parameter name: The name that will be used to invoke the function in JavaScript.
    /// - Parameter callback: The swift function to execute when the JS function is invoked
    /// - Returns: The current instance of Webview for chaining.
    public func bind(_ name: String, _ callback: @escaping JSCallback) -> Webview {
        guard !destroyed else {
            return self
        }
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
        return self
    }

    /// Unbinds a function and removes it from the global JavaScript scope
    /// Parameter name: The name of the JavaScript function to unbind.
    func unbind(_ name: String) -> Webview {
        if !destroyed {
            callbacks[name] = nil
            webview_unbind(wv, name)
        }
        return self
    }

    /// Destroys the webview and closes the window.
    /// Once a Webview has been destroyed it cannot be used.
    /// Returns: The current instance of Webview for chaining.
    func destroy() -> Webview {
        if !destroyed {
            callbacks.forEach { key, _ in
                unbind(key)
            }
            callbacks.removeAll()
            webview_destroy(wv)
            destroyed = true
        }
        return self
    }

    /// Terminates the main loop and closes the window.
    /// This function is thread safe.
    /// Returns: The current instance of Webview for chaining.
    func terminate() -> Webview {
        if !destroyed {
            webview_terminate(wv)
        }
        return self
    }
}
