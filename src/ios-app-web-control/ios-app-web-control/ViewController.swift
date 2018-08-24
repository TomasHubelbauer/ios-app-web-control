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
        let directoryUrl = Bundle.main.bundleURL.appendingPathComponent("web-control")
        let indexHtmlFileUrl = directoryUrl.appendingPathComponent("index.html")
        controlWebView.loadFileURL(indexHtmlFileUrl, allowingReadAccessTo: directoryUrl)
        guard RTCInitializeSSL() else {
            let alert = UIAlertController(title: "Web Control", message: "Failed to init WebRTC", preferredStyle: .alert)
            alert.present(self, animated: true, completion: nil)
            return
        }

        configuration.iceServers = [RTCIceServer(urlStrings: ["stun:stun.l.google.com:19302"])]
        peerConnection = peerConnectionFactory.peerConnection(with: configuration, constraints: constraints, delegate: self)
        dataChannel = peerConnection!.dataChannel(forLabel: "WebControl", configuration: RTCDataChannelConfiguration())
        dataChannel!.delegate = self
    }
}

// peerConnection RTCPeerConnectionDelegate
extension ViewController: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        print(#function)
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
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        print(#function)
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
