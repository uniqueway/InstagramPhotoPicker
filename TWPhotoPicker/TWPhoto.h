

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface TWPhoto : NSObject

@property (nonatomic, strong) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) PHAsset *asset;

- (void)loadThumbnailImageCompletion:( void(^)(TWPhoto *photo) )completion;
- (void)loadPortraitImageCompletion:( void(^)(TWPhoto *photo) )completion;


@end
