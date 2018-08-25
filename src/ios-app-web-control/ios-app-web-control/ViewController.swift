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
    var dataChannelTheirs: RTCDataChannel?

    override func viewDidLoad() {
        super.viewDidLoad()
        contentTextField.addTarget(self, action: #selector(onContentTextFieldChanged), for: .editingChanged)
        contentTextField.delegate = self
            
        let directoryUrl = Bundle.main.bundleURL.appendingPathComponent("web-control")
        let indexHtmlFileUrl = directoryUrl.appendingPathComponent("index.html")
        controlWebView.loadFileURL(indexHtmlFileUrl, allowingReadAccessTo: directoryUrl)
        controlWebView.navigationDelegate = self
        
        guard RTCInitializeSSL() else {
            showError("Failed to init WebRTC")
            return
        }
        
        configuration.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
    }
    
    @objc func onContentTextFieldChanged(_ textField: UITextField) {
        let dataBuffer = RTCDataBuffer(data: (textField.text ?? "").data(using: .utf8)!, isBinary: false)
        
        if let dataChannel = dataChannel {
            dataChannel.sendData(dataBuffer)
        }
        
        if let dataChannelTheirs = dataChannelTheirs {
            dataChannelTheirs.sendData(dataBuffer)
        }
    }
    
    // TODO: Replace this with a UI audio log as is in the web app
    func showError(_ message: String) {
        print(message)
    }
}

// contentTextField UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: constraints, delegate: self)
        dataChannel = peerConnection!.dataChannel(forLabel: "MobileChannel", configuration: RTCDataChannelConfiguration())
        dataChannel!.delegate = self
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let dict = message.body as! [String: String]
        switch dict["type"] {
        case "offer": do {
            guard let sdp = dict["sdp"] else {
                showError("Failed at offer sdp")
                return
            }
            
            let sessionDescription = RTCSessionDescription(type: .offer, sdp: sdp)
            peerConnection!.setRemoteDescription(sessionDescription, completionHandler: { (error) in
                guard error == nil else {
                    self.showError("Error at set remote description")
                    return
                }
            })
            
            peerConnection!.answer(for: constraints) { (sessionDescription, error) in
                guard error == nil else {
                    self.showError("Error at answer")
                    return
                }
                
                guard let sessionDescription = sessionDescription else {
                    self.showError("Error at answer sessionDescription")
                    return
                }

                self.peerConnection!.setLocalDescription(sessionDescription, completionHandler: { (error) in
                    guard error == nil else {
                        self.showError("Error at setLocalDescription")
                        return
                    }
                })
                
                // Run communication to the web view on the main thread as required by `evaluateJavaScript`
                DispatchQueue.main.async {
                    let javaScript = "receiveAnswer(`\(sessionDescription.sdp)`)"
                    // TODO: Figure out why this works but errors
                    self.controlWebView.evaluateJavaScript(javaScript) { (result, error) in
                        guard error == nil else {
                            self.showError("Failed at web view receiveAnswer")
                            return
                        }
                    }
                }
            }
            }
            
        case "candidate": do {
            guard let sdp = dict["sdp"] else {
                showError("Failed at candidate sdp")
                return
            }
            
            guard let sdpMid = dict["sdpMid"] else {
                showError("Failed at candidate sdpMid")
                return
            }
            
            guard let sdpMLineIndex = Int32(dict["sdpMLineIndex"]!) else {
                showError("Failed at candidate sdpMLineIndex")
                return
            }
            
            let candidate = RTCIceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
            peerConnection!.add(candidate)
            }
        default: print(#function, message.body)
        }
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
        //send("receiveCandidate", , String(candidate.sdpMLineIndex))
        // Run communication to the web view on the main thread as required by `evaluateJavaScript`
        DispatchQueue.main.async {
            let javaScript = "receiveCandidate('\(candidate.sdp)', '\(String(candidate.sdpMLineIndex))', '\(candidate.sdpMid ?? "")')"
            // TODO: Figure out why this works but errors
            self.controlWebView.evaluateJavaScript(javaScript) { (result, error) in
                guard error == nil else {
                    self.showError("Failed at web view receiveCandidate")
                    return
                }
            }
        }
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        print(#function)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        print(#function)
        print(dataChannel.label)
        dataChannelTheirs = dataChannel
        
        // Attach events to this new channel too
        dataChannelTheirs?.delegate = self
    }
}

// dataChannel RTCDataChannelDelegate
extension ViewController: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print(#function, dataChannel.label)
        switch (dataChannel.readyState) {
        case .closed: print("closed")
        case .closing: print("closing")
        case .connecting: print("connecting")
        case .open: print("open")
        }
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        print(#function)
        if let value = String(data: buffer.data, encoding: .utf8) {
            print(value)
            // Set text from the main thread as is required to write to the `text` property
            DispatchQueue.main.async {
                self.contentTextField.text = value
            }
        }
    }
}
