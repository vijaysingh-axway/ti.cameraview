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

#pragma mark Lifecycle

- (id)_initWithPageContext:(id<TiEvaluator>)context
{
    if (self = [super _initWithPageContext:context]) {
        saveToRoll = NO;
    }
    
    return self;
}

#pragma mark Public APIs

- (id)createCamera:(id)args
{
    // FIXME: This has to return a proxy, e.g. TiCameraviewCameraProxy and won't work right now.
    
    ENSURE_SINGLE_ARG_OR_NIL(args,NSDictionary);

    cameraViewController = [[TiCameraViewController alloc] init];
    cameraViewController.delegate = self;

    if (args != nil) {
        [self callbackSetup:args];

        saveToRoll = [TiUtils boolValue:@"saveToPhotoGallery" properties:args def:NO];

        id showControl = [args objectForKey:@"showControl"];
        id torchMode = [args objectForKey:@"torchMode"];
        id flashMode = [args objectForKey:@"flashMode"];
        id cameraType = [args objectForKey:@"cameraType"];

        if (showControl) {
            [self showNativeControl:showControl];
        }
        
        if (torchMode) {
            [self setTorchMode:torchMode];
        }
        
        if (flashMode) {
            [self setFlashMode:flashMode];
        }
        
        if (cameraType) {
            [self setCameraType:cameraType];
        }
    }
}

- (void)open:(id)args
{
    ENSURE_UI_THREAD(open, args);

    [[TiApp app] showModalController:cameraViewController animated:true];
}

- (void)add:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, TiViewProxy);
    ENSURE_UI_THREAD(add, args);

    if ((cameraViewController != nil) && [cameraViewController isViewLoaded]) {
        TiViewProxy *viewProxy = args;
        UIView *view = [viewProxy view];
        
        ApplyConstraintToViewWithBounds([viewProxy layoutProperties], (TiUIView *)view, [cameraViewController.view bounds]);
        
        [viewProxy windowWillOpen];
        [cameraViewController.view addSubview:view];
        [viewProxy windowDidOpen];
    } else {
        DebugLog(@"Camera creation or camera opening failed");
    }
}

- (void)captureImage:(id)args
{
    ENSURE_UI_THREAD(captureImage, args);

    if ((cameraViewController != nil) && [cameraViewController isViewLoaded]) {
        [cameraViewController captureImage];
    } else {
        DebugLog(@"Camera creation or camera opening failed");
    }
}

- (void)dismiss:(__unused id)unused
{
    ENSURE_UI_THREAD(dismiss, unused);

    if (cameraViewController != nil) {
        [cameraViewController cancel];
    }
}

- (void)showNativeControl:(NSNumber *)showNativeControl
{
    if (cameraViewController != nil) {
        [cameraViewController showNativeControl:[TiUtils boolValue:showNativeControl def:NO]];
    }
}

- (void)setTorchMode:(NSNumber *)torchMode
{
    ENSURE_UI_THREAD(setTorchMode, torchMode);
    
    if (cameraViewController != nil) {
        [cameraViewController setTorchMode:[TiUtils intValue:torchMode]];
    }
}
- (NSNumber *)torchMode
{
    return NUMINT(cameraViewController.torchMode);
}

- (void)setFlashMode:(NSNumber *)flashMode
{
    ENSURE_UI_THREAD(setFlashMode, flashMode);
    
    if (cameraViewController != nil) {
        [cameraViewController setFlashMode:[TiUtils intValue:flashMode]];
    }
}

- (NSNumber *)flashMode
{
    return NUMINT([cameraViewController flashMode]);
}

- (void)setFocusMode:(id)focusMode
{
    ENSURE_UI_THREAD(setFocusMode, focusMode);
    
    if (cameraViewController != nil) {
        [cameraViewController setFocusMode:[TiUtils intValue:focusMode]];
    }
}

- (NSNumber *)focusMode
{
    return NUMINT(cameraViewController.focusMode);
}

- (void)setExposureMode:(NSNumber *)exposureMode
{
    ENSURE_UI_THREAD(setExposureMode, exposureMode);
    
    if (cameraViewController != nil) {
        [cameraViewController setExposureMode:[TiUtils intValue:exposureMode]];
    }
}

- (NSNumber *)exposureMode
{
    return NUMINT(cameraViewController.exposureMode);
}

