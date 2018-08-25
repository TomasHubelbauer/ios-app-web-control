# iOS App Web Control

A demonstration of using WebRTC to achieve communication between an iOS application and a web page.

## Configuring

- Install [Carthage](https://github.com/Carthage/Carthage) for managing Swift dependencies
- Install [TypeScript](https://www.typescriptlang.org/) for converting TypeScript to JavaScript

### Dependencies

- An [unofficial build of WebRTC by Anakros](https://github.com/Anakros/WebRTC)
- TypeScript for converting TypeScript to JavaScript in the web application

## Running

- Mobile application: XCode
- Web application:
    - `cd src/web-control`
    - `tsc -p . -w`

## Debugging

- Mobile application: XCode
- Web application: Safari > Develop > My iPhone > ...

TypeScript source maps are not provided yet.

### Flow

1. The user decides to use web control, clicks Web Control in the mobile app and the mobile app shows the web app URL to visit
    - Currently for simplification, a web view is shown in the mobile app and direct communication is used between the apps
    - In the future, the actual web app will be run in a browser on a laptop and the communication will go over the QR channel
    - The mobile app, upon clicking Web Control, creates a peer connection and a data channel (without offer or answer)
    - The mobile app starts listening for messages from the web app (for now direct communication, in the future a QR channel)
2. The web application is opened and it initiates a peer connection and a data channel and waits for negotiation request
3. The web app requires negotiation and creates an offer, then sets it as its local description and sends its SDP to the mobile app
    - The web app also starts listening for messages from the mobile app immediately after startup (now direct, future QR channel)
    - The web app will start generating candidates at this point and sending them to the mobile app as messages too
4. The mobile app receives the offer SDP message and sets it as its remote description or candidate and adds it to its connection
    - The mobile app creates an answer to the offer message and sets it as its local description, then sends its SDP to the web app
    - The mobile app will start gathering ICE candidates at this point and sending them to the web app as messages
5. The web app receives the answer SDP message and sets it as its remote description or candidate and adds it to its connection
    - Maybe creation of a pranswer is needed here?
6. At this point the data channel should open at both ends

In the future the web application may be changed to be able to act as a peer (offerer or answered)
so that web applications can interconnect with any other and all have the ability to offer first.

The mobile application will always be an answered only, because the web application doesn't benefit
from the mobile one being used as a remote control. (Or does it?)
