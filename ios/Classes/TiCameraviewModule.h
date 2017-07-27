/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 20017-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */


#import "TiCameraViewController.h"
#import "TiViewProxy.h"
#import "KrollCallback.h"
#import "TiModule.h"

@interface TiCameraviewModule : TiModule <TiImageCaptureDelegate>
{
    @private
    TiCameraViewController *cameraViewController;
    KrollCallback *successCallback;
    KrollCallback *errorCallback;
    KrollCallback *cancelCallback;
    bool saveToRoll;
}

@end
