//
//  TWPhotoImageItem.m
//  Pods
//
//  Created by Madao on 12/8/15.
//
//

#import "TWPhotoImageItem.h"

@interface TWPhotoImageItem ()
@end

@implementation TWPhotoImageItem

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    CGRect rect = CGRectMake(0, 0, width, height);
    UIImage *iconImage = [UIImage imageNamed:@"select_photo_icon"];
    CGFloat iconWidth  = iconImage.size.width/2;
    CGFloat iconHeight = iconImage.size.height/2;
    self.icon = [[UIImageView alloc] initWithImage:iconImage];
    self.icon.frame = CGRectMake((width-iconWidth)/2, (height-iconHeight)/2, iconWidth, iconHeight);
    self.icon.hidden = YES;
    self.image = [[UIImageView alloc] initWithFrame:rect];
    self.image.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:self.image];
    [self addSubview:self.icon];
    return self;
}



@end
