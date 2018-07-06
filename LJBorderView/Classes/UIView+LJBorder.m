//
//  UIButton+LJBorder.m
//  border
//
//  Created by leju_feifei on 05/05/2018.
//  Copyright © 2018 leju. All rights reserved.
//

#import "UIView+LJBorder.h"
#import <objc/runtime.h>

@implementation LJLineLayer
+ (instancetype)lineLayerWithDirection:(LJLineDirection)direction lineWidth:(NSInteger)lineWidth lineColor:(UIColor *)lineColor insets:(UIEdgeInsets)insets {
    LJLineLayer *linelayer = [[LJLineLayer alloc] init];
    linelayer.backgroundColor = lineColor.CGColor;
    linelayer.lj_lineWidth = lineWidth;
    linelayer.lj_LineInsets = insets;
    linelayer.lj_lineDirection = direction;
    return linelayer;
}
- (void)layoutSublayers {
    [super layoutSublayers];
    [self changeSuperFrame:self.superlayer.frame];
}
- (void)changeSuperFrame:(CGRect)superFrame {
    CGSize viewSize = superFrame.size;
    CGRect frame = CGRectZero;
    UIEdgeInsets insets = self.lj_LineInsets;
    
    switch (self.lj_lineDirection) {
        case LJLineDirectionTop: {
            frame = CGRectMake(insets.left, insets.top, viewSize.width - insets.left - insets.right, self.lj_lineWidth);
        } break;
        case LJLineDirectionLeft: {
            frame = CGRectMake(insets.left, insets.top, self.lj_lineWidth, viewSize.height - insets.top - insets.bottom);
        } break;
        case LJLineDirectionBottom: {
            frame = CGRectMake(insets.left, viewSize.height - insets.bottom-self.lj_lineWidth, viewSize.width - insets.left - insets.right, self.lj_lineWidth);
        } break;
        case LJLineDirectionRight: {
            frame = CGRectMake(viewSize.width - insets.right - self.lj_lineWidth,insets.top, self.lj_lineWidth, viewSize.height - insets.top - insets.bottom);
        } break;
        default:
            break;
    }
    self.frame = frame;
}
@end

@protocol LJViewFrameObserverDelegate <NSObject>
- (void)lj_layoutSubviews;
@end

@interface LJViewFrameObserver : NSObject
@property (unsafe_unretained, nonatomic) id delegate;
@end

@implementation LJViewFrameObserver
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (_delegate && [_delegate respondsToSelector:@selector(lj_layoutSubviews)]) {
        [_delegate lj_layoutSubviews];
    }
}
- (void)dealloc {
    [self.delegate removeObserver:self forKeyPath:@"frame"];
    self.delegate = nil;
}
@end

@interface UIView ()
@property (strong, nonatomic) LJViewFrameObserver *lj_observer;
@property (strong, nonatomic) NSMutableArray *lj_lineLayers;
@end

@implementation UIView (LJLine)
- (LJLineLayer *)addLineDirection:(LJLineDirection)direction lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color insets:(UIEdgeInsets)insets {
    LJLineLayer *lineLayer = [self getLineDirection:direction lineWidth:lineWidth insets:insets];
    if(lineLayer) {
        lineLayer.backgroundColor = color.CGColor;
        return lineLayer;
    }
    
    lineLayer =  [LJLineLayer lineLayerWithDirection:direction lineWidth:lineWidth lineColor:color insets:insets];
    [self.layer addSublayer:lineLayer];
    if (self.lj_lineLayers.count == 0) {
        [self addObserver:self.lj_observer forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:nil];
    }
    [self.lj_lineLayers addObject:lineLayer];
    [lineLayer changeSuperFrame:self.frame];
    return lineLayer;
}
- (LJLineLayer *)getLineDirection:(LJLineDirection)direction lineWidth:(CGFloat)lineWidth insets:(UIEdgeInsets)insets {
    for (LJLineLayer *layer in self.lj_lineLayers) {
        if(layer.lj_lineWidth == lineWidth && layer.lj_lineDirection == direction && UIEdgeInsetsEqualToEdgeInsets(insets, layer.lj_LineInsets)) {
            return layer;
        }
    }
    return nil;
}
- (void)lj_layoutSubviews {
    for (LJLineLayer *lineLayer in self.layer.sublayers) {
        if ([lineLayer isKindOfClass:[LJLineLayer class]]) {
            [lineLayer changeSuperFrame:self.frame];
        }
    }
}
- (void)setLj_lineLayers:(NSMutableArray *)lj_lineLayers {
    objc_setAssociatedObject(self, @selector(lj_lineLayers), lj_lineLayers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSMutableArray *)lj_lineLayers {
    NSMutableArray *lj_lineLayers = objc_getAssociatedObject(self, @selector(lj_lineLayers));
    if (!lj_lineLayers) {
        lj_lineLayers = [NSMutableArray array];
        [self setLj_lineLayers:lj_lineLayers];
    }
    return lj_lineLayers;
}
- (void)setLj_observer:(LJViewFrameObserver *)lj_observer {
    objc_setAssociatedObject(self, @selector(lj_observer), lj_observer, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (LJViewFrameObserver *)lj_observer {
    LJViewFrameObserver *observer = objc_getAssociatedObject(self, @selector(lj_observer));
    if (!observer) {
        observer = [[LJViewFrameObserver alloc] init];
        [self setLj_observer:observer];
        observer.delegate = self;
    }
    return observer;
}
@end

@implementation UIView (LJBorder)
- (void)addLineBorderDirection:(LJRectDirection)direction lineWidth:(CGFloat)lineWidth lineColor:(UIColor *)color {
    LJLineLayer *linLayer = nil;
    if (direction & LJRectDirectionTop) {
        linLayer = [self addLineDirection:LJLineDirectionTop lineWidth:lineWidth lineColor:color insets:UIEdgeInsetsZero];
    } else if (direction & LJRectDirectionLeft) {
        linLayer =[self addLineDirection:LJLineDirectionLeft lineWidth:lineWidth lineColor:color insets:UIEdgeInsetsZero];
    } else if (direction & LJRectDirectionBottom) {
        linLayer =[self addLineDirection:LJLineDirectionBottom lineWidth:lineWidth lineColor:color insets:UIEdgeInsetsZero];
    } else if (direction & LJRectDirectionRight) {
        linLayer =[self addLineDirection:LJLineDirectionRight lineWidth:lineWidth lineColor:color insets:UIEdgeInsetsZero];
    }
}
@end

