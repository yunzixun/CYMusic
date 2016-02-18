//
//  CYAudioManager.m
//  01-距离传感器
//
//  Created by dongzb on 16/2/11.
//  Copyright © 2016年 叫兽. All rights reserved.
//

#import "CYAudioManager.h"
@interface CYAudioManager ()<AVAudioPlayerDelegate,AVAudioRecorderDelegate>
/** <音频播放器> */
@property (nonatomic,strong) AVPlayer *audioPlayer;
/** <录音器> */
@property (nonatomic,strong) AVAudioRecorder *recorder;
/** <定时器> */
@property (nonatomic,strong) NSTimer *timer;
/** <当前播放的item> */
@property (nonatomic,strong) AVPlayerItem *currentPlayItem;

@end

@implementation CYAudioManager

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static CYAudioManager *_audioManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _audioManager = [super allocWithZone:zone];
        _audioManager.isPlaySoundAvailable  = YES;
        _audioManager.isPlaybackAvailable   = YES;
        _audioManager.volume                = 1.0f;
    });
    return _audioManager;
}
/** <实例化录音管理者的实例> */
+ (instancetype)shareInstance
{
    return [[super alloc] init];
}
- (AVPlayer *)audioPlayer
{
    if (!_audioPlayer) {
        _audioPlayer = [[AVPlayer alloc] init];
    }
    return _audioPlayer;
}
#pragma mark - 录音机的一些方法
/** 初始化一个 AVRecord对象并制定录制文件的保存位置 */
+ (void)startRecordWithURL:(NSURL *)url
{
    [self stopRecord];
    CYAudioManager *manager    = [CYAudioManager shareInstance];
    NSError *error = nil;
    AVAudioRecorder *recorder  = [[AVAudioRecorder alloc] initWithURL:url settings:@{} error:&error];
    [recorder prepareToRecord];
    [recorder record];
    manager.recorder           = recorder;
    manager.recorder.delegate  = manager;
}
/** <暂停录音> */
+ (void)pauseRecord
{
    CYAudioManager *manager = [CYAudioManager shareInstance];
    [manager.recorder pause];
}
/** <继续录音> */
+ (void)continueRecord
{
    CYAudioManager *manager = [CYAudioManager shareInstance];
    [manager.recorder record];
}
/** <停止录音> */
+ (void)stopRecord
{
    if ([[self shareInstance] recorder]) {
        CYAudioManager *manager = [CYAudioManager shareInstance];
        [manager.recorder stop];
        manager.recorder = nil;
    }
}
#pragma mark - 媒体播放器的一些方法
/** <开始播放音频文件> */
+ (void)startPlaySoundWithURL:(NSURL*)url
{
    if (![[self shareInstance] isPlaySoundAvailable]) return;
    CYAudioManager *manager = [CYAudioManager shareInstance];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
            [self replaceAVPlayItem:playerItem];
            manager.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:manager selector:@selector(update) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:manager.timer forMode:NSRunLoopCommonModes];
            [manager.timer fire];
            manager.dragging = NO;
        });
    });
}
/** <每隔1秒更新当前播放的进度> */
- (void)update
{
    if (self.audioPlayer&&self.currentPlayItem.status == AVPlayerItemStatusReadyToPlay &&!self.isDragging) {
        double currentTime = CMTimeGetSeconds(self.currentPlayItem.currentTime);
        double totalTime   = CMTimeGetSeconds([[self.currentPlayItem asset] duration]);
        //  修正了播放完毕后 currenTime 为零点几的问题
        if ((int)currentTime==(int)totalTime) {
            [self invalidateTimer];
            currentTime = totalTime;
        }
        if ([self.delegate respondsToSelector:@selector(cyAudioManagerCurrenTime:totalTime:)]) {
            [self.delegate cyAudioManagerCurrenTime:currentTime totalTime:totalTime];
        }
    }
}
/** <暂停播放音频文件> */
+ (void)pausePlaySound
{
    CYAudioManager *manager = [CYAudioManager shareInstance];
    [manager.audioPlayer pause];
}
/** <继续播放音频文件> */
+ (void)continuePlaySound
{
    CYAudioManager *manager = [CYAudioManager shareInstance];
    [manager.audioPlayer play];
}
/** <停止播放音频文件> */
+ (void)stopPlaySound
{
    if ([[self shareInstance] audioPlayer]&&[[self shareInstance] currentPlayItem]) {
        CYAudioManager *manager = [CYAudioManager shareInstance];
        manager.audioPlayer.rate = 0.0f;
        [manager removeAVPlayerItemObserver];
        [manager removeNotification];
        manager.currentPlayItem = nil;
        manager.audioPlayer = nil;
        [manager invalidateTimer];
    }
}
/** <替换播放的item,用于切换下一个播放内容> */
+ (void)replaceAVPlayItem:(AVPlayerItem*)playItem
{
    [[self shareInstance]removeAVPlayerItem];
    AVPlayer *player = [[self shareInstance] audioPlayer];
    CYAudioManager *manager = [CYAudioManager shareInstance];
    manager.currentPlayItem = playItem;
    // 添加通知和监听
    [[self shareInstance] addAVPlayerItemObserver];
    [[self shareInstance]addNotification];
    [player replaceCurrentItemWithPlayerItem:manager.currentPlayItem];
    [player play];
}
/**
 *  移除旧的 item
 */
