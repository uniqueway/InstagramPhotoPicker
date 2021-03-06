//
//  TWPhotoEditorViewController.m
//  Pods
//
//  Created by Madao on 11/6/15.
//
//

#import "TWPhotoEditorViewController.h"
#import "TWPhotoFilterCollectionViewCell.h"
#import "TWPhoto.h"
#import "TWImageScrollView.h"
#import "TWPhotoImageItem.h"
#import <SVProgressHUD.h>

#import <mach/mach_time.h>

#define SCREEN_WIDTH CGRectGetWidth([UIScreen mainScreen].bounds)
#define SCREEN_HEIGHT CGRectGetHeight([UIScreen mainScreen].bounds)
static CGFloat const NavigationBarHeight = 64;

@interface TWPhotoEditorViewController()<UICollectionViewDataSource, UICollectionViewDelegate,TWImageScrollViewDelegate>
@property (nonatomic, strong) NSMutableArray *list;
@property (nonatomic, strong) NSMutableArray *thumbnailImageList;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) UICollectionView *collectionView;
//@property (strong, nonatomic) UIView *imageListView;
@property (nonatomic, assign) BOOL isEdited;
@property (strong, nonatomic) TWImageScrollView *imageScrollView;
@property (nonatomic, assign) NSInteger currentType;
@property (nonatomic, strong) NSArray *filterList;
@property (nonatomic, strong) NSArray *filterNameList;
@property (strong, nonatomic) NSMutableArray *resultList;
@property (strong, nonatomic) UIButton *nextOrSubmitButton;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CALayer *maskLayer;

@end

@implementation TWPhotoEditorViewController
- (id)initWithPhotoList:(NSArray *)list crop:(cropBlock)crop {
    self              = [super init];
    self.currentType  = 0;
    self.cropBlock    = crop;
    self.list         = [list mutableCopy];
    self.filterList   = @[@(0),@(1),@(2),@(3),@(4)];
    self.filterNameList = @[@"normal", @"inkwell", @"earlybird", @"xproii", @"lomofi",@"hudson",@"toaster"];
//    self.filterList   = @[@"normal", @"amaro", @"rise", @"hudson", @"xproii", @"sierra", @"lomofi", @"earlybird", @"sutro", @"toaster", @"brannan", @"inkwell", @"walden", @"hefe", @"valencia", @"nashville", @"1977"];
    self.resultList   = [[NSMutableArray alloc] initWithCapacity:list.count];
    self.currentIndex = 0;
    self.view.backgroundColor = [UIColor blackColor];
    return self;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:YES];
    [self.view addSubview:self.topView];
    [self.view insertSubview:self.collectionView belowSubview:self.topView];
    [self loadCurrentImage];
    if (self.list.count > 1) {
        self.titleLabel.text = self.navigtationTitle;
    }

}

