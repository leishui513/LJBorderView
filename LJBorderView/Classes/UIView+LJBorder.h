//
//  UIButton+LJBorder.h
//  border
//
//  Created by leju_feifei on 05/05/2018.
//  Copyright © 2018 leju. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, LJRectDirection) {
    LJRectDirectionTop     = 1 << 0,
    LJRectDirectionLeft    = 1 << 1,
    LJRectDirectionBottom  = 1 << 2,
    LJRectDirectionRight = 1 << 3,
    LJRectDirectionAll  = ~0UL
};

@interface UIView (LJBorder)
- (void)addLineBorderDirection:(LJRectDirection)direction lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color;
@end


typedef NS_OPTIONS(NSUInteger, LJLineDirection) {
    LJLineDirectionTop     = 1 << 0,
    LJLineDirectionLeft    = 1 << 1,
    LJLineDirectionBottom  = 1 << 2,
    LJLineDirectionRight = 1 << 3,
};

@interface LJLineLayer: CALayer
@property (nonatomic) NSInteger tag;
@property (nonatomic) CGFloat lj_lineWidth;
@property (nonatomic) UIEdgeInsets lj_LineInsets;
@property (nonatomic) LJLineDirection lj_lineDirection;
@end

@interface UIView (LJLine)
- (LJLineLayer *)addLineDirection:(LJLineDirection)direction lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color insets:(UIEdgeInsets)insets;
@end


