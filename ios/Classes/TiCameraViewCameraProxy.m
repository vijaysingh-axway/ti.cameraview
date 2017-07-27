/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCameraViewCameraProxy.h"
#import "TiApp.h"

@implementation TiCameraViewCameraProxy

- (TiCameraViewController *)cameraViewController
{
    if (_cameraViewController == nil) {
        _cameraViewController = [[TiCameraViewController alloc] initWithDelegate:self];
        
        [self setupCallbacks];
    }
    
    return _cameraViewController;
}

- (void)open:(id)args
{
    ENSURE_UI_THREAD(open, args);
    
    [[TiApp app] showModalController:[self cameraViewController]
                            animated:true];
}

- (void)close:(__unused id)unused
{
    ENSURE_UI_THREAD(close, unused);
    
    [[self cameraViewController] cancel];
}

- (void)add:(id)args
{
    ENSURE_SINGLE_ARG_OR_NIL(args, TiViewProxy);
    ENSURE_UI_THREAD(add, args);

    if ([[self cameraViewController] isViewLoaded]) {
        TiViewProxy *viewProxy = args;
        UIView *view = [viewProxy view];

        ApplyConstraintToViewWithBounds([viewProxy layoutProperties], (TiUIView *)view, [[[self cameraViewController] view] bounds]);

        [viewProxy windowWillOpen];
        [[[self cameraViewController] view] addSubview:view];
        [viewProxy windowDidOpen];
    } else {
        DebugLog(@"Camera creation or camera opening failed");
    }
}

- (void)captureImage:(id)args
{
    ENSURE_UI_THREAD(captureImage, args);
    
    if ([[self cameraViewController] isViewLoaded]) {
        [[self cameraViewController] captureImage];
    } else {
        DebugLog(@"[ERROR] Camera creation or camera opening failed");
    }
}

- (void)setShowNativeControl:(NSNumber *)showNativeControl
{
    ENSURE_UI_THREAD(setShowNativeControl, showNativeControl);

    [[self cameraViewController] showNativeControl:[TiUtils boolValue:showNativeControl def:NO]];
}

- (void)setTorchMode:(NSNumber *)torchMode
{
    ENSURE_UI_THREAD(setTorchMode, torchMode);
    
    [[self cameraViewController] setTorchMode:[TiUtils intValue:torchMode]];
}
- (NSNumber *)torchMode
{
    return NUMINT([[self cameraViewController] torchMode]);
}

- (void)setFlashMode:(NSNumber *)flashMode
{
    ENSURE_UI_THREAD(setFlashMode, flashMode);
    
    [[self cameraViewController] setFlashMode:[TiUtils intValue:flashMode]];
}

- (NSNumber *)flashMode
{
    return NUMINT([[self cameraViewController] flashMode]);
}

- (void)setFocusMode:(id)focusMode
{
    ENSURE_UI_THREAD(setFocusMode, focusMode);
    
    [[self cameraViewController] setFocusMode:[TiUtils intValue:focusMode]];
}

- (NSNumber *)focusMode
{
    return NUMINT([[self cameraViewController] focusMode]);
}

- (void)setExposureMode:(NSNumber *)exposureMode
{
    ENSURE_UI_THREAD(setExposureMode, exposureMode);
    
    [[self cameraViewController] setExposureMode:[TiUtils intValue:exposureMode]];
}

- (NSNumber *)exposureMode
{
    return NUMINT([[self cameraViewController] exposureMode]);
}

- (void)setCameraType:(NSNumber *)cameraType
{
    ENSURE_UI_THREAD(setCameraType, cameraType);
    
    [[self cameraViewController] setCameraType:[TiUtils intValue:cameraType]];
}

- (NSNumber *)cameraType
{
    return NUMINT([[self cameraViewController] cameraType]);
}

- (void)setSaveToPhotoGallery:(NSNumber *)saveToPhotoGallery
{
    _saveToPhotoGallery = [saveToPhotoGallery boolValue];
}

- (NSNumber *)saveToPhotoGallery
{
    return NUMBOOL(_saveToPhotoGallery);
}

#pragma mark Private API's
    
    
- (void)setupCallbacks
{
    _successCallback = [self valueForKey:@"success"];
    ENSURE_TYPE_OR_NIL(_successCallback, KrollCallback);
    
    _errorCallback = [self valueForKey:@"error"];
    ENSURE_TYPE_OR_NIL(_errorCallback, KrollCallback);
    
    _cancelCallback = [self valueForKey:@"cancel"];
    ENSURE_TYPE_OR_NIL(_cancelCallback, KrollCallback);
}

- (void)dispatchCallback:(NSArray *)args
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

- (void)sendPickerSuccess:(id)event
{
    if (_successCallback != nil) {
#ifdef TI_USE_KROLL_THREAD
        [NSThread detachNewThreadSelector:@selector(dispatchCallback:)
                                 toTarget:self
                               withObject:@[@"success", event, _successCallback]];
#else
        [self dispatchCallback:@[@"success", event, _successCallback]];
#endif
    }
}

#pragma TiImageCaptureDelegate methods

- (void)didCaptureImage:(UIImage *)image
{
    UIImage *resultImage = [TiUtils adjustRotation:image];
    
    TiBlob *media = [[TiBlob alloc] _initWithPageContext:[self pageContext]];
    [media setImage:resultImage];
    
    if (_saveToPhotoGallery) {
        UIImageWriteToSavedPhotosAlbum(resultImage, nil, nil, NULL);
    }
    
    NSMutableDictionary *dictionary = [TiUtils dictionaryWithCode:0 message:nil];
    [dictionary setObject:@"image/jpeg" forKey:@"mediaType"];
    [dictionary setObject:media forKey:@"media"];
    
    [self sendPickerSuccess:dictionary];
}

@end
