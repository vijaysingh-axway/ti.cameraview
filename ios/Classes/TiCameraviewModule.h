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

#pragma mark Public API's

/**
 @brief To be documented.
 */
- (id)createCamera:(id)args;

/**
 @brief To be documented.
 */
- (void)open:(id)args;

/**
 @brief To be documented.
 */
- (void)add:(id)args;

/**
 @brief To be documented.
 */
- (void)captureImage:(id)args;

/**
 @brief To be documented.
 */
- (void)dismiss:(__unused id)unused;

/**
 @brief To be documented.
 */
- (void)showNativeControl:(NSNumber *)showNativeControl;

/**
 @brief To be documented.
 */
- (void)setTorchMode:(NSNumber *)torchMode;

/**
 @brief To be documented.
 */
- (NSNumber *)torchMode;

/**
 @brief To be documented.
 */
- (void)setFlashMode:(NSNumber *)flashMode;

/**
 @brief To be documented.
 */
- (NSNumber *)flashMode;

/**
 @brief To be documented.
 */
- (void)setFocusMode:(NSNumber *)focusMode;

/**
 @brief To be documented.
 */
- (NSNumber *)focusMode;

/**
 @brief To be documented.
 */
- (void)setExposureMode:(NSNumber *)exposureMode;

/**
 @brief To be documented.
 */
- (NSNumber *)exposureMode;

/**
 @brief To be documented.
 */
- (void)setCameraType:(NSNumber *)cameraType;

/**
 @brief To be documented.
 */
- (NSNumber *)cameraType;

@end