- (void)setCameraType:(NSNumber *)cameraType
{
    ENSURE_UI_THREAD(setCameraType, cameraType);
    
    if (cameraViewController != nil) {
        [cameraViewController setCameraType:[TiUtils intValue:cameraType]];
    }
}

- (NSNumber *)cameraType
{
    return NUMINT([cameraViewController cameraType]);
}

#pragma Private APIs

- (void)callbackSetup:(NSDictionary *)args
{
    // FIXME: Unused
    __unused id save = [args objectForKey:@"saveToPhotoGallery"];

    successCallback = [args objectForKey:@"success"];
    ENSURE_TYPE_OR_NIL(successCallback, KrollCallback);
    
    errorCallback = [args objectForKey:@"error"];
    ENSURE_TYPE_OR_NIL(errorCallback, KrollCallback);
    
    cancelCallback = [args objectForKey:@"cancel"];
    ENSURE_TYPE_OR_NIL(cancelCallback, KrollCallback);
}

-(void)dispatchCallback:(NSArray*)args
{
    @autoreleasepool {
        NSString *type = [args objectAtIndex:0];
        id object = [args objectAtIndex:1];
        id listener = [args objectAtIndex:2];
        [NSThread sleepForTimeInterval:0.5];
        [self _fireEventToListener:type withObject:object listener:listener thisObject:nil];
    }
    
#ifndef TI_USE_KROLL_THREAD
    KrollContext *krollContext = [self.pageContext krollContext];
    [krollContext forceGarbageCollectNow];
#endif
}

-(void)sendPickerSuccess:(id)event
{
    id listener = successCallback;

    if (listener != nil) {
#ifdef TI_USE_KROLL_THREAD
        [NSThread detachNewThreadSelector:@selector(dispatchCallback:) toTarget:self withObject:[NSArray arrayWithObjects:@"success",event,listener,nil]];
#else
        [self dispatchCallback:@[@"success",event,listener]];
#endif
    }
}

#pragma TiImageCaptureDelegate methods

- (void)didCaptureImage:(UIImage *)image
{
    UIImage *resultImage = [TiUtils adjustRotation:image];

    TiBlob *media = [[TiBlob alloc] _initWithPageContext:[self pageContext]];
    [media setImage:resultImage];
    
    if (saveToRoll) {
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, NULL);
    }
    
    NSMutableDictionary *dictionary = [TiUtils dictionaryWithCode:0 message:nil];
    [dictionary setObject:@"image/jpeg" forKey:@"mediaType"];
    [dictionary setObject:media forKey:@"media"];
    
    [self sendPickerSuccess:dictionary];
    cameraViewController.delegate = nil;
}

#pragma mark Constants

MAKE_SYSTEM_PROP(TORCH_MODE_OFF,AVCaptureTorchModeOff);
MAKE_SYSTEM_PROP(TORCH_MODE_ON,AVCaptureTorchModeOn);
MAKE_SYSTEM_PROP(TORCH_MODE_AUTO,AVCaptureTorchModeAuto);

MAKE_SYSTEM_PROP(FLASH_MODE_OFF,AVCaptureFlashModeOff);
MAKE_SYSTEM_PROP(FLASH_MODE_ON,AVCaptureFlashModeOn);
MAKE_SYSTEM_PROP(FLASH_MODE_AUTO,AVCaptureFlashModeAuto);

MAKE_SYSTEM_PROP(FOCUS_MODE_LOCKED,AVCaptureFocusModeLocked);
MAKE_SYSTEM_PROP(FOCUS_MODE_AUTO_FOCUS,AVCaptureFocusModeAutoFocus);
MAKE_SYSTEM_PROP(FOCUS_MODE_CONTINUOUS_AUTO_FOCUS,AVCaptureFocusModeContinuousAutoFocus);

MAKE_SYSTEM_PROP(EXPOSURE_MODE_LOCKED, AVCaptureExposureModeLocked);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_AUTO_EXPOSE, AVCaptureExposureModeAutoExpose);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_CONTINUOUS_AUTO_EXPOSE, AVCaptureExposureModeContinuousAutoExposure);
MAKE_SYSTEM_PROP(EXPOSURE_MODE_CUSTOM, AVCaptureExposureModeCustom);

MAKE_SYSTEM_PROP(CAMERA_TYPE_FRONT,CameraTypeFront);
MAKE_SYSTEM_PROP(CAMERA_TYPE_REAR,CameraTypeRear);
@end
