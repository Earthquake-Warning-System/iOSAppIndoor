# iOSAppIndoor

If there is any retired iPhone, you can use it as sensor.  Bring a new tesk to old iPhones for keeping you safe.
This App is indoor version, it is used to detect shake and issue alert, we suggest user put the phone installed  indoor version app in a steady status when it start detecting, ex : put the phone horizontally and leave it alone.
If you want to receive push notification on your mobile phone when indoor phone detected shake, please check  another our project [iOSAppMobile](https://mwnlgit.ce.ncu.edu.tw/EarthquakeWarningSystem/iOSAppMoblie), you can click scan button on indoor App and QR code button on mobile App to pair two Apps.

## Prerequisites

* Requires Swift 4/5 and Xcode 10.x
* iPhone required above [iOS10.0](https://support.apple.com/en-us/HT208011).
* iOS10.0 [supported devices](https://en.wikipedia.org/wiki/IOS_10#Supported_devices)

## Installing

Download project from git :
```sh
git clone https://github.com/Earthquake-Warning-System/iOSAppIndoor.git
```
Notice that this project use Firebase to send notification, so you need to build a account in Firebase and create a project for this, basically, you need finish following things.
* put google-services.json into mobile version
* Fill out author key

If you need tutorial please check  [FCM setup](https://firebase.google.com/docs/ios/setup)

Open project in Xcode and click build  → make project, then you can run this project.

### Fill in your own FCM key

If you have own Firebase project, you must remember to fill in the key to the project. How to work? Create a property list, and set a key which include your FCMkey. That's all!
If you were still confused, check the [web](https://dev.iachieved.it/iachievedit/using-property-lists-for-api-keys-in-swift-applications/)

## Download from TestFlight
There is test iOSapp enviroment from Apple name "TestFlight". You can find it in AppStore.
If you want install this App with testflight, please send your AppleID to us with E-mail : "ncumwnl337@gmail.com", we are willing to invite you into our test list. In several days, we will send email with verification code to your account. Enter the verification code on testflight, you would see our App.

## Versioning

We use [SemVer](http://semver.org/) for versioning.

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

