//
//  PSKHUDNode.m
//  SKPocketCyclops
//
//  Created by William Zhang on 4/13/14.
//  Copyright (c) 2014 Razeware, LLC. All rights reserved.
//

#import "PSKHUDNode.h"
#import "SKTAudio.h"

#import "PSKSharedTextureCache.h"
#import "PSKGameManager.h"

#import "Level.h"
#import "GPlayer.h"

@interface PSKHUDNode ()

// determine whether arrowbutton is pressed and whether arrow is locked
@property (nonatomic, assign) BOOL arrowButtonPressed;
@property (nonatomic, assign) BOOL arrowLock;

// life indiciator
@property (nonatomic, strong) SKSpriteNode *lifeBarImage;

// left right jump images
@property (nonatomic, strong) SKSpriteNode *leftButton;
@property (nonatomic, strong) SKSpriteNode *rightButton;
@property (nonatomic, strong) SKSpriteNode *jumpButton;
@property (nonatomic, strong) SKSpriteNode *arrowButton;

// uc gathered images
@property (nonatomic, strong) SKSpriteNode *firstUC;
@property (nonatomic, strong) SKSpriteNode *secondUC;
@property (nonatomic, strong) SKSpriteNode *thirdUC;

// label nodes
@property (nonatomic, strong) SKLabelNode *coinLabel;
@property (nonatomic, strong) SKLabelNode *arrowLabel;
@property (nonatomic, strong) SKLabelNode *timeLabel;

// scoring
@property (nonatomic, strong) SKLabelNode *scored;
@property (nonatomic, strong) SKLabelNode *scoreLabel;

// texture atlases
@property (nonatomic, strong) SKTextureAtlas *atlas;

// pause
@property (nonatomic, strong) SKSpriteNode *pauseButton;

// button array for iteration
@property (nonatomic, strong) NSArray *buttons;

@end

@implementation PSKHUDNode
@synthesize scored;

