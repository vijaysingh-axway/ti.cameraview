/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 20017-present by Axway Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 *
 */

#import "TiCameraViewController.h"
#import "TiApp.h"

#import <ImageIO/ImageIO.h>

@interface TiCameraViewController ()

@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureDevice *currentCameraDevice;
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutPut;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation TiCameraViewController

- (id)initWithDelegate:(id<TiImageCaptureDelegate>)delegate
{
  if (self = [super init]) {
    _cameraType = TiCameraTypeRear;
    _shouldShowControl = NO;
    _delegate = delegate;
  }

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self configureCamera];
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];

  if (_shouldShowControl) {
    [self addCaptureButton];
    [self addCancelButton];
  }
  [self.session startRunning];
}

- (void)dealloc
{
  [[self session] stopRunning];
  self.session = nil;
  self.previewLayer = nil;
  self.stillImageOutPut = nil;

  _captureLabel = nil;
  _cancelLabel = nil;
}

- (void)addCaptureButton
{
  if (_captureLabel == nil) {
    _captureLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0) / 2, self.view.frame.size.height - 100.0, 60.0, 60.0)];
    _captureLabel.backgroundColor = [UIColor clearColor];
    _captureLabel.userInteractionEnabled = true;
    _captureLabel.layer.cornerRadius = _captureLabel.frame.size.width / 2;
    _captureLabel.layer.masksToBounds = true;
    _captureLabel.layer.borderWidth = 4.0;
    _captureLabel.layer.borderColor = [[UIColor redColor] CGColor];
    [self.view addSubview:_captureLabel];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(captureImage)];
    [_captureLabel addGestureRecognizer:tapGesture];
  }
}

- (void)addCancelButton
{
  if (_cancelLabel == nil) {

    // FIXME: Use Autolayout

    _cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0) / 2, 40.0, 40.0, 40.0)];
    _cancelLabel.backgroundColor = [UIColor clearColor];
    _cancelLabel.userInteractionEnabled = true;
    [self.view addSubview:_cancelLabel];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel)];
    [_cancelLabel addGestureRecognizer:tapGesture];

    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 20 * 1.41, 3.0)];
    line1.backgroundColor = [UIColor redColor];
    CGAffineTransform transform1 = CGAffineTransformMakeTranslation(-10 * 1.41, 0);
    transform1 = CGAffineTransformRotate(transform1, 45 * M_PI / 180);
    transform1 = CGAffineTransformTranslate(transform1, 10 * 1.41, 0);
    line1.transform = transform1;
    [_cancelLabel addSubview:line1];

    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(10, 30, 20 * 1.41, 3.0)];
    line2.backgroundColor = [UIColor redColor];
    CGAffineTransform transform2 = CGAffineTransformMakeTranslation(-10 * 1.41, 0);
    transform2 = CGAffineTransformRotate(transform2, -45 * M_PI / 180);
    transform2 = CGAffineTransformTranslate(transform2, 10 * 1.41, 0);
    line2.transform = transform2;
    [_cancelLabel addSubview:line2];
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
  CGRect rect = self.view.layer.bounds;

  self.session = [[AVCaptureSession alloc] init];
  self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
  self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

  self.previewLayer.bounds = rect;
  self.previewLayer.position = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
  [self.view.layer addSublayer:self.previewLayer];
}

- (void)addInputDeviceForCameraType:(TiCameraType)camera
{
  for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
    switch (_cameraType) {
    case TiCameraTypeFront:
      if (device.position == AVCaptureDevicePositionFront) {
        self.currentCameraDevice = device;
      }
      break;
    case TiCameraTypeRear:
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
  NSDictionary *outputSettings = @{ AVVideoCodecKey : AVVideoCodecJPEG };

  self.stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
  [self.stillImageOutPut setOutputSettings:outputSettings];

  if ([self.session canAddOutput:self.stillImageOutPut]) {
    [self.session addOutput:self.stillImageOutPut];
  }
}

- (AVCaptureVideoOrientation)getVideoOrienation
{
  AVCaptureVideoOrientation videoOrientation;
  switch ([[UIDevice currentDevice] orientation]) {
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

  if (videoConnection != nil) {
    [self.stillImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection
                                                       completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                                                         if (!error) {
                                                           NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                                                           UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                           [[self delegate] didCaptureImage:image];
                                                         } else {
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

  if (self.session != nil) {
  }
}

- (void)showNativeControl:(BOOL)showNativeControl
{
  _shouldShowControl = showNativeControl;
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

- (void)setCameraType:(TiCameraType)cameraType
{
  _cameraType = cameraType;

  if (self.session) {
    // TO DO: Add animation while camera is switching
    [UIView animateWithDuration:.3
        delay:0
        options:UIViewAnimationOptionTransitionFlipFromLeft
        animations:^{
        }
        completion:^(BOOL finished) {
          [self addInputDeviceForCameraType:_cameraType];
        }];
  }
}

- (TiCameraType)cameraType
{
  return _cameraType;
}

@end