#pragma mark - TWImageScrollViewDelegate
- (void)contentDidEdit:(BOOL)flag {
    self.isEdited = flag;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.filterList count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TWPhotoFilterCollectionViewCell";
    TWPhotoFilterCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    NSString *filterName = [self.filterNameList objectAtIndex:indexPath.row];
    cell.title.text = filterName;
    filterName = [filterName stringByAppendingString:@".jpg"];
    cell.imageView.image = [UIImage imageNamed:filterName];
    cell.selected = [self.filterList[indexPath.row] integerValue] == self.currentType;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.isEdited = YES;
    NSInteger newType = [self.filterList[indexPath.row] integerValue];
    if (newType != self.currentType) {
        [[NSNotificationCenter defaultCenter] postNotificationName:TWPhotoEditorViewControllerNotification object:nil];
    }
    self.currentType  = newType;
    [self.imageScrollView switchFilter:self.currentType];
    [self.collectionView reloadData];
    if (indexPath.row != 0) {
        
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
//    [self toggleIndex:indexPath];
}


#pragma mark - Helper
- (void)loadCurrentImage {
    TWPhoto *photo = self.list[self.currentIndex];
    [photo loadPortraitImageCompletion:^(TWPhoto *photo) {
        [self.imageScrollView displayImage:photo.originalImage];
        self.currentType  = 0;
        [self.collectionView reloadData];
    }];
}


#pragma mark - event response


- (void)backAction {
    NSMutableArray *list = [@[] mutableCopy];
    for (NSDictionary *dict in self.resultList) {
        if (dict) {
            [list addObject:dict];
        }
    }
    if (self.cropBlock && list.count > 0) {
        self.cropBlock(list);
    }

    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextOrSubmitAction {
    BOOL isLast    = self.currentIndex == self.list.count-1;
    __weak __typeof__(self) weakSelf = self;
    NSInteger index = self.currentIndex;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block UIImage *image = weakSelf.imageScrollView.capture;
        TWPhoto *photo = weakSelf.list[index];
        NSString *url = photo.asset.localIdentifier;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.cropBlock && image && url) {
                if (self.currentType != 0) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:TWPhotoEditorUploadEditedImageNotification object:nil];
                }
                weakSelf.cropBlock(@[@{@"image":image,@"localIdentifier": url}]);
            }
            if (isLast) {
                weakSelf.list = nil;
                [self dismissViewControllerAnimated:YES completion:NULL];
                [SVProgressHUD dismiss];
            }
            image = nil;
        });

    });
    self.nextOrSubmitButton.enabled = NO;
    if (isLast) {
        [SVProgressHUD showWithStatus:@"正在处理中"];
    } else {
        self.currentIndex++;
        [self loadCurrentImage];
        NSString *title = @"下一张";
        if (self.currentIndex == self.list.count-1) {
            title = @"完成";
        }
        [self.nextOrSubmitButton setTitle:title forState:UIControlStateNormal];
        self.nextOrSubmitButton.enabled = YES;
        self.titleLabel.text = self.navigtationTitle;
    }
    
    
}
- (UIView *)topView {
    if (_topView == nil) {
        CGFloat handleHeight = 44;
        CGRect rect = CGRectMake(0, 20, SCREEN_WIDTH, SCREEN_WIDTH+handleHeight*2);
        self.topView = [[UIView alloc] initWithFrame:rect];
        self.topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
        self.topView.backgroundColor = [UIColor clearColor];
        self.topView.clipsToBounds = YES;
        
        rect = CGRectMake(0, 0, SCREEN_WIDTH, handleHeight);
        UIView *navView = [[UIView alloc] initWithFrame:rect];//26 29 33
        navView.backgroundColor = [UIColor colorWithRed:26.0/255 green:29.0/255 blue:33.0/255 alpha:1];
        [self.topView addSubview:navView];
        
        rect = CGRectMake(0, 0, 60, CGRectGetHeight(navView.bounds));
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        backBtn.frame = rect;
        backBtn.transform = CGAffineTransformMakeRotation(-M_PI_2);
        [backBtn setImage:[UIImage imageNamed:@"back.png"]
                 forState:UIControlStateNormal];
        [backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:backBtn];
        
        [navView addSubview:self.titleLabel];
        
        rect = CGRectMake(SCREEN_WIDTH-80, 0, 80, CGRectGetHeight(navView.bounds));
        self.nextOrSubmitButton = [[UIButton alloc] initWithFrame:rect];
        NSString *title = @"完成";
        if (self.list.count > 1) {
            title = @"下一张";
        }
        [self.nextOrSubmitButton setTitle:title forState:UIControlStateNormal];

        [self.nextOrSubmitButton.titleLabel setFont:[UIFont systemFontOfSize:14.0f]];
        [self.nextOrSubmitButton setTitleColor:[UIColor cyanColor] forState:UIControlStateNormal];
        [self.nextOrSubmitButton addTarget:self action:@selector(nextOrSubmitAction) forControlEvents:UIControlEventTouchUpInside];
        [navView addSubview:self.nextOrSubmitButton];
        
        rect = CGRectMake(0, CGRectGetHeight(self.topView.bounds)-handleHeight, SCREEN_WIDTH, handleHeight);
        UIView *dragView = [[UIView alloc] initWithFrame:rect];
        [self addButtonsToDragView:dragView];
        [self.topView addSubview:dragView];
        
        
        rect = CGRectMake(0, handleHeight, SCREEN_WIDTH, SCREEN_WIDTH);
        self.imageScrollView = [[TWImageScrollView alloc] initWithFrame:rect];
        self.imageScrollView.backgroundColor = [UIColor blackColor];
        self.imageScrollView.scrollDelegate  = self;
        [self.topView addSubview:self.imageScrollView];
        [self.topView sendSubviewToBack:self.imageScrollView];
        [self.topView.layer addSublayer:[self maskLayer:rect]];
        CGFloat y = handleHeight+SCREEN_WIDTH;
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, SCREEN_HEIGHT-y)];
        bottomView.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:bottomView];

    }
    return _topView;
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    CGFloat scale = systemVer >= 4.0 ? UIScreen.mainScreen.scale : 1.0;
    
    return [self imageWithCGColor:cgColor_ size:size_ scale:scale];
}

