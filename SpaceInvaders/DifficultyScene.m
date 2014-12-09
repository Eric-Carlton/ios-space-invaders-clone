//
//  DifficultyScene.m
//  SpaceInvaders
//
//  Created by Eric Carlton on 12/9/14.
//  Copyright (c) 2014 Eric Carlton. All rights reserved.
//
#import <UICKeyChainStore.h>

#import "DifficultyScene.h"
#import "StartGameScene.h"

#define EASY_BUTTON_NAME @"easy"
#define NORMAL_BUTTON_NAME @"normal"
#define HARD_BUTTON_NAME @"hard"
#define IMPOSSIBLE_BUTTON_NAME @"impossible"

@implementation DifficultyScene{
    
    SKLabelNode *_titleLabel;
    
    SKLabelNode *_easyButton;
    SKLabelNode *_normalButton;
    SKLabelNode *_hardButton;
    SKLabelNode *_impossibleButton;
    
    SKAction *_playSound;
    
    bool _soundOn;
    
}

-(void)didMoveToView:(SKView *)view{
    [self setUserInteractionEnabled:YES];
    [self determineSoundSetting];
    
    [self loadSound];
    [self createTitleLabel];
    [self createEasyButton];
    [self createNormalButton];
    [self createHardButton];
    [self createImpossibleButton];
    
}

//Touch actions
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    StartGameScene* startGameScene = [[StartGameScene alloc] initWithSize:self.size];
    startGameScene.scaleMode = SKSceneScaleModeAspectFill;
    
    
    if ([touchedNode.name isEqualToString:EASY_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        [self setStoredDifficultyTo:1];
        [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }else if ([touchedNode.name isEqualToString:NORMAL_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        [self setStoredDifficultyTo:2];
        [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }else if ([touchedNode.name isEqualToString:HARD_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        [self setStoredDifficultyTo:3];
        [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }else if ([touchedNode.name isEqualToString:IMPOSSIBLE_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        [self setStoredDifficultyTo:4];
        [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }
}

//Feature creation helpers
-(void)createTitleLabel{
    
    _titleLabel = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_titleLabel setFontColor:[UIColor whiteColor]];
    [_titleLabel setFontSize:50.0];
    [_titleLabel setText:@"Tap a Difficulty Setting"];
    _titleLabel.position = CGPointMake(self.size.width/2, self.size.height - _titleLabel.frame.size.height);
    [self addChild:_titleLabel];
}

-(void)createEasyButton{
    _easyButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_easyButton setFontColor:[UIColor whiteColor]];
    [_easyButton setFontSize:40.0];
    [_easyButton setText:@"Easy"];
    _easyButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 + 3 * _easyButton.frame.size.height);
    [_easyButton setName:EASY_BUTTON_NAME];
    
    [self addChild: _easyButton];
}

-(void)createNormalButton{
    _normalButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_normalButton setFontColor:[UIColor whiteColor]];
    [_normalButton setFontSize:40.0];
    [_normalButton setText:@"Normal"];
    _normalButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 + _normalButton.frame.size.height);
    [_normalButton setName:NORMAL_BUTTON_NAME];
    
    [self addChild: _normalButton];
}

-(void)createHardButton{
    _hardButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_hardButton setFontColor:[UIColor whiteColor]];
    [_hardButton setFontSize:40.0];
    [_hardButton setText:@"Hard"];
    _hardButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - 2 * _hardButton.frame.size.height);
    [_hardButton setName:HARD_BUTTON_NAME];
    
    [self addChild: _hardButton];
}

-(void)createImpossibleButton{
    _impossibleButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_impossibleButton setFontColor:[UIColor whiteColor]];
    [_impossibleButton setFontSize:40.0];
    [_impossibleButton setText:@"Impossible"];
    _impossibleButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - 4 * _impossibleButton.frame.size.height);
    [_impossibleButton setName:IMPOSSIBLE_BUTTON_NAME];
    
    [self addChild: _impossibleButton];
    
}

//Stored setting retriaval / storage helpers
-(void)setStoredDifficultyTo:(NSInteger)difficulty{
    NSString *difficultyString = [NSString stringWithFormat:@"%li", (long)difficulty];
    [UICKeyChainStore setString:difficultyString forKey:@"spaceInvadersDifficultySetting"];
}

-(void)determineSoundSetting{
    NSString *soundSettingString = [UICKeyChainStore stringForKey:@"spaceInvadersSoundSetting"];
    
    if(soundSettingString){
        _soundOn = [soundSettingString intValue];
    }else{
        _soundOn = true;
        soundSettingString = [NSString stringWithFormat:@"%i", true];
        [UICKeyChainStore setString:soundSettingString forKey:@"spaceInvadersSoundSetting"];
    }
}

//Action helpers
-(void)loadSound{
    _playSound = [SKAction playSoundFileNamed:@"ButtonPress.mp3" waitForCompletion:YES];
}

@end
