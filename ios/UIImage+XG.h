//
//  UIImage+XG.h
//  KukuWatch
//
//  Created by Rover on 3/12/15.
//  Copyright © 2015年 Rover. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (XG)

+ (instancetype)imageWithIconName:(UIImage *)icon borderImage:(UIImage *)borderImage border:(int)border;

- (UIImage *)imageByScalingAndCroppingForSize:(CGSize)targetSize;

@end
