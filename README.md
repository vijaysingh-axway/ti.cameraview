# Ti.CameraView

## Summary
The Ti.CameraView module allows you to use native camera features of iOS. 
This is implemented using the `AVFoundation` framework, which contains many API's that are not 
available with `UIImagePickerController` that is used in `Ti.Media.showCamera`. It is an optional 
module that can be used together with Ti.Media of the Titanium SDK or standalone. 

## Requirements
---------------
- Titanium Mobile SDK 6.0.0.GA or later
- iOS 8.0 or later

## Features
- [x] Camera functionality. 

## Example
Please see the full-featured example in `example/app.js`.

## Build from Source
- iOS: `appc ti build -p ios --build-only` from the `ios` directory

> Note: Please do not use the (deprecated) `build.py` for iOS and `ant` for Android anymore.
> Those are unified in the above appc-cli these days.

## Author
Vijay Vikram Singh, Appcelerator

## License
Apache 2.0

## Contributing
Code contributions are greatly appreciated, please submit a new [pull request](https://github.com/appcelerator-modules/ti.cameraview/pull/new/master)!
