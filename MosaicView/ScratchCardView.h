//
//  ScratchCardView.h
//  MosaicView
//
//  Created by Superman on 2018/7/1.
//  Copyright © 2018年 Superman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScratchCardView : UIView

/**
 要刮的底图.
 */
@property (nonatomic, strong) UIImage *image;
/**
 涂层图片.
 */
@property (nonatomic, strong) UIImage *surfaceImage;

@end
