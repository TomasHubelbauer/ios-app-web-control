import UIKit
import WebKit
import WebRTC

class ViewController: UIViewController {
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var controlWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        let directoryUrl = Bundle.main.bundleURL.appendingPathComponent("web-control")
        let indexHtmlFileUrl = directoryUrl.appendingPathComponent("index.html")
        controlWebView.loadFileURL(indexHtmlFileUrl, allowingReadAccessTo: directoryUrl)
        print(RTCInitializeSSL())
    }
}
