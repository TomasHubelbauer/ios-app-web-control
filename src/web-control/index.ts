let peerConnection: RTCPeerConnection;
let dataChannel: RTCDataChannel;
let dataChannelTheirs: RTCDataChannel;

type Message = {
    type: string;
    [key: string]: string | number | boolean | Message;
};

interface Window {
    webkit: {
        messageHandlers: {
            // This comes from the name set up in the Swift code
            scriptHandler: {
                postMessage: (message: Message) => void;
            }
        }
    }
}

window.addEventListener('load', _ => {
    const contentInput = document.querySelector<HTMLInputElement>('#contentInput');

    peerConnection = new RTCPeerConnection({ iceServers: [{ urls: ['stun:stun.l.google.com:19302'] }] });

    peerConnection.addEventListener('connectionstatechange', _event => {
        report('connectionstatechange', peerConnection.connectionState);
    });

    peerConnection.addEventListener('datachannel', event => {
        report('datachannel', event.channel.label);
        dataChannelTheirs = event.channel;

        event.channel.addEventListener('bufferedamountlow', _event => {
            report('bufferedamountlow theirs', event.channel.bufferedAmount, event.channel.bufferedAmountLowThreshold);
        });

        event.channel.addEventListener('close', _event => {
            report('close theirs');
        });

        event.channel.addEventListener('error', event => {
            report('error theirs', event.error);
        });

        event.channel.addEventListener('message', event => {
            report('message theirs', event.data, event.origin, event.ports, event.source);
        });

        event.channel.addEventListener('open', _event => {
            report('open theirs', event.channel.label);
        });
    });

    peerConnection.addEventListener('icecandidate', event => {
        if (event.candidate === null) {
            return;
        }

        window.webkit.messageHandlers.scriptHandler.postMessage({
            type: 'candidate',
            sdp: event.candidate.candidate,
            sdpMid: event.candidate.sdpMid,
            sdpMLineIndex: event.candidate.sdpMLineIndex.toString(),
        });
    });

    peerConnection.addEventListener('icecandidateerror', event => {
        report('icecandidateerror', event.errorCode, event.errorText, event.hostCandidate, event.url);
    });

    peerConnection.addEventListener('iceconnectionstatechange', _event => {
        report('iceconnectionstatechange', peerConnection.iceConnectionState);
    });

    peerConnection.addEventListener('icegatheringstatechange', _event => {
        report('icegatheringstatechange', peerConnection.iceGatheringState);
    });

    peerConnection.addEventListener('negotiationneeded', async _event => {
        const offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);
        window.webkit.messageHandlers.scriptHandler.postMessage({
            type: 'offer',
            sdp: offer.sdp,
        });
    });

    peerConnection.addEventListener('signalingstatechange', _event => {
        report('signalingstatechange', peerConnection.signalingState);
    });

    peerConnection.addEventListener('statsended', event => {
        report('statsended', event.report);
    });

    peerConnection.addEventListener('track', event => {
        report('statsended', event.receiver, event.streams, event.track, event.transceiver);
    });

    dataChannel = peerConnection.createDataChannel('WebChannel');

    dataChannel.addEventListener('bufferedamountlow', _event => {
        report('bufferedamountlow', dataChannel.bufferedAmount, dataChannel.bufferedAmountLowThreshold);
    });

    dataChannel.addEventListener('close', _event => {
        report('close');
    });

    dataChannel.addEventListener('error', event => {
        report('error', event.error);
    });

    dataChannel.addEventListener('message', event => {
        report('message mine', event.data, event.origin, event.ports, event.source);
        contentInput.value = event.data;
    });

    dataChannel.addEventListener('open', _event => {
        report('open', dataChannel.label);
    });

    contentInput.addEventListener('input', _event => {
        if (dataChannel) {
            dataChannel.send(contentInput.value);
        }

        if (dataChannelTheirs) {
            //dataChannelTheirs.send(contentInput.value);
        }
    });
});

async function receiveAnswer(sdp: string) {
    const sessionDescription = new RTCSessionDescription({ type: 'answer', sdp });
    await peerConnection.setRemoteDescription(sessionDescription);
}

async function receiveCandidate(sdp: string, sdpMLineIndex: string, sdpMid: string) {
    const candidate = new RTCIceCandidate({ candidate: sdp, sdpMLineIndex: Number(sdpMLineIndex), sdpMid });
    await peerConnection.addIceCandidate(candidate);
}

function report(name: string, ...args: any[]) {
    const messageP = document.createElement('p');
    messageP.textContent = name + ' ' + JSON.stringify(args);
    document.body.appendChild(messageP);
}
