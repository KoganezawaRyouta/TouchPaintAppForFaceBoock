//
//  ColorEditView.h
//  TouchPaintApp
//
//  Created by fexd on 2012/08/14.
//  Copyright (c) 2012年 Fexd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorEditView : UIView {
    
    id delegate;
    float red;
    float green;
    float blue;
    
}
@property (strong, nonatomic) id delegate;

@property (strong, nonatomic) IBOutlet UIView *colorPreview;
@property (strong, nonatomic) IBOutlet UISlider *redSlider;
@property (strong, nonatomic) IBOutlet UISlider *greenSlider;
@property (strong, nonatomic) IBOutlet UISlider *blueSlider;

- (IBAction)sliderAction:(UISlider *)sender;

@end


@protocol ColorEditViewDelegate <NSObject>

- (void) colorEditViewColorCreated: (ColorEditView*) colorEdit Color:(UIColor*) color;

@end