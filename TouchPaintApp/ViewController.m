//
//  ViewController.m
//  TouchPaintApp
//
//  Created by fexd on 2012/08/13.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import "ViewController.h"
#import "CanvasView.h"
#import "ColorEditView.h"
#import "DataManager.h"
#import <QuartzCore/QuartzCore.h>

@interface ViewController ()

@end

@implementation ViewController

@synthesize fbLoginButton;
@synthesize toolBarTop;
@synthesize toolbar;
@synthesize canvas;
@synthesize colorEditView;
@synthesize colorEditButton;
@synthesize colorDeletButton;
@synthesize topBarSpace;
@synthesize facebook;
@synthesize permissions;
@synthesize userIfIpone;

// -----------------------------
// FACEBOOK認証情報
// -----------------------------
static NSString* APPLICATION_ID;
static NSString* APPLICATION_ID_IPHONE = @"283435158423427";
static NSString* APPLICATION_ID_IPAD = @"458903230820446";
static NSString *FACEBOOK_SECRET_KEY_IPHONE = @"ef742826740d14166d5f5e2f2f5faf42";
static NSString *FACEBOOK_SECRET_KEY_IPAD = @"0e3c46d30c80d4140c79b22f7894608c";

// ----------------------------
// IPAD端末専用変数
// ----------------------------
UIPopoverController *imagePopCon;

// Nibファイルが読み込まれた
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // データマネージャーインスタンス生成
	dataManager = [[DataManager alloc] initWithSize:CGSizeMake(canvas.frame.size.width,
                                                               canvas.frame.size.height)];
    canvas.delegate = self;
    colorEditView.delegate = self;
    
    // FaceBook認証
    facebook = [[Facebook alloc] initWithAppId:APPLICATION_ID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    if ([facebook isSessionValid] == NO){
        [fbLoginButton setTitle:@"LogIn" forState:UIControlStateNormal];
    } else {
        //[self fbDidLogin];
        [fbLoginButton setTitle:@"LogOut" forState:UIControlStateNormal];
    }
    
    // 端末判定
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        userIfIpone = YES;
        APPLICATION_ID = APPLICATION_ID_IPHONE;
    } else {
        userIfIpone = NO;
        APPLICATION_ID = APPLICATION_ID_IPAD;
    }

}

// FaceBookへログイン/ログアウトアクション
- (IBAction)fbLogin:(id)sender {
    
    facebook = [[Facebook alloc] initWithAppId:APPLICATION_ID andDelegate:self];
    // セッション有効かを判定
 //[fbLoginButton setTitle:@"LogIn" forState:UIControlStateNormal];
    if ([fbLoginButton.currentTitle isEqualToString:@"LogIn"]) {
        NSLog(@"login");
        // ログイン処理
        [fbLoginButton setTitle:@"LogOut" forState:UIControlStateNormal];
        permissions =  [[NSArray alloc] initWithObjects:@"publish_stream", @"offline_access",nil];
        [facebook authorize:permissions];
    } else {
        
        // ログアウト処理
        NSLog(@"logout");
        [fbLoginButton setTitle:@"LogIn" forState:UIControlStateNormal];
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        [facebook logout:self];
        
    }
    
}

// FaceBookへ画像をアップロード
- (IBAction)fbUpload:(id)sender {
    
    facebook = [[Facebook alloc] initWithAppId:APPLICATION_ID andDelegate:self];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   [self creatImage], @"source",
                                   nil];
    
    [facebook requestWithGraphPath:@"me/photos"
                         andParams:params
                     andHttpMethod:@"POST"
                       andDelegate:self];
    
}

//投稿処理完了後に呼ばれるデリゲートメソッドを実装。
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"received response");
};

//requestが成功してロードされた時に呼び出されるデリゲートメソッド
- (void)request:(FBRequest *)request didLoad:(id)result {
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if ([result objectForKey:@"owner"]) {
		NSLog(@"Photo upload Success");
	} else {
		NSLog(@"result name:%@",[result objectForKey:@"name"]);
	}
    
    // アラートを生成
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"FaceBookへ画像を投稿しました。"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
};

