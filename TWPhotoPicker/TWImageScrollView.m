//
//  TWImageScrollView.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "TWImageScrollView.h"
#import "IFVideoCamera.h"
#define rad(angle) ((angle) / 180.0 * M_PI)

@interface TWImageScrollView ()<UIScrollViewDelegate,IFVideoCameraDelegate>
{
    CGSize _imageSize;
}
@property (strong, nonatomic) GPUImageView *imageView;

@end

@implementation TWImageScrollView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = NO;
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.alwaysBounceHorizontal = YES;
        self.alwaysBounceVertical = YES;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        self.videoCamera = [[IFVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:AVCaptureDevicePositionBack highVideoQuality:YES];
        
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // center the zoom view as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
    self.imageView.frame = frameToCenter;
}

/**
 *  cropping image not just snapshot , inpired by https://github.com/gekitz/GKImagePicker
 *
 *  @return image cropped
 */
- (UIImage *)capture
{
    UIImage *image = [self.videoCamera getCurrentImage];
    CGRect visibleRect = [self _calcVisibleRectForCropArea:image.size];//caculate visible rect for crop

    CGAffineTransform rectTransform = [self _orientationTransformedRectOfImage:image];//if need rotate caculate
    visibleRect = CGRectApplyAffineTransform(visibleRect, rectTransform);

    CGImageRef ref = CGImageCreateWithImageInRect([image CGImage], visibleRect);//crop
    UIImage* cropped = [[UIImage alloc] initWithCGImage:ref scale:image.scale orientation:image.imageOrientation] ;
    CGImageRelease(ref);
    ref = NULL;
    return cropped;
//    return [self.videoCamera getCurrentImage];
}


static CGRect TWScaleRect(CGRect rect, CGFloat scale)
{
    return CGRectMake(rect.origin.x * scale, rect.origin.y * scale, rect.size.width * scale, rect.size.height * scale);
}


-(CGRect)_calcVisibleRectForCropArea:(CGSize)size {
    CGFloat sizeScale = size.width / self.frame.size.width;
    sizeScale *= self.zoomScale;
    CGRect visibleRect = [self convertRect:self.bounds toView:self.imageView];
    return visibleRect = TWScaleRect(visibleRect, sizeScale);
}

- (CGAffineTransform)_orientationTransformedRectOfImage:(UIImage *)img
{
    CGAffineTransform rectTransform;
    switch (img.imageOrientation)
    {
        case UIImageOrientationLeft:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -img.size.height);
            break;
        case UIImageOrientationRight:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -img.size.width, 0);
            break;
        case UIImageOrientationDown:
            rectTransform = CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -img.size.width, -img.size.height);
            break;
        default:
            rectTransform = CGAffineTransformIdentity;
    };
    
    return CGAffineTransformScale(rectTransform, img.scale, img.scale);
}


- (void)displayImage:(UIImage *)image
{
    // clear the previous image
    [self.imageView removeFromSuperview];
    [self.videoCamera cancelAlbumPhotoAndGoBackToNormal];
    self.videoCamera.rawImage = image;
    self.videoCamera.delegate = self;

    // reset our zoomScale to 1.0 before doing any further calculations
    self.zoomScale = 1.0;
    
    CGRect frame = self.imageView.frame;
    if (image.size.height > image.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = (self.bounds.size.width / image.size.width) * image.size.height;
    } else {
        frame.size.height = self.bounds.size.height;
        frame.size.width = (self.bounds.size.height / image.size.height) * image.size.width;
    }
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    frame = CGRectMake(0, 0, width, width);
    [self.videoCamera resetSize:frame.size];
    self.imageView = self.videoCamera.gpuImageView;
    self.imageView.frame = frame;
    self.imageView.clipsToBounds = NO;
    self.imageView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.imageView];
    [self configureForImageSize:self.imageView.bounds.size];
}

- (void)configureForImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    self.contentSize = imageSize;
    
    //to center
    if (imageSize.width > imageSize.height) {
        self.contentOffset = CGPointMake(imageSize.width/4, 0);
    } else if (imageSize.width < imageSize.height) {
        self.contentOffset = CGPointMake(0, imageSize.height/4);
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    self.zoomScale = self.minimumZoomScale;
}

- (void)setMaxMinZoomScalesForCurrentBounds
{
    self.minimumZoomScale = 1.0;
    self.maximumZoomScale = 2.0;
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - IFVideoCameraDelegate

- (void)IFVideoCameraWillStartCaptureStillImage:(IFVideoCamera *)videoCamera {
    
}

- (void)IFVideoCameraDidFinishCaptureStillImage:(IFVideoCamera *)videoCamera {
    
}

- (void)IFVideoCameraDidSaveStillImage:(IFVideoCamera *)videoCamera {
    
}

- (BOOL)canIFVideoCameraStartRecordingMovie:(IFVideoCamera *)videoCamera {
    return NO;
}

- (void)IFVideoCameraWillStartProcessingMovie:(IFVideoCamera *)videoCamera {
    
}

- (void)IFVideoCameraDidFinishProcessingMovie:(IFVideoCamera *)videoCamera {
    
}

@end
