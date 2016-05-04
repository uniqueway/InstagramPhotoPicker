//
//  TWImageLoader.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhotoLoader.h"
#import <Photos/Photos.h>

@interface TWPhotoLoader ()

@property (strong, nonatomic) NSMutableArray *allPhotos;
@property (readwrite, copy, nonatomic) void(^loadBlock)(NSArray *photos, NSError *error);

@end

@implementation TWPhotoLoader

+ (TWPhotoLoader *)sharedLoader {
    static TWPhotoLoader *loader;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        loader = [[TWPhotoLoader alloc] init];
    });
    return loader;
}

+ (void)loadAllPhotos:(void (^)(NSArray *photos, NSError *error))completion {

    if ([TWPhotoLoader sharedLoader].allPhotos.count > 0) {
        if (completion) {
            completion([TWPhotoLoader sharedLoader].allPhotos, nil);
        }
    }else {
        [[TWPhotoLoader sharedLoader] setLoadBlock:completion];
        [[TWPhotoLoader sharedLoader] startLoading];
    }
}

- (void)startLoading {
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"modificationDate" ascending:YES]];
    PHFetchResult *fetchresults = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:options];
    [fetchresults enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([asset isKindOfClass:[PHAsset class]]) {
            TWPhoto *photo = [TWPhoto new];
            photo.asset = asset;
            [self.allPhotos insertObject:photo atIndex:0];
        }
    }];
    if (self.loadBlock) {
        self.loadBlock(self.allPhotos, nil);
    }
}

- (NSMutableArray *)allPhotos {
    if (_allPhotos == nil) {
        _allPhotos = [NSMutableArray array];
    }
    return _allPhotos;
}

@end
