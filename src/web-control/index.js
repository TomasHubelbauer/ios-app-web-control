let peerConnection;
let dataChannel;

window.addEventListener('load', _ => {
    peerConnection = new RTCPeerConnection({ iceServers: [{ urls: ['stun:stun.l.google.com:19302'] }] });

    peerConnection.addEventListener('connectionstatechange', _event => {
        report('connectionstatechange', peerConnection.connectionState);
    });

    peerConnection.addEventListener('datachannel', event => {
        report('datachannel', event.channel);
    });

    peerConnection.addEventListener('icecandidate', event => {
        report('icecandidate', event.candidate, event.url);
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

    peerConnection.addEventListener('negotiationneeded', event => {
        report('negotiationneeded');
    });

    peerConnection.addEventListener('signalingstatechange', event => {
        report('signalingstatechange', peerConnection.signalingState);
    });

    peerConnection.addEventListener('statsended', event => {
        report('statsended', event.report);
    });

    peerConnection.addEventListener('track', event => {
        report('statsended', event.receiver, event.streams, event.track, event.transceiver);
    });

    dataChannel = peerConnection.createDataChannel('Channel');

    dataChannel.addEventListener('bufferedamountlow', event => {
        report('bufferedamountlow', dataChannel.bufferedAmount, dataChannel.bufferedAmountLowThreshold);
    });

    dataChannel.addEventListener('close', event => {
        report('close');
    });

    dataChannel.addEventListener('error', event => {
        report('error', event.error);
    });

    dataChannel.addEventListener('message', event => {
        report('message', event.data, event.origin, event.ports, event.source);
    });

    dataChannel.addEventListener('open', event => {
        report('open');
    });
});

// window.webkit.messageHandlers.scriptHandler.postMessage({ type: 'load' });

function report(name, ...args) {
    const messageP = document.createElement('p');
    messageP.textContent = name + ' ' + JSON.stringify(args);
    document.body.appendChild(messageP);
}

function receiveCandidate(a, b) {
    const candidateP = document.createElement('p');
    candidateP.textContent = 'candidate';
    document.body.appendChild(candidateP);
}
