//
//  TWPhoto.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhoto.h"



@implementation TWPhoto

- (void)loadThumbnailImageCompletion:(void (^)(TWPhoto *))completion {
    if (self.thumbnailImage) {
        if (completion) {
            completion(self);
        }
    }else {
        CGFloat colum = 4.0, spacing = 2.0;
        CGFloat value = floorf(([self screenSize].width - (colum - 1) * spacing) / colum);
        [self loadImageWithAsset:self.asset targetSize:CGSizeMake(value, value) completion:^(UIImage *result) {
            self.thumbnailImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadPortraitImageCompletion:(void (^)(TWPhoto *))completion {
    if (self.originalImage) {
        if (completion) {
            completion(self);
        }
    }else {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGSize size = CGSizeMake(1500, 1500);
        [self loadImageWithAsset:self.asset targetSize:size completion:^(UIImage *result) {
            self.originalImage = result;
            if (completion) {
                completion(self);
            }
        }];
    }
}

- (void)loadImageWithAsset:(PHAsset *)asset targetSize:(CGSize)targetSize completion:(void(^)(UIImage *result))completion{
    PHImageManager *imageManager = [PHImageManager defaultManager];
    PHImageRequestOptions *options = [PHImageRequestOptions new];
    options.networkAccessAllowed = YES;
    options.resizeMode =  PHImageRequestOptionsResizeModeFast;
    options.deliveryMode =  PHImageRequestOptionsDeliveryModeHighQualityFormat;
    options.synchronous = NO;
    [imageManager requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(result);
            }
        });
    }];
}

- (CGSize)screenSize {
    return [UIScreen mainScreen].bounds.size;
}

@end
