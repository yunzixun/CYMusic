//
//  ViewController.m
//  01-距离传感器
//
//  Created by xiaomage on 15/8/20.
//  Copyright (c) 2015年 叫兽. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "CYAudioManager.h"
#import <MediaPlayer/MediaPlayer.h>

#define CYDocPath(_fileName_) [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@",_fileName_]]
#define CYBundlePath(_fileName_)  [[NSBundle mainBundle] pathForResource:_fileName_ ofType:nil]
#define URLString @"http://m6.file.xiami.com/198/1198/6069/377539_22465_h.mp3?auth_key=0ae1b8a1347dea88346347bedc5b8606-1455580800-0-null"
@interface ViewController ()<CYAudioManagerDelegate>
@property (nonatomic,strong) AVAudioPlayer *player;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // 设置播放声音为0.1
    [self.progressView setThumbImage:[UIImage imageNamed:@"playbar_slider_thumb"] forState:UIControlStateNormal];
    [self.switchView setOn:YES animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(volumeChanged:) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
    [self setSystemVolom:1];
    
    [self selectMusicAtIndex:self.currentIndex];
    
}
/**
 *  系统音量改变时的通知
 */
- (void)volumeChanged:(NSNotification*)noti
{
    NSString *string = noti.userInfo[@"AVSystemController_AudioVolumeNotificationParameter"];
    self.volSlider.value = [string floatValue];
    
}
/**
 *  播放或暂停
 */
- (IBAction)playBtnClick:(UIButton *)btn {
    btn.selected = !btn.selected;
    if (btn.selected) {
        [CYAudioManager pausePlaySound];
    }else{
        [CYAudioManager continuePlaySound];
    }
}
/**
 *  上一曲
 */
- (IBAction)previousClick:(UIButton *)sender {
    [[CYAudioManager shareInstance]setDragging:YES];
    if (self.currentIndex == 0) {
        self.currentIndex = self.musicList.count - 1;
    }else{
        self.currentIndex--;
    }
    [self replaceMusicAtIndex:self.currentIndex];
}
/**
 *  下一曲
 */
- (IBAction)nextClick:(UIButton *)sender {
    [[CYAudioManager shareInstance]setDragging:YES];
    self.currentIndex ++;
    if (self.currentIndex>self.musicList.count-1) {
        self.currentIndex = 0;
    }
    [self replaceMusicAtIndex:self.currentIndex];
}
/**
 *  中间切换歌曲
 */
- (void)replaceMusicAtIndex:(NSInteger)index
{
    AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:[self getMusicURLAtIndex:index]];
    [CYAudioManager replaceAVPlayItem:item];
    [[CYAudioManager shareInstance]setDragging:NO];
    self.playButton.selected = NO;
}
/**
 *  第一次正常播放初始化
 */
- (void)selectMusicAtIndex:(NSInteger)index
{
    [CYAudioManager startPlaySoundWithURL:[self getMusicURLAtIndex:index]];
    [[CYAudioManager shareInstance] setDelegate:self];
}
- (NSURL*)getMusicURLAtIndex:(NSInteger)index
{
    NSString *music = [NSString stringWithFormat:@"%@.mp3",self.musicList[self.currentIndex]];
    self.title = music;
    NSString *path = CYBundlePath(music);
    return [NSURL fileURLWithPath:path];
}
/**
 *  开始播放的代理方法
 */
- (void)cyAudioManagerDidStartPlaySoundWithTotalTime:(double)totalTime
{
    // 每次播放前初始化进度条
    self.progressView.maximumValue = totalTime;
    self.progressView.value   = 0;
}
/**
 *  播放器的进度
 */
- (void)cyAudioManagerCurrenTime:(double)currentTime totalTime:(double)totalTime
{
    self.progressView.value = currentTime;
    NSString *time1 = [CYAudioManager getMinuteSecondWithSecond:currentTime];
    NSString *time2 = [CYAudioManager getMinuteSecondWithSecond:totalTime];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",time1,time2];
}

- (void)cyAudioManagerDidFinishPlaySound
{
    // 播放完毕默认播放下一曲
    [self nextClick:nil];
}

- (void)cyAudioManagerAVPlayerStatusFailed:(NSError *)error
{
    NSLog(@"------> %@",error.localizedDescription);
}
/**
 *   手动设置播放时间
 */
- (IBAction)changeValue:(UISlider *)sender {
    [[CYAudioManager shareInstance] setVolume:sender.value];
    [self setSystemVolom:sender.value];
}
- (void)setSystemVolom:(CGFloat)value
{
    MPMusicPlayerController *mp=[MPMusicPlayerController applicationMusicPlayer];
    mp.volume= value;//0为最小1为最大
}
/**
 *  点击滑块就停止播放 和 设置 Dragging = YES
 */
- (IBAction)touch:(id)sender {
    [[CYAudioManager shareInstance] setDragging:YES];
    [CYAudioManager pausePlaySound];
}
/**
 *  松开滑块重新播放
 */
- (IBAction)replay:(UISlider *)sender
{
    [[CYAudioManager shareInstance] setDragging:NO];
    if (sender.value==sender.maximumValue) {
        [self nextClick:nil];
    }else{
        [CYAudioManager continuePlaySound];
    }
    if (self.playButton.selected) {
        self.playButton.selected = NO;
    }
}
- (IBAction)change:(UISlider *)sender
{
    [[CYAudioManager shareInstance] setCurrentTime:sender.value];
    NSString *time1 = [CYAudioManager getMinuteSecondWithSecond:sender.value];
    NSString *time2 = [CYAudioManager getMinuteSecondWithSecond:[[CYAudioManager shareInstance] totalTime]];
    self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",time1,time2];
}
- (IBAction)switchChange:(UISwitch *)sender {
    
    [[CYAudioManager shareInstance]setIsPlaybackAvailable:sender.isOn];
}

- (void)dealloc
{
    [CYAudioManager stopPlaySound];
}

@end
