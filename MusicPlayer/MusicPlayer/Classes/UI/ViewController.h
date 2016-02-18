//
//  ViewController.h
//  01-距离传感器
//
//  Created by xiaomage on 15/8/20.
//  Copyright (c) 2015年 叫兽. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISlider *volSlider;

- (IBAction)changeValue:(UISlider *)sender;
@property (weak, nonatomic) IBOutlet UISlider *progressView;
- (IBAction)touch:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
- (IBAction)switchChange:(UISwitch *)sender;
@property (weak, nonatomic) IBOutlet UISwitch *switchView;

@property (nonatomic,strong) NSArray *musicList;

@property (nonatomic,assign) NSInteger currentIndex;
- (IBAction)playBtnClick:(UIButton *)sender;
- (IBAction)previousClick:(UIButton *)sender;
- (IBAction)nextClick:(UIButton *)sender;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@end

