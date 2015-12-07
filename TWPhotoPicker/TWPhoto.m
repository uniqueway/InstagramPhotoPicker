//
//  TWPhoto.m
//  Pods
//
//  Created by Emar on 4/30/15.
//
//

#import "TWPhoto.h"

static NSString * const IMAGE_SAVE_PATH = @"UNWIMAGE";

@implementation TWPhoto

- (UIImage *)thumbnailImage {
    if (self.asset) {
        return [UIImage imageWithCGImage:self.asset.thumbnail];
    } else {
        return [UIImage imageWithContentsOfFile:[self localPath:[NSString stringWithFormat:@"%@!s270",self.imageName]]];
    }
}

- (NSString *)localPath:(NSString *)imageName {
    NSArray *path          = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:IMAGE_SAVE_PATH];
    return [[imageDocPath stringByAppendingString:@"/"] stringByAppendingString:imageName];
}

- (UIImage *)originalImage {
    if (!_originalImage) {
        if (self.asset) {
            _originalImage = [UIImage imageWithCGImage:self.asset.defaultRepresentation.fullResolutionImage
                                                 scale:self.asset.defaultRepresentation.scale
                                           orientation:(UIImageOrientation)self.asset.defaultRepresentation.orientation];
        } else {
            _originalImage = [UIImage imageWithContentsOfFile:[self localPath:self.imageName]];
        }
    }
    return _originalImage;
}
@end
