//
//  ViewController.m
//  MosaicView
//
//  Created by Superman on 2018/7/1.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import "ViewController.h"
#import "ScratchCardView.h"


#define kBitsPerComponent (8)
#define kBitsPerPixel (32)
#define kPixelChannelCount (4)

@interface ViewController ()

@property (nonatomic,strong)ScratchCardView * cardView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _cardView =[[ScratchCardView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.view.bounds)/2-150, CGRectGetMaxY(self.view.bounds)/2-150, 300, 300)];
    UIImage *image=[UIImage imageNamed:@"6.jpg"];
    UIImage *image2=[UIImage imageNamed:@"p2.JPG"];

    _cardView.surfaceImage=image;
    
//    _cardView.image=[self transToMosaicImage:image blockLevel:20];
    _cardView.image=image2;//底层图片

    [self.view addSubview:_cardView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (UIImage *)transToMosaicImage:(UIImage*)orginImage blockLevel:(NSUInteger)level
{
    //获取BitmapData
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    CGImageRef imgRef=orginImage.CGImage;
    CGFloat width =CGImageGetWidth(imgRef);
    CGFloat height=CGImageGetHeight(imgRef);
    
    CGContextRef context = CGBitmapContextCreate(nil, width, height, kBitsPerComponent, width*kPixelChannelCount, colorSpace, kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imgRef);
    unsigned char *bitmapData = CGBitmapContextGetData(context);
    
    //这里把BitmapData进行马赛克转换,就是用一个点的颜色填充一个level*level的正方形
    unsigned char pixel[kPixelChannelCount]={0};
    NSUInteger index,preIndex;
    for (NSUInteger i=0; i<height-1; i++) {
        for (NSUInteger j=0; j<width-1; j++) {
            index= i*width + j;
            if (i % level ==0) {
                if (j % level ==0) {
                    memcpy(pixel, bitmapData+kPixelChannelCount*index, kPixelChannelCount);
                }else{
                    memcpy(bitmapData+kPixelChannelCount*index, pixel, kPixelChannelCount);
                }
            }else{
                preIndex = (i-1)*width +j;
                memcpy(bitmapData +kPixelChannelCount*index, bitmapData+kPixelChannelCount*preIndex, kPixelChannelCount);
            }
        }
    }
    
    NSInteger dataLength =width *height *kPixelChannelCount;
    CGDataProviderRef provider =CGDataProviderCreateWithData(NULL, bitmapData, dataLength, NULL);
    //创建要输出的图像
    CGImageRef mosaicImageRef = CGImageCreate(width, height, kBitsPerComponent, kBitsPerPixel, width*kPixelChannelCount, colorSpace, kCGBitmapByteOrderDefault, provider,NULL, NO, kCGRenderingIntentDefault);
    
    CGContextRef outputContext= CGBitmapContextCreate(nil, width, height, kBitsPerComponent, width*kPixelChannelCount, colorSpace, kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(outputContext, CGRectMake(0.0, 0.0, width, height), mosaicImageRef);
    
    CGImageRef resultImageRef = CGBitmapContextCreateImage(outputContext);
    UIImage *resultImage = nil;
    if ([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
        float scale = [[UIScreen mainScreen] scale];
        resultImage=[UIImage imageWithCGImage:resultImageRef scale:scale orientation:UIImageOrientationUp];
    }else{
        resultImage=[UIImage imageWithCGImage:resultImageRef];
    }
    
    if (resultImageRef) {
        CFRelease(resultImageRef);
    }
    if (mosaicImageRef) {
        CFRelease(mosaicImageRef);
    }
    if (colorSpace) {
        CGColorSpaceRelease(colorSpace);
    }
    if (provider) {
        CGDataProviderRelease(provider);
    }
    if (context) {
        CGContextRelease(context);
    }
    if (outputContext) {
        CGContextRelease(outputContext);
    }
    return resultImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end


























