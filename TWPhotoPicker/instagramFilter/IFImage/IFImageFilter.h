//
//  IFImageFilter.h
//  InstaFilters
//
//  Created by Di Wu on 2/28/12.
//  Copyright (c) 2012 twitter:@diwup. All rights reserved.
//

#import "GPUImageFilter.h"
#import "GPUImageTwoInputFilter.h"

@interface IFImageFilter : GPUImageFilter {

    GPUImageFramebuffer *secondInputFramebuffer,*thirdInputFramebuffer;
    
    BOOL hasSetFirstTexture, hasReceivedFirstFrame, hasReceivedSecondFrame, firstFrameWasVideo, secondFrameWasVideo, hasSetSecondTexture;
    GLuint filterSourceTexture,filterSourceTexture2,filterSourceTexture3, filterSourceTexture4, filterSourceTexture5, filterSourceTexture6;
}

@end
