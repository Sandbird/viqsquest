#import <AVFoundation/AVFoundation.h>

@interface SKTAudio : NSObject <AVAudioPlayerDelegate>

+ (instancetype)sharedInstance;
@property (nonatomic, assign) BOOL isMuted;

- (void)playBackgroundMusic:(NSString *)filename;
- (void)pauseBackgroundMusic;
- (void)resumeBackgroundMusic;

- (void)muteAudio;
- (void)unmuteAudio;

- (void)playSoundEffect:(NSString *)filename;

@end
