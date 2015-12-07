

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TWPhoto : NSObject

@property (nonatomic, readonly) UIImage *thumbnailImage;
@property (nonatomic, strong) UIImage *originalImage;
@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) ALAsset *asset;

@end
