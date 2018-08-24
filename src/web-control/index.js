window.addEventListener('load', _ => {
    document.body.appendChild(document.createTextNode("JavaScript works"));
});

function receiveCandidate(a, b) {
    document.body.appendChild(document.createTextNode("Swift communication works " + a + ' ' + b));
}
