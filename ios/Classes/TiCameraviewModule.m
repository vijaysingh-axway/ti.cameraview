/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 20017-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */


#import "TiCameraviewModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import <AVFoundation/AVFoundation.h>
#import "TiCameraViewConstants.h"

@implementation TiCameraviewModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"11297d48-f1a0-4690-af76-e8398f9a6900";
}

- (NSString *)moduleId
{
	return @"ti.cameraview";
}

#pragma mark Public APIs

// FIXME: Replace with correct view and view-proxy, e.g. TiCameraviewViewProxy / TiCameraviewView
//- (void)add:(id)args
//{
//    ENSURE_SINGLE_ARG_OR_NIL(args, TiViewProxy);
//    ENSURE_UI_THREAD(add, args);
//
//    if ((cameraViewController != nil) && [cameraViewController isViewLoaded]) {
//        TiViewProxy *viewProxy = args;
//        UIView *view = [viewProxy view];
//        
//        ApplyConstraintToViewWithBounds([viewProxy layoutProperties], (TiUIView *)view, [cameraViewController.view bounds]);
//        
//        [viewProxy windowWillOpen];
//        [cameraViewController.view addSubview:view];
//        [viewProxy windowDidOpen];
//    } else {
//        DebugLog(@"Camera creation or camera opening failed");
//    }
//}

#pragma mark Constants

MAKE_SYSTEM_PROP(TORCH_MODE_OFF, AVCaptureTorchModeOff);
MAKE_SYSTEM_PROP(TORCH_MODE_ON, AVCaptureTorchModeOn);
MAKE_SYSTEM_PROP(TORCH_MODE_AUTO, AVCaptureTorchModeAuto);

MAKE_SYSTEM_PROP(FLASH_MODE_OFF, AVCaptureFlashModeOff);
MAKE_SYSTEM_PROP(FLASH_MODE_ON, AVCaptureFlashModeOn);
MAKE_SYSTEM_PROP(FLASH_MODE_AUTO, AVCaptureFlashModeAuto);

MAKE_SYSTEM_PROP(FOCUS_MODE_LOCKED, AVCaptureFocusModeLocked);
MAKE_SYSTEM_PROP(FOCUS_MODE_AUTO_FOCUS, AVCaptureFocusModeAutoFocus);
MAKE_SYSTEM_PROP(FOCUS_MODE_CONTINUOUS_AUTO_FOCUS, AVCaptureFocusModeContinuousAutoFocus);

MAKE_SYSTEM_PROP(EXPOSURE_MODE_LOCKED, AVCaptureExposureModeLocked);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_AUTO_EXPOSE, AVCaptureExposureModeAutoExpose);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_CONTINUOUS_AUTO_EXPOSE, AVCaptureExposureModeContinuousAutoExposure);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_CUSTOM, AVCaptureExposureModeCustom);

MAKE_SYSTEM_PROP(CAMERA_TYPE_FRONT, TiCameraTypeFront);
MAKE_SYSTEM_PROP(CAMERA_TYPE_REAR, TiCameraTypeRear);
@end
