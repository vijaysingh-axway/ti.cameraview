/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2014 by Appcelerator, Inc. All Rights Reserved.
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
#import "Constants.h"

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

-(void)startup
{
	[super startup];
}

- (void)shutdown:(id)sender
{
	[super shutdown:sender];
}

#pragma mark Cleanup

#pragma mark Internal Memory Management

- (void)didReceiveMemoryWarning:(NSNotification*)notification
{
	[super didReceiveMemoryWarning:notification];
}

#pragma Public APIs

- (id)createCamera:(id)args
{
    if (self = [super init]) {
        ENSURE_SINGLE_ARG_OR_NIL(args,NSDictionary);
        saveToRoll = false;
        cameraViewController.delegate = nil;
        RELEASE_TO_NIL(cameraViewController);
        cameraViewController = [[TiCameraViewController alloc] init];
        cameraViewController.delegate = self;
        if (args != nil) {
            [self callbackSetup:args];
            saveToRoll = [TiUtils boolValue:@"saveToPhotoGallery" properties:args def:NO];
            
            id showControl = [args objectForKey:@"showControl"];
            if (showControl) {
                [self showNativeControl:showControl];
            }
            
            id torchMode = [args objectForKey:@"torchMode"];
            if (torchMode) {
                [self setTorchMode:torchMode];
            }
            
            id flashMode = [args objectForKey:@"flashMode"];
            if (flashMode) {
                [self setFlashMode:flashMode];
            }
            
            id cameraType = [args objectForKey:@"cameraType"];
            if (cameraType) {
                [self setCameraType:cameraType];
            }
        }
        return self;
    }
}

- (void)open:(id)args
{
    ENSURE_UI_THREAD(open, args);
    [[TiApp app] showModalController:cameraViewController animated:true];
}

- (void)add:(id)arg
{
    ENSURE_SINGLE_ARG_OR_NIL(arg, TiViewProxy);
    ENSURE_UI_THREAD(add,arg);
    if ((cameraViewController != nil) && [cameraViewController isViewLoaded]) {
        TiViewProxy *viewProxy = [arg retain];
        UIView *view = [viewProxy view];
        
        ApplyConstraintToViewWithBounds([viewProxy layoutProperties], (TiUIView *)view, [cameraViewController.view bounds]);
        
        [viewProxy windowWillOpen];
        [cameraViewController.view addSubview:view];
        [viewProxy windowDidOpen];
    } else {
        DebugLog(@"Camera creation or camera opening failed");
    }
}

- (void)captureImage:(id)arg
{
    ENSURE_UI_THREAD(captureImage, arg);
    if ((cameraViewController != nil) && [cameraViewController isViewLoaded]) {
        [cameraViewController captureImage];
    } else {
        DebugLog(@"Camera creation or camera opening failed");
    }
}

- (void)dismiss:(id)arg
{
    ENSURE_UI_THREAD(dismiss, arg);
    if (cameraViewController != nil) {
        [cameraViewController cancel];
    }
}

- (void)showNativeControl:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);    
    if (cameraViewController != nil) {
        [cameraViewController showNativeControl:[TiUtils boolValue:value def:NO]];
    }
}

- (void)setTorchMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setTorchMode,value);
    
    if (cameraViewController != nil) {
        [cameraViewController setTorchMode:[TiUtils intValue:value]];
    }
}
- (NSNumber *)torchMode
{
    return NUMINT(cameraViewController.torchMode);
}

- (void)setFlashMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setFlashMode,value);
    
    if (cameraViewController != nil) {
        [cameraViewController setFlashMode:[TiUtils intValue:value]];
    }
}

- (NSNumber *)flashMode
{
    return NUMINT(cameraViewController.flashMode);
}

- (void)setFocushMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setFocushMode,value);
    
    if (cameraViewController != nil) {
        [cameraViewController setFocusMode:[TiUtils intValue:value]];
    }
}

- (NSNumber *)focusMode
{
    return NUMINT(cameraViewController.focusMode);
}

- (void)setCameraType:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setCameraType,value);
    
    if (cameraViewController != nil) {
        [cameraViewController setCameraType:[TiUtils intValue:value]];
    }
}

- (CameraType)cameraType
{
    return NUMINT(cameraViewController.cameraType);
}

#pragma Private APIs

- (void)callbackSetup:(NSDictionary *)args
{
    id save = [args objectForKey:@"saveToPhotoGallery"];
    successCallback = [args objectForKey:@"success"];
    ENSURE_TYPE_OR_NIL(successCallback,KrollCallback);
    [successCallback retain];
    
    errorCallback = [args objectForKey:@"error"];
    ENSURE_TYPE_OR_NIL(errorCallback,KrollCallback);
    [errorCallback retain];
        
    cancelCallback = [args objectForKey:@"cancel"];
    ENSURE_TYPE_OR_NIL(cancelCallback,KrollCallback);
    [cancelCallback retain];
}

-(void)dispatchCallback:(NSArray*)args
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSString *type = [args objectAtIndex:0];
    id object = [args objectAtIndex:1];
    id listener = [args objectAtIndex:2];
    [NSThread sleepForTimeInterval:0.5];
    [self _fireEventToListener:type withObject:object listener:listener thisObject:nil];
    [pool release];
    
#ifndef TI_USE_KROLL_THREAD
    KrollContext *krollContext = [self.pageContext krollContext];
    [krollContext forceGarbageCollectNow];
#endif
}

-(void)sendPickerSuccess:(id)event
{
    id listener = [[successCallback retain] autorelease];
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

    TiBlob *media = [[[TiBlob alloc] _initWithPageContext:[self pageContext]] autorelease];
    [media setImage:resultImage];
    
    if (saveToRoll) {
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, NULL);
    }
    
    NSMutableDictionary *dictionary = [TiUtils dictionaryWithCode:0 message:nil];
    [dictionary setObject:@"image/jpeg" forKey:@"mediaType"];
    [dictionary setObject:media forKey:@"media"];
    
    [self sendPickerSuccess:dictionary];
    cameraViewController.delegate = nil;
    RELEASE_TO_NIL(cameraViewController);
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

MAKE_SYSTEM_PROP(CAMERA_TYPE_FRONT,CameraTypeFront);
MAKE_SYSTEM_PROP(CAMERA_TYPE_REAR,CameraTypeRear);
@end
