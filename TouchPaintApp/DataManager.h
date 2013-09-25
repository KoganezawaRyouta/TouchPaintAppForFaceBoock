//
//  DataManager.h
//  TouchPaintApp
//
//  Created by fexd on 2012/08/17.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataManager : NSObject {
    
    CGContextRef drawContext; //描画用のコンテキスト
    CGSize contextSize;       // コンテキストのサイズ
    CGPoint startPt;          // 描画の起点ポイント
    float penSize;            // ペンのサイズ
    UIColor* drawColor;       // 描画色
    float penSizeTmp;         // ペンのサイズ(バックアップ用)
    UIColor* drawColorTmp;    // 描画色(バックアップ用)
}

@property (strong,nonatomic) UIColor* drawColor;
@property (nonatomic) float penSize;
@property (nonatomic) float penSizeTmp;
@property (strong,nonatomic) UIColor* drawColorTmp;

// 初期化メソッド
- (id) initWithSize: (CGSize) size;

// 画面描画メソッド
- (void) drawStart: (CGPoint) pt;
-(UIImage*) drawMoved: (CGPoint) pt;
-(UIImage*) drawEnded: (CGPoint) pt;
-(UIImage*) clear;

// 画像生成メソッド
- (UIImage*) creatImage;

@end
