//
//  DataManager.m
//  TouchPaintApp
//
//  Created by fexd on 2012/08/17.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import "DataManager.h"

@implementation DataManager
@synthesize drawColor;
@synthesize penSize;

- (id) initWithSize:(CGSize)size {
    
    self = [super init];
    
    if (self) {
        
        // コンテキストを生成する
        contextSize = size; // サイズをプロパティーに保存
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        drawContext = CGBitmapContextCreate(nil,                // ピクセルのバッフ
                                           size.width,          // 横のピクセル数
                                           size.height,         // 縦のピクセル
                                           8,                   // 1ピクセルのビット数
                                           4 * size.width,      // 横１ラインのピクセル数
                                           colorSpace,          // カラースペース
                                           kCGImageAlphaPremultipliedFirst); // バイトの並び方 kCGImageAlphaFirst
        CGColorSpaceRelease(colorSpace);
        CGContextSetLineCap(drawContext, kCGLineCapRound);
        CGContextSetLineJoin(drawContext, kCGLineJoinRound);
        // ペンサイズ
        self.penSize = 1;
        // 描画色
        self.drawColor = [UIColor colorWithRed: 0.0
                                         green: 0.0
                                          blue: 0.0
                                         alpha: 1.0];
    }
    return self;
}

// ペンサイズの設定（セッタメソッド）
- (void) setPenSize:(float) pensize {
    
    penSize = pensize;
    // コンテキストにペンサイズを設定
    CGContextSetLineWidth(drawContext, penSize);

}

// 描画色の設定（セッタメソッド）
- (void) setDrawColor:(UIColor*) color {
    
    drawColor = color;
    // コンテキストの描画色設定
    CGContextSetStrokeColorWithColor(drawContext, drawColor.CGColor);
    
}

-(void) drawStart:(CGPoint) pt {
    
    // 描画の開始ポイントの保存
    startPt = pt;
    
}

// 描画中
-(UIImage*) drawMoved:(CGPoint) pt {
    
    // コンテキストの保存
    CGContextSaveGState(drawContext);
    {
        // コンテキストを上下反転させる
        CGContextTranslateCTM(drawContext, 0, contextSize.height);
        CGContextScaleCTM(drawContext, 1, -1);
        // 前回のポイントの差分からパスラインを作成する
        CGContextBeginPath(drawContext);
        CGContextMoveToPoint(drawContext, startPt.x, startPt.y);
        CGContextAddLineToPoint(drawContext, pt.x
                                , pt.y);
        
        //	ラインの端の処理を、丸になるよう指示する。
        CGContextSetLineCap(drawContext, kCGLineCapRound);
        // コンテキストのパスラインを描画する
        CGContextStrokePath(drawContext);

    }
    // コンテキストの復元
    CGContextRestoreGState(drawContext);
    // ポイントの更新
    startPt = pt;
    // コンテキストの画像を作成して返す
    return [self creatImage];
}

// 描画終了
-(UIImage*) drawEnded:(CGPoint)pt {
    
    // コンテキストから画像を作成して返す
    return [self creatImage];
    
}

// 画像消去
-(UIImage*) clear {
    
    // 画像のコンテキストをクリアする
    CGRect rect = CGRectMake(0,0,contextSize.width,contextSize.height);
    CGContextClearRect(drawContext,rect);
    
    return [self creatImage];
}

// コンテキストからイメージを作成する
-(UIImage*) creatImage {
    
    // コンテキストからCGImageRefを作成する
    CGImageRef cgImage = CGBitmapContextCreateImage(drawContext);
    // CGImageRefからUIImageを作成する
    UIImage* image = [UIImage imageWithCGImage:cgImage];
    // CGImageRefを解放する
    CFRelease(cgImage);
    
    return image;
}

@end
