//
//  OptionsScene.m
//  SpaceInvaders
//
//  Created by Eric Carlton on 12/9/14.
//  Copyright (c) 2014 Eric Carlton. All rights reserved.
//
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "OptionsScene.h"
#import "StartGameScene.h"

#define SOUND_BUTTON_NAME @"soundsButton"
#define MUSIC_BUTTON_NAME  @"musicButton"
#define DONE_BUTTON_NAME @"doneButton"

@implementation OptionsScene{
    bool _soundOn;
    bool _musicOn;
    
    SKLabelNode *_titleLabel;
    SKLabelNode *_soundButton;
    SKLabelNode *_musicButton;
    SKLabelNode *_doneButton;
    
    SKAction *_playSound;
}

-(void)didMoveToView:(SKView *)view{
    [self determineStoredSettings];
    
    [self loadSound];
    [self createTitleLabel];
    [self createSoundButton];
    [self createMusicButton];
    [self createDoneButton];
}

//Touch actions
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint touchLocation = [touch locationInNode:self];
    SKNode *touchedNode = [self nodeAtPoint:touchLocation];
    
    if ([touchedNode.name isEqualToString:SOUND_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        _soundOn = !_soundOn;
        NSString *soundSettingString = [NSString stringWithFormat:@"%i", _soundOn];
        [UICKeyChainStore setString:soundSettingString forKey:@"spaceInvadersSoundSetting"];
        [self updateSoundButtonText];
    }else if ([touchedNode.name isEqualToString:MUSIC_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        _musicOn = !_musicOn;
        NSString *soundSettingString = [NSString stringWithFormat:@"%i", _musicOn];
        [UICKeyChainStore setString:soundSettingString forKey:@"spaceInvadersMusicSetting"];
        [self updateMusicButtonText];
        
    }else if ([touchedNode.name isEqualToString:DONE_BUTTON_NAME] && [touch tapCount] == 1) {
        if(_soundOn){
            [self runAction:_playSound];
        }
        StartGameScene* startGameScene = [[StartGameScene alloc] initWithSize:self.size];
        startGameScene.scaleMode = SKSceneScaleModeAspectFill;
        [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
    }
}

//Create feature helpers
-(void)createTitleLabel{
    
    _titleLabel = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_titleLabel setFontColor:[UIColor whiteColor]];
    [_titleLabel setFontSize:50.0];
    [_titleLabel setText:@"Options"];
    _titleLabel.position = CGPointMake(self.size.width/2, self.size.height - _titleLabel.frame.size.height);
    [self addChild:_titleLabel];
}

-(void)createSoundButton{
    
    _soundButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_soundButton setFontColor:[UIColor whiteColor]];
    [_soundButton setFontSize:40.0];
    [self updateSoundButtonText];
    _soundButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 + 2 * _soundButton.frame.size.height);
    [_soundButton setName:SOUND_BUTTON_NAME];
    
    [self addChild: _soundButton];
}

-(void)createMusicButton{
    
    _musicButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_musicButton setFontColor:[UIColor whiteColor]];
    [_musicButton setFontSize:40.0];
    [self updateMusicButtonText];
    _musicButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - _musicButton.frame.size.height);
    [_musicButton setName:MUSIC_BUTTON_NAME];
    
    [self addChild: _musicButton];
    
}

-(void)createDoneButton{
    
    _doneButton = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_doneButton setFontColor:[UIColor whiteColor]];
    [_doneButton setFontSize:40.0];
    [_doneButton setText:@"Done"];
    _doneButton.position = CGPointMake(_titleLabel.position.x, self.size.height / 2 - 4 * _doneButton.frame.size.height);
    [_doneButton setName:DONE_BUTTON_NAME];
    
    [self addChild: _doneButton];
    
}

-(void)updateSoundButtonText{
    if(_soundOn){
        [_soundButton setText:@"Sound: On"];
    }else{
        [_soundButton setText:@"Sound: Off"];
    }
}

-(void)updateMusicButtonText{
    if(_musicOn){
        [_musicButton setText:@"Music: On"];
    }else{
        [_musicButton setText:@"Music: Off"];
    }
}


//Stored setting retriaval / storage helpers
-(void)determineStoredSettings{
    NSString *soundSettingString = [UICKeyChainStore stringForKey:@"spaceInvadersSoundSetting"];
    NSString *musicSettingString = [UICKeyChainStore stringForKey:@"spaceInvadersMusicSetting"];
    
    if(soundSettingString){
        _soundOn = [soundSettingString intValue];
    }else{
        _soundOn = true;
        soundSettingString = [NSString stringWithFormat:@"%i", true];
        [UICKeyChainStore setString:soundSettingString forKey:@"spaceInvadersSoundSetting"];
    }
    
    if(musicSettingString){
        _musicOn = [musicSettingString intValue];
    }else{
        _musicOn = true;
        musicSettingString = [NSString stringWithFormat:@"%i", true];
        [UICKeyChainStore setString:musicSettingString forKey:@"spaceInvadersMusicSetting"];
    }
}

//Action helpers
-(void)loadSound{
    _playSound = [SKAction playSoundFileNamed:@"ButtonPress.mp3" waitForCompletion:NO];
}

@end
