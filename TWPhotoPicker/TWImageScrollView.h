//
//  TWImageScrollView.h
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IFVideoCamera.h"


@interface TWImageScrollView : UIScrollView
@property (strong, nonatomic) IFVideoCamera *videoCamera;
- (void)displayImage:(UIImage *)image;

- (UIImage *)capture;

@end
