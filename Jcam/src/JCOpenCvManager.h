//
//  JCOpenCvManager.h
//  Jcam
//
//  Created by 上原 将司 on 2014/09/12.
//  Copyright (c) 2014年 Project Wolf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JCOpenCvManager : NSObject

- (cv::Mat)cvMatFromUIImage:(UIImage *)image;
- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat;

@end
