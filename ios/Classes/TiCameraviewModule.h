/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 20017-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

#import "KrollCallback.h"
#import "TiCameraViewController.h"
#import "TiModule.h"
#import "TiViewProxy.h"

@interface TiCameraviewModule : TiModule <TiImageCaptureDelegate> {
  TiCameraViewController *_cameraViewController;
  KrollCallback *_successCallback;
  KrollCallback *_errorCallback;
  KrollCallback *_cancelCallback;
  BOOL _saveToPhotoGallery;
}

/**
 @brief To be documented.
 */
- (void)open:(id)args;

/**
 @brief To be documented.
 */
- (void)close:(__unused id)unused;

/**
 @brief To be documented.
 */
- (void)captureImage:(id)args;

/**
 @brief To be documented.
 */
- (void)add:(id)args;

/**
 @brief To be documented.
 */
- (void)setShowNativeControl:(NSNumber *)showNativeControl;

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

/**
 @brief To be documented.
 */
- (void)setSaveToPhotoGallery:(NSNumber *)saveToPhotoGallery;

/**
 @brief To be documented.
 */
- (NSNumber *)saveToPhotoGallery;

@end