- (id)initWithSize:(CGSize)size level:(Level *)level atlas:(SKTextureAtlas *)atlas {
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        
        // set atlas and levelObject
        self.atlas = atlas;
        Level *levelObject = level;
        
        // create lifebar and position
        self.lifeBarImage = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Life_Bar_5_5.png"]];
        self.lifeBarImage.position = CGPointMake(64, size.height - 30);
        [self addChild:self.lifeBarImage];
        
        // create left button and position
        self.leftButton = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"leftButton.png"]];
        self.leftButton.position = CGPointMake(50, 60);
        [self addChild:self.leftButton];
        
        // create right button and position
        self.rightButton = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"rightButton.png"]];
        self.rightButton.position = CGPointMake(130, 60);
        [self addChild:self.rightButton];
        
        // create jump button and position
        self.jumpButton = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"jumpButton.png"]];
        self.jumpButton.position = CGPointMake(size.width - 150, 60);
        [self addChild:self.jumpButton];
        
        // create arrow button and position
        self.arrowButton = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"Arrow.png"]];
        self.arrowButton.position = CGPointMake(size.width - 50, 100);
        [self addChild:self.arrowButton];
        
        // create pause button and position
        self.pauseButton = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"pause.png"]];
        self.pauseButton.position = CGPointMake(size.width - 40, size.height - 40);
        [self addChild:self.pauseButton];
        
        // create 3rd UC and position
        self.thirdUC = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        self.thirdUC.position = CGPointSubtract(self.pauseButton.position, CGPointMake(55, 0));
        [self addChild:self.thirdUC];
        
        // create 2nd UC and position
        self.secondUC = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        self.secondUC.position = CGPointSubtract(self.thirdUC.position, CGPointMake(55, 0));
        [self addChild:self.secondUC];
        
        // create 1st UC and position
        self.firstUC = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"swordGoldMissing.png"]];
        self.firstUC.position = CGPointSubtract(self.secondUC.position, CGPointMake(55, 0));
        [self addChild:self.firstUC];
        
        // get the player object
        Player *p = [[PSKGameManager sharedManager] player];
        
        // show how many arrows are left. create and position
        self.arrowLabel = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        self.arrowLabel.text = [NSString stringWithFormat:@"%d",[[p arrowsLeft] intValue]];
        self.arrowLabel.fontSize = 30.0;
        self.arrowLabel.position = CGPointMake(self.pauseButton.position.x, size.height - 100);
        [self addChild:self.arrowLabel];
        
        float pos = self.arrowLabel.frame.size.height / 2;
        SKSpriteNode *arrowNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"ArrowIcon.png"]];
        arrowNode.position = CGPointMake(size.width - 80, self.arrowLabel.position.y + pos);
        [self addChild:arrowNode];
        
        // show how many coins are left, create and position
        self.coinLabel = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        self.coinLabel.text = [NSString stringWithFormat:@"%d",[p.coins intValue]];
        self.coinLabel.fontSize = 30.0;
        self.coinLabel.position = CGPointMake(self.pauseButton.position.x, size.height - 130);
        [self addChild:self.coinLabel];
        
        pos = self.coinLabel.frame.size.height / 2;
        SKSpriteNode *coinNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"CoinIcon.png"]];
        coinNode.position = CGPointMake(size.width - 80, self.coinLabel.position.y + pos);
        [self addChild:coinNode];
        
        // show how many seconds are left, create and position
        self.timeLabel = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        self.timeLabel.text = [NSString stringWithFormat:@"%d",[[levelObject timeLimit] intValue]];
        self.timeLabel.fontSize = 30.0;
        self.timeLabel.position = CGPointMake(60, size.height - 85);
        [self addChild:self.timeLabel];
        
        pos = self.timeLabel.frame.size.height / 2;
        SKSpriteNode *timeNode = [SKSpriteNode spriteNodeWithTexture:[atlas textureNamed:@"timer.png"]];
        timeNode.position = CGPointMake(25, self.timeLabel.position.y + pos);
        [self addChild:timeNode];
        
        // show score position
        scored = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        scored.text = @"Score: ";
        scored.fontSize = 30.0;
        scored.position = CGPointMake(50, timeNode.position.y - 50);
        [self addChild:scored];
        
        // show score label, create and position
        self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"OldeEnglish-Regular"];
        self.scoreLabel.text = @"0";
        self.scoreLabel.fontSize = 30.0;
        self.scoreLabel.position = CGPointMake(scored.position.x + scored.frame.size.width, scored.position.y);
        [self addChild:self.scoreLabel];
        
        // create button array
        self.buttons = @[self.leftButton, self.rightButton, self.jumpButton, self.arrowButton, self.pauseButton];
        
        self.jumpState = kJumpButtonOff;
        self.joyDirection = kJoyDirectionNone;
    }
    
    return self;
}