//Requestが失敗したときに呼ばれるデリゲートメソッド
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"didfailwitherror");
    NSLog(@"%@", [error localizedDescription]);
    NSLog(@"%@", [error description]);
    
    // アラートを生成
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"FaceBookへの投稿失敗しました。"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    
};

// アクセストークン情報を保存
- (void)fbDidLogin {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"didlogin");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
}

// ログアウトのコールバックハンドラ
- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    NSLog(@"didlogout");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }

}

//ログインできなかったときに呼ばれるデリゲートメソッド
-(void)fbDidNotLogin:(BOOL)cancelled {
    NSLog(@"did not login");
    [fbLoginButton setTitle:@"LogIn" forState:UIControlStateNormal];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

// Nibファイルがアンロードされた
- (void)viewDidUnload
{
    [self setCanvas:nil];
    [self setToolbar:nil];
    [self setColorEditView:nil];
    [self setColorEditButton:nil];
    [self setColorDeletButton:nil];
    [self setTopBarSpace:nil];
    [self setToolBarTop:nil];
    [self setFbLoginButton:nil];
    [super viewDidUnload];
}

// キャンバスの画像をフォトアルバムへ保存アクション
- (IBAction)saveToPhotoAlbum:(id)sender {
    SEL sel = @selector(savingImageIsFinished:didFinishSavingWithError:contextInfo:);
    UIImageWriteToSavedPhotosAlbum([self creatImage], self,  sel, nil);

}

// 画面表示してるイメージを生成する
- (UIImage*)creatImage {
    
    // -----------------------------
    // View(canvas)上のイメージのみ
    // 保存するように処理を実行する
    // -----------------------------
    toolbar.hidden = YES;
    toolBarTop.hidden = YES;
    UIGraphicsBeginImageContext(canvas.frame.size);
    [canvas.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // PNGの場合（view.alphaで指定した透明度も維持されるみたい）
    NSData *pngImage = UIImagePNGRepresentation(image);
    UIImage* dataSaveImage = [UIImage imageWithData:pngImage];
    
    toolbar.hidden = NO;
    toolBarTop.hidden = NO;
    
    return dataSaveImage;

}


// 消しゴムボタンアクション
- (IBAction)colorDelete:(id)sender {
    
    //トップバーの設定
    [self setTopBar];
    // 消しゴム設定
    [self changeDeleteEvent];

}

// ペンサイズ変更アクション
- (IBAction)penSize: (UISegmentedControl*) sender {
    
    UISegmentedControl* seg = (UISegmentedControl*) sender;
    int index = seg.selectedSegmentIndex;
    float pensize;
    if(index == 0) {
        pensize = 1;
    }
    if(index == 1) {
        pensize = 3;
    }
    if(index == 2) {
        pensize = 9;
    }
    dataManager.penSize = pensize;
}

// 画像消去アクション
- (IBAction)clear: (id)sender {
    UIImage* image = [dataManager clear];
    canvas.canvasImage = image;
    canvas.backgroundColor = [UIColor whiteColor];
}

// カラー変更ビューを表示アクション
- (IBAction)colorEdit: (id)sender {
    
    // カラー変更ビュー消去
    if( [colorEditView superview] ) {
        
        // カラー変更ビュー消去アニメ
        [self colorEditViewDownAnimation];
        // ツールバーのボタンイメージを変更する
        colorEditButton.image = [UIImage imageNamed:@"up.png"];
        
    } else {
        
        // カラー変更ビュー表示アニメ
        [self colorEditViewUpAnimation];
        // ツールバーのボタンイメージを変更する
        colorEditButton.image = [UIImage imageNamed:@"down.png"];
    }
    
}

// 写真画像ライブラリーを表示
- (IBAction)photoLibrary:(id)sender {
    
    
    // ----------------------------------
    // モーダルビューが表示されている状態の場合、
    // モーダルビューを閉じる※Ipadのみ
    // ----------------------------------
    if(!userIfIpone) {
        if(imagePopCon.popoverVisible) {
            [imagePopCon dismissPopoverAnimated:YES];
            return;
        }
    }
    
    // -----------------
    // Iphone
    // -----------------
    // モーダルビューを閉じる
    [self dismissModalViewControllerAnimated:YES];
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        
        // 取得元を設定する。フォトライブラリを指定しています。
        UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imgPicker.delegate = self;
        
        // 端末別モーダル表示切り替え
        if(userIfIpone) {
            [self photoLibrary_Iphone:imgPicker];
        } else {
            [self photoLibrary_Ipad:imgPicker sender:sender];
        }
        
    } else {
        // アラートを生成
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"フォトライブラリーがありません。"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }

}
// 写真画像ライブラリーをモーダル表示（Ipad）
- (void)photoLibrary_Ipad:(UIImagePickerController*)imgPicker sender:(id)sender{
    imagePopCon = [[UIPopoverController alloc] initWithContentViewController:imgPicker];
    [imagePopCon presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

//// 写真画像ライブラリーをモーダル表示（Iphone）
- (void)photoLibrary_Iphone:(UIImagePickerController*)imgPicker{
    [self presentModalViewController:imgPicker animated:YES];
}
//// 画像が選択された時に呼ばれるデリゲートメソッド（Iphone）
-(void)imagePickerController:(UIImagePickerController*)picker
       didFinishPickingImage:(UIImage*)image editingInfo:(NSDictionary*)editingInfo{

    // -----------------
    // Ipad
    // -----------------
    if(!userIfIpone) {
        canvas.backgroundColor = [UIColor colorWithPatternImage:image];
        // モーダルを閉じる
        [imagePopCon dismissPopoverAnimated:YES];
        return;
    }
    // -----------------
    // Iphone
    // -----------------
    // モーダルビューを閉じる
    [self dismissModalViewControllerAnimated:YES];
    //リサイズする大きさを作成
    CGImageRef imageRef = [image CGImage];
    size_t w = CGImageGetWidth(imageRef);
    size_t h = CGImageGetHeight(imageRef);
    size_t resize_w, resize_h;
    if ( w > h ) {
        resize_w = 320;
        resize_h = h * resize_w / w;
    } else {
        resize_h = 480;
        resize_w = w * resize_h / h;
    }
    // drawInRect でその領域に描画
    UIGraphicsBeginImageContext(CGSizeMake(resize_w, resize_h));
    [image drawInRect:CGRectMake(0, 0, resize_w, resize_h)];
    // イメージの取得
    image = UIGraphicsGetImageFromCurrentImageContext();
    canvas.backgroundColor =  [UIColor colorWithPatternImage:image];
    UIGraphicsEndImageContext();
}

// 消しゴムボタンのタイトルの変更及びバースペースの幅を設定
- (void)setTopBar{
    UIColor* color = nil;
    
    if(colorDeletButton.tag == 0) {
        colorDeletButton.tag = 1;
        color = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1.0];
        [colorDeletButton setTintColor:color];
        topBarSpace.width = 66;
    } else {
        colorDeletButton.tag = 0;
        [colorDeletButton setTintColor:color];
        topBarSpace.width = 60;
    }
}

// 消しゴム設定のオンとオフ
- (void)changeDeleteEvent{

    if(colorDeletButton.tag == 0) {
        
        dataManager.drawColor = dataManager.drawColorTmp;
        dataManager.penSize = dataManager.penSizeTmp;
        
    } else {
        
        UIColor* color = [UIColor colorWithRed: 1 // red
                                         green: 1 // green
                                          blue: 1 // blue
                                         alpha: 1.0];
        
        dataManager.drawColorTmp = dataManager.drawColor;
        dataManager.penSizeTmp = dataManager.penSize;
        dataManager.drawColor = color;
        dataManager.penSize = 9;
        
    }

}

// 保存完了を通知するメソッド
- (void) savingImageIsFinished:(UIImage *)_image
      didFinishSavingWithError:(NSError *)_error
                   contextInfo:(void *)_contextInfo{
    
    // アラートを生成
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"アルバムへ保存しました。"
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

// カラー変更ビュー表示アニメ
-(void) colorEditViewUpAnimation {
    
    // カラー変更ビューを画面に外に配置
    CGRect frame = colorEditView.frame;
    [self.view addSubview:colorEditView];
    colorEditView.frame = CGRectMake(0,460,frame.size.width, frame.size.height);
    
    // ツールバーを最前面に移動
    [self.view bringSubviewToFront: toolbar];

    // アニメーション設定
    CGPoint fromPt = colorEditView.layer.position;
    CGPoint toPt;
    int viewHeight = 0;

    // 端末判定
    if (userIfIpone) {
        viewHeight = -44;
    } else {
        viewHeight = 500;
    }
    
    toPt = CGPointMake(fromPt.x, fromPt.y - frame.size.height + viewHeight);
    CABasicAnimation* anime = [CABasicAnimation animationWithKeyPath:@"position.x"];
    anime.duration = 0.2;
    anime.fromValue = [NSValue valueWithCGPoint:toPt];
    
    // アニメーション開始と共にカラー変更ビューの位置を変更
    [colorEditView.layer addAnimation:anime forKey:@"animatePosition"];
    colorEditView.layer.position = toPt;
}

// アニメーション終了時に呼ばれるデリゲートメソッド
-(void) colorEditViewDownAnimation {
    
    // アニメーション設定
    CGRect frame = colorEditView.frame;
    CGPoint fromPt = colorEditView.layer.position;
    CGPoint toPt = CGPointMake(fromPt.x, fromPt.y + frame.size.height + 44);
    CABasicAnimation* anime = [CABasicAnimation animationWithKeyPath:@"animatePosition"];
    anime.duration = 0.2;
    anime.fromValue = [NSValue valueWithCGPoint:fromPt];
    
    // アニメーション終了後に削除するためデリゲートを設定
    anime.delegate = self;
    // アニメーション開始と共にカラー変更ビューの位置を変更
    [self dismissModalViewControllerAnimated:YES];
    [colorEditView.layer addAnimation:anime forKey:@"animetePosition"];    
    colorEditView.layer.position = toPt;

}

// アニメーション終了時に呼ばれるデリゲートメソッド
-(void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag  {
    
    if(flag) {
        // カラー変更ビューを削除
        [colorEditView removeFromSuperview];
    }

}

// ColorEditViewのデリゲートメソッド実装部
-(void) colorEditViewColorCreated: (ColorEditView*) colorEdit Color:(UIColor *)color {
    dataManager.drawColor = color;
}

// CanvasViewのデリゲートメソッド実装部：　タッチダウン
- (void) canvasViewTouchesBegan: (CanvasView*) contentView Location: (CGPoint) pt {
    
    // カラー変更パネルが表示されたらいったん隠す
    if([colorEditView subviews]) {
        colorEditView.hidden = YES;
    }
    [dataManager drawStart:pt];
}

// CanvasViewのデリゲートメソッド実装部： タッチムーブ
- (void) canvasViewTouchesMoved: (CanvasView*) contentView Location: (CGPoint) pt{
    
    UIImage* image = [dataManager drawMoved:pt];
    canvas.canvasImage = image;
    
}

// CanvasViewのデリゲートメソッド実装部： タッチエンド
- (void) canvasViewTouchesEnded: (CanvasView*) contentView Location: (CGPoint) pt{
    
    // カラー変更パネルが表示されていたら再表示
    if([colorEditView subviews] && colorEditView.hidden) {
        colorEditView.hidden = NO;
    }
    
}

@end
