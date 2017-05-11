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

@implementation TiCameraviewModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"11297d48-f1a0-4690-af76-e8398f9a6900";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"ti.cameraview";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];

	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably

	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup

-(void)dealloc
{
	// release any resources that have been retained by the module
	[super dealloc];
    RELEASE_TO_NIL(cameraViewController);
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{
	if (count == 1 && [type isEqualToString:@"my_event"])
	{
		// the first (of potentially many) listener is being added
		// for event named 'my_event'
	}
}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{
	if (count == 0 && [type isEqualToString:@"my_event"])
	{
		// the last listener called for event named 'my_event' has
		// been removed, we can optionally clean up any resources
		// since no body is listening at this point for that event
	}
}

#pragma Public APIs

-(id)example:(id)args
{
	// example method
	return @"hello world";
}

-(id)exampleProp
{
	// example property getter
	return @"hello world";
}

-(void)setExampleProp:(id)value
{
	// example property setter
}

-(void)openCamera:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args,NSDictionary);
    if (![NSThread isMainThread])
    {
        TiThreadPerformOnMainThread(^{[self openCamera:args];},NO);
        return;
    }
    [self showCamera:args];
}

-(void)showCamera:(id)args
{
    saveToRoll = false;
    cameraViewController = [[TiCameraViewController alloc] init];
    cameraViewController.delegate = self;
    [[TiApp app] showModalController:cameraViewController animated:true];
    if (args != nil)
    {
        [self callbackSetup:args];
        saveToRoll = [TiUtils boolValue:@"saveToPhotoGallery" properties:args def:NO];
        
        id torchMode = [args objectForKey:@"torchMode"];
        if (torchMode)
        {
            [self setTorchMode:torchMode];
        }
        id flashMode = [args objectForKey:@"flashMode"];
        if (flashMode)
        {
            [self setFlashMode:flashMode];
        }
    }
}

-(void)setTorchMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setTorchMode,value);
    
    if (cameraViewController!=nil)
    {
        [cameraViewController setTorchMode:[TiUtils intValue:value]];
    }
}

-(void)setFlashMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setFlashMode,value);
    
    if (cameraViewController!=nil)
    {
        [cameraViewController setFlashMode:[TiUtils intValue:value]];
    }
}

-(void)setFocushMode:(id)value
{
    ENSURE_SINGLE_ARG(value,NSNumber);
    ENSURE_UI_THREAD(setFocushMode,value);
    
    if (cameraViewController!=nil)
    {
        [cameraViewController setFocushMode:[TiUtils intValue:value]];
    }
}

-(void)callbackSetup:(NSDictionary *)args
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
    if (listener!=nil)
    {
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
    
    if (saveToRoll)
    {
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, NULL);
    }
    
    NSMutableDictionary *dictionary = [TiUtils dictionaryWithCode:0 message:nil];
    [dictionary setObject:@"image/jpeg" forKey:@"mediaType"];
    [dictionary setObject:media forKey:@"media"];
    
    [self sendPickerSuccess:dictionary];
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
@end
