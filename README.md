
Summary
---------------
The Ti.CameraView module allows you to use camera feature of iPhone/iPad. This is implemented using AVFoundation framework, so many apis which are not available with UIImagePickerController in iOS can be used. It will depend on requirement whether to use camera from this module or Media of Titanium SDK. As a simple guideline if you want to create your own control use this otherwise Media.

Requirements
---------------
- Titanium Mobile SDK 6.0.0.GA or later
- iOS 8.0 or later

Features
---------------
- [x] Camera functionality. 

Example
---------------
Please see the full-featured example in `example/app.js`.

Build from Source
---------------
- iOS: `appc ti build -p ios --build-only` from the `ios` directory

> Note: Please do not use the (deprecated) `build.py` for iOS and `ant` for Android anymore.
> Those are unified in the above appc-cli these days.

Author
---------------
Appcelerator

License
---------------
Apache 2.0

Contributing
---------------
Code contributions are greatly appreciated, please submit a new [pull request](https://github.com/appcelerator-modules/ti.cameraview/pull/new/master)!
