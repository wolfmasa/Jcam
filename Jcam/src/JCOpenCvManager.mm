//
//  JCOpenCvManager.m
//  Jcam
//
//  Created by 上原 将司 on 2014/09/12.
//  Copyright (c) 2014年 Project Wolf. All rights reserved.
//

#import "JCOpenCvManager.h"

@implementation JCOpenCvManager


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    return cvMat;
}

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                              //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

-(cv::Mat)faceDetection:(UIImage *)image
{
    /*
     const char *imagename = argc > 1 ? argv[1] : "../../image/lenna.png";
     cv::Mat img = cv::imread(imagename, 1);
     if(img.empty()) return -1;
     */
    cv::Mat img = [self cvMatFromUIImage:image];
    
    
    double scale = 4.0;
    cv::Mat gray, smallImg(cv::saturate_cast<int>(img.rows/scale), cv::saturate_cast<int>(img.cols/scale), CV_8UC1);
    // グレースケール画像に変換
    cv::cvtColor(img, gray, cv::CV_BGR2GRAY);
    // 処理時間短縮のために画像を縮小
    cv::resize(gray, smallImg, smallImg.size(), 0, 0, cv::INTER_LINEAR);
    cv::equalizeHist( smallImg, smallImg);
    
    // 分類器の読み込み
    std::string cascadeName = "./haarcascade_frontalface_alt.xml"; // Haar-like
    //std::string cascadeName = "./lbpcascade_frontalface.xml"; // LBP
    cv::CascadeClassifier cascade;
    if(!cascade.load(cascadeName))
        return nil;
    
    std::vector<cv::Rect> faces;
    /// マルチスケール（顔）探索xo
    // 画像，出力矩形，縮小スケール，最低矩形数，（フラグ），最小矩形
    cascade.detectMultiScale(smallImg, faces,
                             1.1, 2,
                             cv::CV_HAAR_SCALE_IMAGE,
                             cv::Size(30, 30));
    
    // 結果の描画
    std::vector<cv::Rect>::const_iterator r = faces.begin();
    for(; r != faces.end(); ++r) {
        cv::Point center;
        int radius;
        center.x = cv::saturate_cast<int>((r->x + r->width*0.5)*scale);
        center.y = cv::saturate_cast<int>((r->y + r->height*0.5)*scale);
        radius = cv::saturate_cast<int>((r->width + r->height)*0.25*scale);
        cv::circle( img, center, radius, cv::Scalar(80,80,255), 3, 8, 0 );
    }
    
    cv::namedWindow("result", CV_WINDOW_AUTOSIZE|CV_WINDOW_FREERATIO);
    cv::imshow( "result", img );
    cv::waitKey(0);
}

@end
