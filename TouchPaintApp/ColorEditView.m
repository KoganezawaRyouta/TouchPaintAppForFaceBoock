//
//  ColorEditView.m
//  TouchPaintApp
//
//  Created by fexd on 2012/08/14.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import "ColorEditView.h"


@implementation ColorEditView
@synthesize delegate;
@synthesize colorPreview;

@synthesize redSlider;
@synthesize greenSlider;
@synthesize blueSlider;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (IBAction)sliderAction:(UISlider *)sender {
    
    //tagプロパティでスライダーを特定する
    if(sender.tag == 0) {
        red = sender.value;
    }

    if(sender.tag == 1) {
        green = sender.value;
    }
    
    if(sender.tag == 2) {
        blue = sender.value;
    }
    
    //カラー生成する
    UIColor* color = [UIColor colorWithRed: red
                                     green: green
                                      blue: blue
                                     alpha: 1.0];
    // 背景色として設定
    colorPreview.backgroundColor = color;
    
    // デリゲートに作成したカラーを通知
    if( [delegate respondsToSelector:@selector(colorEditViewColorCreated:Color:)] ) {
        
        [delegate colorEditViewColorCreated:self
                                      Color:color];
    }
}

@end
