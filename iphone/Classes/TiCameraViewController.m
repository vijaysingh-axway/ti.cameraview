/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

#import "TiApp.h"
#import <ImageIO/ImageIO.h>
#import "TiCameraViewController.h"

@interface TiCameraViewController ()

@property(nonatomic, strong)AVCaptureSession *session;
@property(nonatomic, strong)AVCaptureDevice *currentCameraDevice;
@property(nonatomic, strong)AVCaptureStillImageOutput *stillImageOutPut;
@property(nonatomic, strong)AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation TiCameraViewController

- (id)init
{
    if (self = [super init]) {
        _cameraType = CameraTypeRear;
        shouldShowControl = NO;
        return self;
    }
}

- (void)viewDidLoad
{
    [self configureCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
    if (shouldShowControl) {
        [self addCaptureButton];
        [self addCancelButton];
    }
    [self.session startRunning];
}

- (void)dealloc
{
    [self.session stopRunning];
    RELEASE_TO_NIL(self.session);
    RELEASE_TO_NIL(self.previewLayer);
    RELEASE_TO_NIL(self.stillImageOutPut);
    RELEASE_TO_NIL(captureLabel);
    RELEASE_TO_NIL(cancelLabel);
    [super dealloc];
}

- (void)addCaptureButton
{
    if (!captureLabel) {
        captureLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0)/2, self.view.frame.size.height - 100.0, 60.0, 60.0)];
        captureLabel.backgroundColor = [UIColor clearColor];
        captureLabel.userInteractionEnabled = true;
        captureLabel.layer.cornerRadius = captureLabel.frame.size.width / 2;
        captureLabel.layer.masksToBounds = true;
        captureLabel.layer.borderWidth = 4.0;
        captureLabel.layer.borderColor = [[UIColor redColor]  CGColor];
        [self.view addSubview:captureLabel];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captureImage)];
        [captureLabel addGestureRecognizer:tapGesture];
    }
}

- (void)addCancelButton
{
    if (!cancelLabel) {
        cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0)/2, 40.0, 40.0, 40.0)];
        cancelLabel.backgroundColor = [UIColor clearColor];
        cancelLabel.userInteractionEnabled = true;
        [self.view addSubview:cancelLabel];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
        [cancelLabel addGestureRecognizer:tapGesture];
        
        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 20*1.41, 3.0)];
        line1.backgroundColor = [UIColor redColor];
        CGAffineTransform transform1 = CGAffineTransformMakeTranslation(-10*1.41, 0);
        transform1 = CGAffineTransformRotate(transform1, 45*M_PI/180);
        transform1 = CGAffineTransformTranslate(transform1,10*1.41,0);
        line1.transform = transform1;
        [cancelLabel addSubview:line1];
        
        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 20*1.41, 3.0)];
        line2.backgroundColor = [UIColor redColor];
        CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-10*1.41, 0);
        transform2 = CGAffineTransformRotate(transform2, -45*M_PI/180);
        transform2 = CGAffineTransformTranslate(transform2,10*1.41,0);
        line2.transform = transform2;
        [cancelLabel addSubview:line2];
    }
}

- (void)configureCamera
{
    [self initializeCameraSession];
    [self addInputDeviceForCameraType:_cameraType];
    [self addImageOutput];
}

- (void)initializeCameraSession
{
    RELEASE_TO_NIL(self.previewLayer);
    RELEASE_TO_NIL(self.session);
    self.session = [[AVCaptureSession alloc] init];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CGRect rect = self.view.layer.bounds;
    
    self.previewLayer.bounds = rect;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(rect),CGRectGetMidY(rect));
    [self.view.layer addSublayer:self.previewLayer];
}

- (void)addInputDeviceForCameraType:(CameraType)camera
{
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        switch (_cameraType) {
            case CameraTypeFront:
                if (device.position == AVCaptureDevicePositionFront) {
                    self.currentCameraDevice = device;
                }
                break;
            case CameraTypeRear:
                if (device.position == AVCaptureDevicePositionBack) {
                    self.currentCameraDevice = device;
                }
                break;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:self.currentCameraDevice error:&error];
    [self.session removeInput:self.session.inputs.firstObject];
    if ([self.session canAddInput:inputDevice]) {
        [self.session addInput:inputDevice];
    }
}

- (void)addImageOutput
{
    self.stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    [self.stillImageOutPut setOutputSettings:outputSettings];
    if ([self.session canAddOutput:self.stillImageOutPut]) {
        [self.session addOutput:self.stillImageOutPut];
    }
}

- (AVCaptureVideoOrientation)getVideoOrienation
{
    AVCaptureVideoOrientation videoOrientation;
    switch ([[UIDevice currentDevice] orientation])
    {
        case UIDeviceOrientationPortrait:
            videoOrientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            videoOrientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            videoOrientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        default:
            videoOrientation = AVCaptureVideoOrientationPortrait;
    }
    return videoOrientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)captureImage
{
    AVCaptureConnection *videoConnection = [self.stillImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = [self getVideoOrienation];
    
    if (videoConnection) {
        [self.stillImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (!error) {
                CFDictionaryRef metadata = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                [self.delegate didCaptureImage:image];
            }
            else {
                DebugLog(@"%@", [TiUtils messageFromError:error]);
            }
            [self cancel];
        }];
    }
}

- (void)cancel
{
    [self stopSession];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)stopSession
{
    [self.session stopRunning];
    [self setTorchMode:AVCaptureTorchModeOff];
    if (self.session ) {
        
    }
}

- (void)showNativeControl:(BOOL)show
{
    shouldShowControl = show;
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = self.currentCameraDevice;
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if ([device isTorchModeSupported:torchMode]) {
            [device setTorchMode:torchMode];
        }
        [device unlockForConfiguration];
    }
}

- (AVCaptureTorchMode)torchMode
{
    return self.currentCameraDevice.torchMode;
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = self.currentCameraDevice;
    if ([device hasFlash]) {
        [device lockForConfiguration:nil];
        if ([device isFlashModeSupported:flashMode]) {
            [device setFlashMode:flashMode];
        }
        [device unlockForConfiguration];
    }
}

- (AVCaptureFlashMode)flashMode
{
    return self.currentCameraDevice.flashMode;
}

- (void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = self.currentCameraDevice;
    [device lockForConfiguration:nil];
    if ([device isFocusModeSupported:focusMode]) {
        [device setFocusMode:focusMode];
    }
    [device unlockForConfiguration];
}

- (AVCaptureFocusMode)focusMode
{
    return self.currentCameraDevice.focusMode;
}

- (void)setExposureMode:(AVCaptureExposureMode)exposureMode
{
    AVCaptureDevice *device = self.currentCameraDevice;
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:exposureMode]) {
        [device setExposureMode:exposureMode];
    }
    [device unlockForConfiguration];
}

- (AVCaptureExposureMode)exposureMode
{
    return self.currentCameraDevice.exposureMode;
}

- (void)setCameraType:(CameraType)cameraType
{
    _cameraType = cameraType;
    if (self.session) {
        // TO DO: Add animation while camera is switching
        [UIView animateWithDuration:.3 delay:0 options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        } completion:^(BOOL finished) {
            [self addInputDeviceForCameraType:_cameraType];
        }];
    }
}

- (CameraType)cameraType
{
    return _cameraType;
}

@end