+ (UIImage *)imageWithCGColor:(CGColorRef)cgColor_
                         size:(CGSize)size_
                        scale:(CGFloat)scale_
{
    CGFloat systemVer = [[[UIDevice currentDevice] systemVersion] floatValue];
    
    if ( systemVer >= 4.0 ) {
        UIGraphicsBeginImageContextWithOptions(size_, NO, scale_);
    }
    else {
        UIGraphicsBeginImageContext(size_);
    }
    
    CGRect rect = CGRectZero;
    rect.size = size_;
    
    UIColor *color = [UIColor colorWithCGColor:cgColor_];
    
    UIBezierPath* rectanglePath = [UIBezierPath bezierPathWithRect:rect];
    [color setFill];
    [rectanglePath fill];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)addButtonsToDragView:(UIView *)view {
    NSArray *list   = @[];
    list = @[@"滤镜"];
    CGFloat height  = 44;
    CGFloat width   = SCREEN_WIDTH/list.count;
    CGSize itemSize = (CGSize){width,height};
    NSInteger index = 0;
    UIButton *button = nil;
    for (NSString *title in list) {
        button = [self buttonWithTitle:title withSize:itemSize];
        button.selected  = YES;
        button.tag       = index;
        button.frame     = CGRectMake(width*index, 0, width, height);
        [button addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:button];
        index++;
    }
//    if (list.count > 1) {
//        [button setSelected:YES];
//    }
}

- (void)buttonDidPress:(UIButton *)sender {
    return;
//    NSInteger index = sender.tag;
//    NSArray *list = @[self.collectionView];
//    for (UIButton *button in [[sender superview]subviews]) {
//        if ([button isKindOfClass:UIButton.class]) {
//            button.selected = YES;
//        }
//    }
//    sender.selected = NO;
//    for (UIView *view in list) {
//        view.hidden = NO;
//    }
//    [list[index] setHidden:YES];
}


+ (UIImage *)fixrotation:(UIImage *)image {
    
    
    if (image.imageOrientation == UIImageOrientationUp) return image;
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
    
}

+ (UIImage *)generatePhotoThumbnail:(UIImage *)image {
    image = [self fixrotation:image];
    CGSize size = image.size;
    CGSize croppedSize;
    CGFloat ratio   = SCREEN_WIDTH/3 - 20;
    CGFloat offsetX = 0.0;
    CGFloat offsetY = 0.0;
    
    // check the size of the image, we want to make it
    // a square with sides the size of the smallest dimension
    if (size.width > size.height) {
        offsetX = (size.height - size.width) / 2;
        croppedSize = CGSizeMake(size.height, size.height);
    } else {
        offsetY = (size.width - size.height) / 2;
        croppedSize = CGSizeMake(size.width, size.width);
    }
    
    // Crop the image before resize
    CGRect clippedRect = CGRectMake(offsetX * -1, offsetY * -1, croppedSize.width, croppedSize.height);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], clippedRect);
    // Done cropping
    
    // Resize the image
    CGRect rect = CGRectMake(0.0, 0.0, ratio, ratio);
    
    UIGraphicsBeginImageContext(rect.size);
    [[UIImage imageWithCGImage:imageRef] drawInRect:rect];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    // Done Resizing
    
    return thumbnail;
}

#pragma mark getters & setters

