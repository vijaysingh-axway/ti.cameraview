/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 20017-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "TiCameraViewConstants.h"

@protocol TiImageCaptureDelegate <NSObject>

- (void)didCaptureImage:(UIImage *)image;

@end
 
@interface TiCameraViewController : UIViewController {
    @private
    TiCameraType _cameraType;
    UILabel *captureLabel;
    UILabel *cancelLabel;
    BOOL _shouldShowControl;
}

@property(nonatomic, assign)id <TiImageCaptureDelegate> delegate;
@property(nonatomic) AVCaptureTorchMode torchMode;
@property(nonatomic) AVCaptureFlashMode flashMode;
@property(nonatomic) AVCaptureFocusMode focusMode;
@property(nonatomic) AVCaptureExposureMode exposureMode;
@property(nonatomic) TiCameraType cameraType;

- (id)initWithDelegate:(id<TiImageCaptureDelegate>)delegate;

- (void)showNativeControl:(BOOL)show;
- (void)captureImage;
- (void)cancel;

@end