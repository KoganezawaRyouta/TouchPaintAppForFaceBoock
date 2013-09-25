//
//  ViewController.h
//  TouchPaintApp
//
//  Created by fexd on 2012/08/13.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JSON.h"
#import "FBConnect.h"

@class CanvasView;
@class ColorEditView;
@class DataManager;

@interface ViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate,UITextFieldDelegate,FBSessionDelegate,FBRequestDelegate,FBDialogDelegate>{
    UIToolbar* toolbar;            // ツールバー
    CanvasView* canvas;            // 描画用キャンパスビュー
    ColorEditView* colorEditView;  // カラー変更用パネル
    DataManager* dataManager;      // データマネージャー
    Facebook *facebook;
    NSArray* permissions;
    NSUserDefaults *standardUserDefaults;
    IBOutlet UIToolbar *toolBarTop;
    Boolean userIfIpone;
}
@property (strong, nonatomic) IBOutlet UIButton *fbLoginButton;
@property (strong, nonatomic) IBOutlet UIToolbar *toolBarTop;
@property (strong, nonatomic) IBOutlet UIToolbar* toolbar;
@property (strong, nonatomic) IBOutlet CanvasView* canvas;
@property (strong, nonatomic) IBOutlet ColorEditView* colorEditView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *colorEditButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *colorDeletButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *topBarSpace;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) NSArray *permissions;
@property Boolean userIfIpone;

// アクションメソッド
- (IBAction)penSize: (UISegmentedControl*) sender;
- (IBAction)clear: (id)sender;
- (IBAction)colorEdit: (id)sender;
- (IBAction)saveToPhotoAlbum: (id)sender;
- (IBAction)colorDelete:(id)sender;
- (IBAction)photoLibrary:(id)sender;
- (IBAction)fbLogin:(id)sender;
- (IBAction)fbUpload:(id)sender;

// インスタンスメソッド
-(void) colorEditViewUpAnimation;
-(void) colorEditViewDownAnimation;

@end
