/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "Constants.h"

@protocol TiImageCaptureDelegate <NSObject>

- (void)didCaptureImage:(UIImage *)image;

@end
 
@interface TiCameraViewController : UIViewController
{
    @private
    CameraType _cameraType;
    UILabel *captureLabel;
    UILabel *cancelLabel;
    BOOL shouldShowControl;
}

@property(nonatomic, assign)id <TiImageCaptureDelegate> delegate;
@property(nonatomic)AVCaptureTorchMode torchMode;
@property(nonatomic)AVCaptureFlashMode flashMode;
@property(nonatomic)AVCaptureFocusMode focusMode;
@property(nonatomic)AVCaptureExposureMode exposureMode;
@property(nonatomic)CameraType cameraType;

- (void)showNativeControl:(BOOL)show;
- (void)captureImage;
- (void)cancel;

@end