- (void)removeAVPlayerItem
{
    [self removeAVPlayerItemObserver];
    [self removeNotification];
    self.currentPlayItem = nil;
}
/**
 *  销毁定时器
 */
- (void)invalidateTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
/**
 *  时间戳转成字符串
 */
+(NSString *)getMinuteSecondWithSecond:(NSTimeInterval)time{
    int minute = (int)time / 60;
    int second = (int)time % 60;
    if (second > 9) {
        return [NSString stringWithFormat:@"%d:%d",minute,second];
    }
    return [NSString stringWithFormat:@"%d:0%d",minute,second];
}
#pragma mark - 添加监听playItem的属性
- (void)removeAVPlayerItemObserver{
    [self.currentPlayItem removeObserver:self forKeyPath:@"status"];
    [self.currentPlayItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    self.currentPlayItem = nil;
}
#pragma mark - 移除监听playItem的属性
- (void)addAVPlayerItemObserver{
    [self.currentPlayItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //监控网络加载情况属性
    [self.currentPlayItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
}
#pragma mark - 监听播放器播放完毕的通知
/**
 *  添加播放器通知
 */
-(void)addNotification{
    //给AVPlayerItem添加播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playstucking) name:AVPlayerItemPlaybackStalledNotification object:self.currentPlayItem];
}
-(void)removeNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:self.currentPlayItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:self.currentPlayItem];
}
/**
 *  播放完毕的通知
 */
-(void)playbackFinished:(NSNotification *)notification{
    [CYAudioManager pausePlaySound];
    if ([self.delegate respondsToSelector:@selector(cyAudioManagerDidFinishPlaySound)]) {
        [self.delegate cyAudioManagerDidFinishPlaySound];
    }
}
/**
 *  播放卡顿
 *
 *  @param notification 通知对象
 */
- (void)playstucking
{
    NSLog(@"播放卡顿");
}
#pragma mark - 监听播放器 playitem 属性的变化
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        if (self.currentPlayItem.status == AVPlayerStatusReadyToPlay) {
            double totalSecond = CMTimeGetSeconds([[self.currentPlayItem asset] duration]);
            [self.delegate respondsToSelector:@selector(cyAudioManagerDidStartPlaySoundWithTotalTime:)];
            [self.delegate cyAudioManagerDidStartPlaySoundWithTotalTime:totalSecond];
            self.totalTime = totalSecond;
        }else if (self.currentPlayItem.status == AVPlayerStatusFailed) {
            if ([self.delegate respondsToSelector:@selector(cyAudioManagerAVPlayerStatusFailed:)]) {
                [self.delegate cyAudioManagerAVPlayerStatusFailed:self.currentPlayItem.error];
            }
        }
    }
}
#pragma mark - setter方法设置播放器的一些属性
/** <切换扬声器和听筒模式> */
- (void)setIsPlaybackAvailable:(BOOL)isPlaybackAvailable
{
    _isPlaybackAvailable    = isPlaybackAvailable;
    [[AVAudioSession sharedInstance]setActive:YES error:nil];
    if (_isPlaybackAvailable) {
        //默认情况下扬声器播放
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }else{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
}
/** <设置播放音量> */
- (void)setVolume:(float)volume
{
    _volume = volume;
    self.audioPlayer.volume = _volume;
}
/** < 设置当前播放时间 >*/
- (void)setCurrentTime:(float)currentTime
{
    _currentTime    = currentTime;
    [self.audioPlayer seekToTime:CMTimeMakeWithSeconds(currentTime, NSEC_PER_SEC) toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}
#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag
{
    [CYAudioManager stopRecord];
}


@end
