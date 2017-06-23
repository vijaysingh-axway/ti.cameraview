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
    CameraType cameraType;
}

@property(nonatomic, assign)id <TiImageCaptureDelegate> delegate;

- (void)setTorchMode:(AVCaptureTorchMode)torchMode;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;
- (void)setFocusMode:(AVCaptureFocusMode)focusMode;
- (void)setCameraType:(CameraType)camera;

@end
