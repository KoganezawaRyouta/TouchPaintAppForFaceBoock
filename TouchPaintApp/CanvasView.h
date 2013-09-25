//
//  CanvasView.h
//  TouchPaintApp
//
//  Created by fexd on 2012/08/14.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CanvasView : UIView {
    
    id delegate;
    UIImage* canvasImage;

}

@property (strong,nonatomic) id delegate;
@property (strong,nonatomic) UIImage* canvasImage;

@end
@protocol CanvasViewDelegate <NSObject>

// タッチダウン
- (void) canvasViewTouchesBegan: (CanvasView*) contentView Location: (CGPoint) pt;

// タッチムーブ
- (void) canvasViewTouchesMoved: (CanvasView*) contentView Location: (CGPoint) pt;

// タッチエンド
- (void) canvasViewTouchesEnded: (CanvasView*) contentView Location: (CGPoint) pt;

@end