#pragma mark - Touches

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    // iterate through all touches
    for (UITouch *touch in touches) {
        // get location relative to the hud
        CGPoint touchLocation = [touch locationInNode:self];
        
        for (SKSpriteNode *button in self.buttons) {
            if (CGRectContainsPoint(button.frame, touchLocation)) {
                // check buttons and call methods
                if (button == self.jumpButton) {
                    // send jump
                    [self sendJump:YES];
                } else if (button == self.leftButton) {
                    // send direction left
                    [self sendDirection:kJoyDirectionLeft];
                } else if (button == self.rightButton) {
                    // send direction right
                    [self sendDirection:kJoyDirectionRight];
                } else if (button == self.arrowButton) {
                    // send arrow fire
                    [self sendArrowChange:YES];
                } else if (button == self.pauseButton) {
                    // send pause button
                    [self pause];
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    // iterate through touches and get position relative to node
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        for (SKSpriteNode *button in self.buttons) {
            if (CGRectContainsPoint(button.frame, touchLocation)) {
                if (button == self.jumpButton) {
                    // send jump NO
                    [self sendJump:NO];
                } else if (button == self.arrowButton) {
                    // send arrowChange NO
                    [self sendArrowChange:NO];
                } else {
                    // send direction to none
                    [self sendDirection:kJoyDirectionNone];
                }
            }
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        // get previous location and current location
        CGPoint touchLocation = [touch locationInNode:self];
        CGPoint previousTouchLocation = [touch previousLocationInNode:self];
        for (SKSpriteNode *button in self.buttons) {
            // if slide release. previous was in, now is not
            if (CGRectContainsPoint(button.frame, previousTouchLocation) &&
                !CGRectContainsPoint(button.frame, touchLocation))  {
                // check button and act appropriately
                if (button == self.jumpButton) {
                    [self sendJump:NO];
                } else if (button == self.arrowButton) {
                    [self sendArrowChange:NO];
                }else {
                    [self sendDirection:kJoyDirectionNone];
                }
            }
        }
    
        // if slide enter, previous out, now in
        for (SKSpriteNode *button in self.buttons) {
            if (!CGRectContainsPoint(button.frame, previousTouchLocation) &&
                CGRectContainsPoint(button.frame, touchLocation)) {
                
                //We don't get another jump on a slide-on, we want the
                //player to let go of the button for another jump
                if (button == self.rightButton) {
                    [self sendDirection:kJoyDirectionRight];
                } else if (button == self.leftButton) {
                    [self sendDirection:kJoyDirectionLeft];
                }
            }
        }
    }
}

#pragma mark - Movement

// load texture, to change the skspritenode's image
- (void)sendJump:(BOOL)jumpOn {
    if (jumpOn) {
        self.jumpState = kJumpButtonOn;
        [self.jumpButton setTexture:[_atlas textureNamed:@"jumpButtonPressed.png"]];
    } else {
        self.jumpState = kJumpButtonOff;
        [self.jumpButton setTexture:[_atlas textureNamed:@"jumpButton.png"]];
    }
}

// change boolean values correctly and update the state images
- (void)sendDirection:(JoystickDirection)direction {
    if (direction == kJoyDirectionLeft) {
        self.joyDirection = kJoyDirectionLeft;
        
        [self.rightButton setTexture:[_atlas textureNamed:@"rightButton.png"]];
        [self.leftButton setTexture:[_atlas textureNamed:@"leftButtonPressed.png"]];
    } else if (direction == kJoyDirectionRight) {
        self.joyDirection = kJoyDirectionRight;
        
        [self.rightButton setTexture:[_atlas textureNamed:@"rightButtonPressed.png"]];
        [self.leftButton setTexture:[_atlas textureNamed:@"leftButton.png"]];
    } else {
        self.joyDirection = kJoyDirectionNone;
        
        [self.rightButton setTexture:[_atlas textureNamed:@"rightButton.png"]];
        [self.leftButton setTexture:[_atlas textureNamed:@"leftButton.png"]];
    }
}

// arrowLock to not allow repeatedly fire
// update texture, check if can fire and then fire the arrow
// update the arrowLabel text
- (void)sendArrowChange:(BOOL)arrowFiring {
    if (arrowFiring && !self.arrowLock) {
        self.arrowLock = YES;
        [self.arrowButton setTexture:[_atlas textureNamed:@"ArrowPressed.png"]];
        
        if ([self.arrowLabel.text intValue] > 0) {
            if ([self.delegate respondsToSelector:@selector(fireArrow)]) {
                [self.delegate fireArrow];
            }
            
            int arrowLeft = [self.arrowLabel.text intValue];
            arrowLeft = arrowLeft - 1;
            self.arrowLabel.text = [NSString stringWithFormat:@"%d",arrowLeft];
        }
    } else {
        self.arrowLock = NO;
        [self.arrowButton setTexture:[_atlas textureNamed:@"Arrow.png"]];
    }
}

#pragma mark - Life Setting

- (void)setLife:(CGFloat)life {
    // calculate heart left and retrieve iamge
    int num = (int)(life * 5);
    NSString *lifeFrame = [NSString stringWithFormat:@"Life_Bar_%d_5.png",num];
    
    // set texture and set size
    [self.lifeBarImage setTexture:[_atlas textureNamed:lifeFrame]];
    [self.lifeBarImage setSize:self.lifeBarImage.texture.size];
    [self.lifeBarImage setName:lifeFrame];
}

#pragma mark - Score Setting

// add score to scoreLabel
// reposition accordingly
- (void)addScore:(int)scor {
    int currentScore = [self.scoreLabel.text intValue];
    currentScore = currentScore + scor;
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",currentScore];
    self.scoreLabel.position = CGPointMake(scored.position.x + scored.frame.size.width, self.scoreLabel.position.y);
}

// set the scoreLabel's score
- (void)setScore:(int)scor {
    self.scoreLabel.text = [NSString stringWithFormat:@"%d",scor];
    self.scoreLabel.position = CGPointMake(scored.position.x + scored.frame.size.width, self.scoreLabel.position.y);
}

// return the scoreLabel's int value
- (int)getScore {
    return [self.scoreLabel.text intValue];
}

#pragma mark - Coin

// add a coin to the coinLabel. if there is 100, add 1 to the player's life and/or +1/5 of life
- (void)addCoin {
    int coinCount = [self.coinLabel.text intValue] + 1;
    if (coinCount == 100) {
        coinCount = 0;
        
        CGFloat life = self.player.life + 100;
        
        if (life <= 500) {
            CGFloat flo = life/500;
            [self setLife:flo];
            
            int l = [[PSKGameManager sharedManager] getLives] + 1;
            [[PSKGameManager sharedManager] setLifeToPlayer:l];
            [[PSKGameManager sharedManager] savePlayer];
        }
    }
    
    self.coinLabel.text = [NSString stringWithFormat:@"%d",coinCount];
}

// return number of coins
- (int)getCoin {
    return [self.coinLabel.text intValue];
}

#pragma mark - UC Gathering

// set the firstUC's gathered iamge
- (void)setFirstGathered {
    [self.firstUC setTexture:[self.atlas textureNamed:@"swordGoldExisting.png"]];
    [self.firstUC setSize:self.firstUC.texture.size];
}

// set the secondUC's gathered iamge
- (void)setSecondGathered {
    [self.secondUC setTexture:[self.atlas textureNamed:@"swordGoldExisting.png"]];
    [self.secondUC setSize:self.secondUC.texture.size];
}

// set the thirdUC's gathered iamge
- (void)setThirdGathered {
    [self.thirdUC setTexture:[self.atlas textureNamed:@"swordGoldExisting.png"]];
    [self.thirdUC setSize:self.thirdUC.texture.size];
}

#pragma mark - Arrow

// add an arrow to the gathered
- (void)addArrow {
    int arrowCount = [self.arrowLabel.text intValue] + 1;
    self.arrowLabel.text = [NSString stringWithFormat:@"%d",arrowCount];
}

// return how many arrows
- (int)arrowAmount {
    return [self.arrowLabel.text intValue];
}

#pragma mark - Timer

// subtract a second from the time
- (int)subtractSecond {
    int time = [self.timeLabel.text intValue] - 1;
    self.timeLabel.text = [NSString stringWithFormat:@"%d",time];
    
    return time;
}

// return the time left
- (int)currentTime {
    return [self.timeLabel.text intValue];
}

#pragma mark - Pause

// stop user interaction, set alpha to 50%
- (void)pause {
    [self setUserInteractionEnabled:NO];
    
    [self.delegate pauseGame:YES];
    [self setAlpha:0.5];
}

#pragma mark - Property Getters

// return state of jump
- (JumpButtonState)jumpState {
    return _jumpState;
}

// return direction going
- (JoystickDirection)joyDirection {
    return _joyDirection;
}

#pragma mark - Unload

// remove everything
- (void)unload {
    [self removeAllChildren];
    [self removeAllActions];
    self.buttons = nil;
}

@end
