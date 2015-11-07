//
//  ViewController.m
//  InstagramPhotoPicker
//
//  Created by Emar on 12/4/14.
//  Copyright (c) 2014 wenzhaot. All rights reserved.
//

#import "ViewController.h"
#import "TWPhotoPickerController.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        TWPhotoPickerController *photoPicker = [[TWPhotoPickerController alloc] init];

        photoPicker.cropBlock = ^(NSArray *list) {
            CGFloat size = 50;
            NSInteger index = 0;
            for (UIImage *image in list) {
                UIImageView *imageview = [[UIImageView alloc] initWithFrame:CGRectMake(0, index*size, size, size)];
                imageview.image = image;
                [self.view addSubview:imageview];
                index++;
            }

        };
        
        UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:photoPicker];
        [navCon setNavigationBarHidden:YES];
        
        [self presentViewController:navCon animated:YES completion:NULL];
    });

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAction:(id)sender {
}

@end
