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

1. The user decides to use the web control functionality
2. The user navigates to the web control menu in the mobile app
3. The mobile app prompts the user to visit the web app
    - It also intiates a peer connection and a data channel
    - It also starts scanning for the offer and candidates
    - Either it already gathers candidates here and rotates them...
4. The web app initiates a peer connection and data channel, makes an offer and displays it
    - it also starts scanning for the answer and candidates
5. The web app gathers candidates and rotates the offer and candidates codes

At step 5 or 6 the mobile application may notice an offer or a candidate code.

In case of a candidate, it is added to the mobile application's peer connection.

In case of an offer (only the first time it is seen):

1. The mobile application adds the offer as its remote description
2. The mobile application creates an answer
    - In case candidates are only being gathered here, it starts rotating them
    - It display the answer

At this point the web app is rotating its candidates and its offer
and the mobile app is rotating its candidates and its answer.

The web application may notice the mobile applications candidates or answer.

In case of a candidate, it is added to the web application's peer connection.

In case of an answer (only the first time it is seen):

1. The web application add the answer as its remote description
2. The web application creates a pranswer (needed?)

At this point the data channel should open at both ends.

In the future the web application may be changed to be able to act as a peer
(offerer or answered) so that web applications can interconnect with any
acting as the first offered.

The mobile application will always be an answered only, because the web
application doesn't benefit from the mobile one being used as a remote control.
(Or does it?)
