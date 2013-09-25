//
//  CanvasView.m
//  TouchPaintApp
//
//  Created by fexd on 2012/08/14.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import "CanvasView.h"

@implementation CanvasView
@synthesize delegate;
@synthesize canvasImage;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [canvasImage drawInRect:rect
                  blendMode:kCGBlendModeNormal alpha:1.0];
}

// 画面描画
// setNeedsDisplayより内部的にdrawRectが呼び出される
- (void) setCanvasImage:(UIImage *) image {
    canvasImage = image;
    [self setNeedsDisplay];
}

// タッチダウン
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // タッチされたポイントを取得
    NSSet* allTouchs = [event allTouches];
    UITouch* touch = [allTouchs anyObject];
    CGPoint location = [touch locationInView:self];
    
    if([delegate respondsToSelector:@selector(canvasViewTouchesBegan:Location:)]) {
        [delegate canvasViewTouchesBegan:self Location:location];
    }
}

// タッチムーブ
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // タッチされたポイントを取得
    NSSet* allTouchs = [event allTouches];
    UITouch* touch = [allTouchs anyObject];
    CGPoint location = [touch locationInView:self];
    
    if([delegate respondsToSelector:@selector(canvasViewTouchesMoved:Location:)]) {
        [delegate canvasViewTouchesMoved:self Location:location];
    }
}

// タッチアップ
-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // タッチされたポイントを取得
    NSSet* allTouchs = [event allTouches];
    UITouch* touch = [allTouchs anyObject];
    CGPoint location = [touch locationInView:self];
    
    if([delegate respondsToSelector:@selector(canvasViewTouchesEnded:Location:)]) {
        [delegate canvasViewTouchesEnded:self Location:location];
    }
}

@end
