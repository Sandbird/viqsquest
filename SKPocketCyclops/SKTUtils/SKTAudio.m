
@import AVFoundation;

#import "SKTAudio.h"

@interface SKTAudio()
@property (nonatomic) AVAudioPlayer *backgroundMusicPlayer;
@property (nonatomic) AVAudioPlayer *soundEffectPlayer;
@end

@implementation SKTAudio

+ (instancetype)sharedInstance {
  static dispatch_once_t pred;
  static SKTAudio *sharedInstance;
  dispatch_once(&pred, ^{
      sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (id)init {
    self.isMuted = NO;
    return self;
}

- (void)playBackgroundMusic:(NSString *)filename {
    NSError *error;
    NSURL *backgroundMusicURL = [[NSBundle mainBundle] URLForResource:filename withExtension:nil];
    self.backgroundMusicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:backgroundMusicURL error:&error];
    self.backgroundMusicPlayer.numberOfLoops = -1;
    
    [self.backgroundMusicPlayer setVolume:self.isMuted ? 0 : 1];
    
    [self.backgroundMusicPlayer prepareToPlay];
    [self.backgroundMusicPlayer play];
}

- (void)pauseBackgroundMusic {
  [self.backgroundMusicPlayer pause];
}

- (void)resumeBackgroundMusic {
  [self.backgroundMusicPlayer play];
}

- (void)playSoundEffect:(NSString*)filename {
    if (self.soundEffectPlayer) {
        [self.soundEffectPlayer stop];
        self.soundEffectPlayer = nil;
    }
    
    NSError *error;
    NSURL *soundEffectURL = [[NSBundle mainBundle] URLForResource:filename withExtension:@"mp3"];
    self.soundEffectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:soundEffectURL error:&error];
    
    self.soundEffectPlayer.numberOfLoops = 0;
    self.soundEffectPlayer.delegate = self;
    [self.soundEffectPlayer prepareToPlay];
    [self.soundEffectPlayer play];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
    if (flag && self.soundEffectPlayer == player) {
        [self resumeBackgroundMusic];
        self.soundEffectPlayer = nil;
    }
}

- (void)muteAudio {
    self.isMuted = YES;
    
    if (self.backgroundMusicPlayer) {
        [self.backgroundMusicPlayer setVolume:0];
    }
}

- (void)unmuteAudio {
    self.isMuted = NO;
    
    if (self.backgroundMusicPlayer) {
        [self.backgroundMusicPlayer setVolume:1];
    }
}

@end
