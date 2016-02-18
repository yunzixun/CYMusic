//
//  CYAudioManager.h
//  01-距离传感器
//
//  Created by dongzb on 16/2/11.
//  Copyright © 2016年 叫兽. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CYAudioManagerDelegate <NSObject>

@optional

/** <开始播放的代理事件> */
- (void)cyAudioManagerDidStartPlaySoundWithTotalTime:(double)totalTime;
/** <播放音频文件结束> */
- (void)cyAudioManagerDidFinishPlaySound;
/** <播放失败> */
- (void)cyAudioManagerAVPlayerStatusFailed:(NSError* _Nonnull )error;
/** <获取当前播放音乐的进度> */
- (void)cyAudioManagerCurrenTime:(double)currentTime totalTime:(double)totalTime;

@end

@interface CYAudioManager : NSObject

NS_ASSUME_NONNULL_BEGIN

/** <实例化音频管理者的实例> */
+ (instancetype)shareInstance;
/** 初始化一个 AVRecord对象并制定录制文件的保存位置 */
+ (void)startRecordWithURL:(NSURL*)url;
/** <停止录音> */
+ (void)stopRecord;
/** <暂停录音> */
+ (void)pauseRecord;
/** <继续录音> */
+ (void)continueRecord;
/** <开始播放音频文件> */
+ (void)startPlaySoundWithURL:(NSURL*)url;
/** <暂停播放音频文件> */
+ (void)pausePlaySound;
/** <继续播放音频文件> */
+ (void)continuePlaySound;
/** <停止播放音频文件> */
+ (void)stopPlaySound;
/** <时间戳转成字符串> */
+ (NSString *)getMinuteSecondWithSecond:(NSTimeInterval)time;
/** <替换播放的item,用于切换下一个播放内容> */
+ (void)replaceAVPlayItem:(AVPlayerItem*)playItem;
/** < 音频文件声音大小 > */
@property (nonatomic,assign) float volume;
/** < 是否可以播放音频文件 > */
@property (nonatomic,assign) BOOL isPlaySoundAvailable;
/** < 是否开启扬声器 > */
@property (nonatomic,assign) BOOL isPlaybackAvailable;
/** <delegate> */
@property (nonatomic,weak) id<CYAudioManagerDelegate>delegate;
/** < 是否正在拖拽 > */
@property(assign,nonatomic,getter=isDragging)BOOL dragging;
/** < 设置当前播放时间 > */
@property (nonatomic,assign) float currentTime;
/** < 音频文件的总播放时间 > */
@property (nonatomic,assign) float totalTime;

NS_ASSUME_NONNULL_END

@end
