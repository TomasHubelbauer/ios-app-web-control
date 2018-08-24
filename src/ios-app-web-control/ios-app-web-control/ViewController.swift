import UIKit
import WebKit

class ViewController: UIViewController {
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var controlWebView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        var html = ""
        html += "<!DOCTYPE html>"
        html += "<html>"
        html += "<head>"
        html += "<title>Control</title>"
        html += "<meta charset='utf8'>"
        html += "<meta name='viewport' content='width=device-width' />"
        html += "</head>"
        html += "<body>"
        html += "test"
        html += "</body>"
        html += "</html>"
        controlWebView.loadHTMLString(html, baseURL: nil)
    }
}
