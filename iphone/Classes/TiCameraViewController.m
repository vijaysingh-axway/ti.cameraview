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

-(void)viewDidLoad
{
}

-(void)viewWillAppear:(BOOL)animated
{
    [self openCameraWithArgs:nil];
    [self addCaptureButton];
    [self addCancelButton];
    [self.session startRunning];
}
-(void)dealloc
{
    RELEASE_TO_NIL(self.session);
    RELEASE_TO_NIL(self.previewLayer);
    RELEASE_TO_NIL(self.stillImageOutPut);
    [super dealloc];
}

-(void)addCaptureButton
{
    UILabel *captureLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0)/2, self.view.frame.size.height - 100.0, 60.0, 60.0)];
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

-(void)addCancelButton
{
    UILabel *cancelLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.view.frame.size.width - 60.0)/2, 40.0, 40.0, 40.0)];
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

-(void)openCameraWithArgs:(id)args
{
    self.session = [[AVCaptureSession alloc] init];
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    CGRect rect = self.view.layer.bounds;
    
    self.previewLayer.bounds = rect;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(rect),CGRectGetMidY(rect));
    [self.view.layer addSublayer:self.previewLayer];
    
    for (AVCaptureDevice *device in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo])
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            self.currentCameraDevice = device;
        }
        else
        {
            // self.currentCameraDevice = device;
        }
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:self.currentCameraDevice error:&error];
    if ([self.session canAddInput:inputDevice])
    {
        [self.session addInput:inputDevice];
    }
    
    self.stillImageOutPut = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    [self.stillImageOutPut setOutputSettings:outputSettings];
    if ([self.session canAddOutput:self.stillImageOutPut])
    {
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

-(BOOL)shouldAutorotate
{
    return YES;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(void)captureImage
{
    AVCaptureConnection *videoConnection = [self.stillImageOutPut connectionWithMediaType:AVMediaTypeVideo];
    videoConnection.videoOrientation = [self getVideoOrienation];
    
    if (videoConnection)
    {
        [self.stillImageOutPut captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            CFDictionaryRef metadata = CMGetAttachment(imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [[UIImage alloc] initWithData:imageData];
            [self.delegate didCaptureImage:image];
            [self dismissViewControllerAnimated:YES completion:nil];
            //NSLog(image);
        }];
    }
    [self setTorchMode:AVCaptureTorchModeOff];
}

-(void)cancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        if ([device isTorchModeSupported:torchMode])
        {
            [device setTorchMode:torchMode];
        }
        [device unlockForConfiguration];
    }
}

-(void)setFlashMode:(AVCaptureFlashMode)flashMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasFlash])
    {
        [device lockForConfiguration:nil];
        if ([device isFlashModeSupported:flashMode])
        {
            [device setFlashMode:flashMode];
        }
        [device unlockForConfiguration];
    }
}

-(void)setFocusMode:(AVCaptureFocusMode)focusMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        if ([device isFocusModeSupported:focusMode])
        {
            [device setFocusMode:focusMode];
        }
        [device unlockForConfiguration];
}
@end

