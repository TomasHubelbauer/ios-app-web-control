import UIKit
import WebKit
import WebRTC

class ViewController: UIViewController {
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var controlWebView: WKWebView!
    
    let configuration = RTCConfiguration()
    let constraints = RTCMediaConstraints(mandatoryConstraints: [:], optionalConstraints: [:])
    let peerConnectionFactory = RTCPeerConnectionFactory()
    var peerConnection: RTCPeerConnection?
    var dataChannel: RTCDataChannel?

    override func viewDidLoad() {
        super.viewDidLoad()
        controlWebView.navigationDelegate = self
            
        let directoryUrl = Bundle.main.bundleURL.appendingPathComponent("web-control")
        let indexHtmlFileUrl = directoryUrl.appendingPathComponent("index.html")
        controlWebView.loadFileURL(indexHtmlFileUrl, allowingReadAccessTo: directoryUrl)
        
        guard RTCInitializeSSL() else {
            showError("Failed to init WebRTC")
            return
        }
        
        configuration.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
    }
    
    func initiateCommunication() {
        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: constraints, delegate: self)
        dataChannel = peerConnection!.dataChannel(forLabel: "WebControl", configuration: RTCDataChannelConfiguration())
        dataChannel!.delegate = self
    }
    
    func send(_ function: String, _ args: String...) {
        var arguments = ""
        for arg in args {
            arguments += "'\(arg)',"
        }

        // Run communication to the web view on the main thread as required by `evaluateJavaScript`
        DispatchQueue.main.async {
            self.controlWebView.evaluateJavaScript("\(function)(\(arguments))") { (result, error) in
                guard error == nil else {
                    self.showError("Failed at web view eval")
                    return
                }
            }
        }
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Web Control", message: message, preferredStyle: .alert)
        alert.present(self, animated: true, completion: nil)
    }
}

// controlWebView WKNavigationDelegate, WKScriptMessageHandler
extension ViewController: WKNavigationDelegate, WKScriptMessageHandler {
    override func loadView() {
        super.loadView()
        controlWebView.configuration.userContentController.add(self, name: "scriptHandler")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print(#function)
        initiateCommunication()
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print(#function, message)
    }
}

// peerConnection RTCPeerConnectionDelegate
extension ViewController: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print(#function)
        switch stateChanged {
        case .closed: print("closed")
        case .haveLocalOffer: print("haveLocalOffer")
        case .haveLocalPrAnswer: print("haveLocalPrAnswer")
        case .haveRemoteOffer: print("haveRemoteOffer")
        case .haveRemotePrAnswer: print("haveRemotePrAnswer")
        case .stable: print("stable")
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        print(#function)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        print(#function)
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        print(#function)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        print(#function)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        print(#function)
        switch newState {
        case .complete: print("complete")
        case .gathering: print("gathering")
        case .new: print("new")
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print(#function)
        send("receiveCandidate", candidate.sdp, String(candidate.sdpMLineIndex))
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print(#function)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print(#function)
    }
}

// dataChannel RTCDataChannelDelegate
extension ViewController: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print(#function)
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        print(#function)
    }
}