- (UIButton *)buttonWithTitle:(NSString *)title withSize:(CGSize)size{
    UIButton *button    = [UIButton buttonWithType:UIButtonTypeCustom];
    UIColor *darkColor  = [UIColor colorWithRed:46.0/255.0 green:43.0/255.0 blue:37.0/255.0 alpha:1];
    UIColor *whiteColor = [UIColor whiteColor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:darkColor forState:UIControlStateNormal];
    [button setTitleColor:whiteColor forState:UIControlStateSelected];
    [button setBackgroundImage:[self.class imageWithCGColor:whiteColor.CGColor size:size] forState:UIControlStateNormal];
    [button setBackgroundImage:[self.class imageWithCGColor:darkColor.CGColor size:size] forState:UIControlStateSelected];
    
    return button;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = 10;
        CGFloat value   = (SCREEN_WIDTH / self.filterList.count)-padding/2;
        CGFloat y       = NavigationBarHeight*2+SCREEN_WIDTH-20;
        CGFloat height  = SCREEN_HEIGHT-y;
        CGFloat itemHeight = value*3/2-20;

        y += (height-itemHeight)/2;
        UICollectionViewFlowLayout *layout  = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize                     = CGSizeMake(value, itemHeight);
        layout.sectionInset                 = UIEdgeInsetsMake(0, padding, 0, padding);
        layout.minimumInteritemSpacing      = 5;
        layout.minimumLineSpacing           = 0;
        layout.scrollDirection              = UICollectionViewScrollDirectionHorizontal;
        CGRect rect = CGRectMake(0, y, SCREEN_WIDTH, itemHeight);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator   = NO;
        _collectionView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
//        _collectionView.hidden = (self.list.count > 1);
        [_collectionView registerClass:[TWPhotoFilterCollectionViewCell class] forCellWithReuseIdentifier:@"TWPhotoFilterCollectionViewCell"];
        
    }
    return _collectionView;
}

- (NSString *)navigtationTitle {
    return [NSString stringWithFormat:@"%ld/%ld",self.currentIndex+1,self.list.count];
}

//- (UIView *)imageListView {
//    if (!_imageListView) {
//        CGFloat padding  = 20;
//        CGFloat y        = NavigationBarHeight*2+SCREEN_WIDTH-20;
//        CGFloat height   = SCREEN_HEIGHT-y;
//        CGFloat itemSize = SCREEN_WIDTH/3 - 20;
//        NSInteger index  = 0;
//        self.thumbnailImageList = [@[] mutableCopy];
//        _imageListView = [[UIView alloc] initWithFrame:CGRectMake(0, y, SCREEN_WIDTH, height)];
//        _imageListView.hidden = !(self.list.count > 1);
//        CGFloat x = 0;
//        for (TWPhoto *photo in self.list) {
//            x += itemSize + padding;
//            if (index == 0) {
//                x = 10;
//            }
//            CGRect rect = CGRectMake(x, (height - itemSize)/2, itemSize, itemSize);;
//            TWPhotoImageItem *item = [[TWPhotoImageItem alloc] initWithFrame:rect];
//            if (index == 0) {
//                item.layer.borderWidth  = 4.f;
//            }
//            item.image.image = [photo thumbnailImage];
//            [_imageListView addSubview:item];
//            [self.thumbnailImageList addObject:item];
//            index++;
//        }
//    }
//    return _imageListView;
//}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        CGRect rect = CGRectMake((SCREEN_WIDTH-100)/2, 0, 100, 44);
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:rect];
        titleLabel.text = @"选择图片";
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (CALayer *)maskLayer:(CGRect)frame {
    if (!_maskLayer) {
        CALayer *maskLayer = [CALayer layer];
        maskLayer.bounds   = frame;
        CGFloat y          = CGRectGetMinY(frame);
        CGFloat height     = CGRectGetHeight(frame);
        CGFloat width      = CGRectGetWidth(frame);
        maskLayer.position = CGPointMake(width/2, height/2+y);
        for (int i = 0; i < 4; i++) {
            CAShapeLayer *line = [CAShapeLayer layer];
            UIBezierPath *linePath=[UIBezierPath bezierPath];
            CGPoint startPoint,endPoint;
            CGFloat per = (i%2)*0.33 + 0.33;
            if (i > 1) {
                startPoint = CGPointMake(per*width, y);
                endPoint   = CGPointMake(per*width, height+y);
            } else {
                startPoint = CGPointMake(0, per*height+y);
                endPoint   = CGPointMake(width, per*height+y);
            }
            [linePath moveToPoint: startPoint];
            [linePath addLineToPoint:endPoint];
            line.path         = linePath.CGPath;
            line.fillColor    = nil;
            line.opacity      = 0.7;
            line.shadowColor  = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5].CGColor;
            line.shadowRadius = 2;
            line.strokeColor  = [UIColor whiteColor].CGColor;
            [maskLayer addSublayer:line];
        }
        _maskLayer = maskLayer;
    }
    return _maskLayer;
}
@end
