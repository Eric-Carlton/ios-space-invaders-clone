//
//  StartGameScene.m
//  SpaceInvaders
//
//  Created by Eric Carlton on 12/9/14.
//  Copyright (c) 2014 Eric Carlton. All rights reserved.
//
#import <UICKeyChainStore/UICKeyChainStore.h>

#import "StartGameScene.h"
#import "GameScene.h"
#import "DifficultyScene.h"
#import "OptionsScene.h"

#define START_BUTTON_NAME @"startButton"
#define DIFFICULTY_BUTTON_NAME @"difficultyButton"
#define OPTIONS_BUTTON_NAME @"optionsButton"

@implementation StartGameScene{
    SKLabelNode *_titleLabel;
    
    SKLabelNode *_startButton;
    SKLabelNode *_difficultyButton;
    SKLabelNode *_optionsBtn;
    
    SKAction *_playSound;
    
    bool _soundOn;
    
}

-(void)didMoveToView:(SKView *)view{
    self.userInteractionEnabled = true;
    [self determineSoundSetting];
    [self loadSound];
    [self createTitleLabel];
    [self createStartButton];
    [self createDifficultyButton];
    [self createOptionsButton];
}

//Touch Actions
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode.name isEqualToString:START_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        GameScene* gameScene = [[GameScene alloc] initWithSize:self.size];
        gameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:gameScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }else if([touchedNode.name isEqualToString:DIFFICULTY_BUTTON_NAME] && [touch tapCount] == 1){
        if(_soundOn){
            [self runAction:_playSound];
        }
        DifficultyScene *difficultyScene = [[DifficultyScene alloc]initWithSize:self.size];
        difficultyScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:difficultyScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }else if([touchedNode.name isEqualToString:OPTIONS_BUTTON_NAME] && [touch tapCount] == 1){
        if(_soundOn){
            [self runAction:_playSound];
        }
        OptionsScene *optionsScene = [[OptionsScene alloc]initWithSize:self.size];
        optionsScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:optionsScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }
}

//Feature creation helpers
-(void)createTitleLabel{
    
    _titleLabel = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_titleLabel setFontColor:[UIColor whiteColor]];
    [_titleLabel setFontSize:50.0];
    [_titleLabel setText:@"Space Invaders"];
    _titleLabel.position = CGPointMake(self.size.width/2, self.size.height - _titleLabel.frame.size.height);
    [self addChild:_titleLabel];
}

-(void)createStartButton{
    
    _startButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_startButton setFontColor:[UIColor whiteColor]];
    [_startButton setFontSize:40.0];
    [_startButton setText:@"Start"];
    _startButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 + 2 * _startButton.frame.size.height);
    [_startButton setName:START_BUTTON_NAME];

    [self addChild: _startButton];
}

-(void)createDifficultyButton{
    
    _difficultyButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_difficultyButton setFontColor:[UIColor whiteColor]];
    [_difficultyButton setFontSize:40.0];
    [_difficultyButton setText:@"Change Difficulty"];
    _difficultyButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - _difficultyButton.frame.size.height);
    [_difficultyButton setName:DIFFICULTY_BUTTON_NAME];
    
    [self addChild: _difficultyButton];
    
}

-(void)createOptionsButton{
    
    _optionsBtn = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_optionsBtn setFontColor:[UIColor whiteColor]];
    [_optionsBtn setFontSize:40.0];
    [_optionsBtn setText:@"Options"];
    _optionsBtn.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - 4 * _optionsBtn.frame.size.height);
    [_optionsBtn setName:OPTIONS_BUTTON_NAME];
    
    [self addChild: _optionsBtn];
    
}

//Retrieve stored settings 
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
