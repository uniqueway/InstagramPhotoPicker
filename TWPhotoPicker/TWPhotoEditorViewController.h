//
//  TWPhotoEditorViewController.h
//  Pods
//
//  Created by Madao on 11/6/15.
//
//

#import <UIKit/UIKit.h>

typedef void(^cropBlock)(NSArray *list);
@interface TWPhotoEditorViewController : UIViewController

@property (nonatomic, copy) void(^cropBlock)(NSArray *list);

- (id)initWithPhotoList:(NSArray *)list crop:(cropBlock)crop;

@end
