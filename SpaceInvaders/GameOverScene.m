//
//  GameOverScene.m
//  SpaceInvaders
//
//  Created by Eric Carlton on 12/8/14.
//  Copyright (c) 2014 Eric Carlton. All rights reserved.
//

#import "GameOverScene.h"
#import "StartGameScene.h"
#import <UICKeyChainStore/UICKeyChainStore.h>

@implementation GameOverScene{
    
    SKLabelNode *_gameOverLbl;
    SKLabelNode *_highScoreLbl;
    SKLabelNode *_scoreLbl;
    SKLabelNode *_tapToPlayAgainLbl;
    
    bool _soundOn;
    
    int _highScore;
}

@synthesize score = _score;

-(void)didMoveToView:(SKView *)view {
    
    [self determineSoundSetting];
    [self determineStoredHighScore];
    
    [self createGameOverLbl];
    [self createScoreLbl];
    [self createHighScoreLbl];
    [self createTapToPlayAgainLbl];
    
    if(_soundOn) [self playGameOverSound];
}

//Touch Actions
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    StartGameScene* startGameScene = [[StartGameScene alloc] initWithSize:self.size];
    startGameScene.scaleMode = SKSceneScaleModeAspectFill;
    [self.view presentScene:startGameScene transition:[SKTransition doorsCloseHorizontalWithDuration:1.0]];
}

//Feature creation helpers
-(void)createGameOverLbl{
    _gameOverLbl = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_gameOverLbl setFontColor:[UIColor whiteColor]];
    [_gameOverLbl setFontSize:50.0];
    [_gameOverLbl setText:@"Game Over!"];
    _gameOverLbl.position = CGPointMake(self.size.width/2, self.size.height - _gameOverLbl.frame.size.height);
    [self addChild:_gameOverLbl];
}

-(void)createHighScoreLbl{
    _highScoreLbl = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_highScoreLbl setFontColor:[UIColor whiteColor]];
    [_highScoreLbl setFontSize:40.0];
    [_highScoreLbl setText:[NSString stringWithFormat:@"Best: %i", _highScore]];
    _highScoreLbl.position = CGPointMake(self.size.width/2, _scoreLbl.position.y - _highScoreLbl.frame.size.height - 20);
    [self addChild:_highScoreLbl];
}

-(void)createScoreLbl{
    _scoreLbl = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_scoreLbl setFontColor:[UIColor whiteColor]];
    [_scoreLbl setFontSize:40.0];
    [_scoreLbl setText:[NSString stringWithFormat:@"Score: %i", _score]];
    _scoreLbl.position = CGPointMake(self.size.width/2, self.size.height / 2);
    [self addChild:_scoreLbl];
}

-(void)createTapToPlayAgainLbl{
    _tapToPlayAgainLbl = [[SKLabelNode alloc]initWithFontNamed:@"Noteworthy"];
    [_tapToPlayAgainLbl setFontColor:[UIColor whiteColor]];
    [_tapToPlayAgainLbl setFontSize:40.0];
    [_tapToPlayAgainLbl setText:@"(Tap anywhere to try again)"];
    _tapToPlayAgainLbl.position = CGPointMake(self.size.width/2, 20);
    [self addChild:_tapToPlayAgainLbl];
}

//Action Creation Helpers
-(void)playGameOverSound{
    [self runAction:[SKAction playSoundFileNamed:@"Ending.mp3" waitForCompletion:YES]];
}

//Retrieve stored setting helpers
-(void)determineStoredHighScore{
    NSString *storedHighScore = [UICKeyChainStore stringForKey:@"spaceInvadersHighScore"];
    if(storedHighScore){
        _highScore = [storedHighScore intValue];
        
        if(_score > _highScore){
            _highScore = _score;
            [UICKeyChainStore setString:[NSString stringWithFormat:@"%i", _score] forKey:@"spaceInvadersHighScore"];
        }
    }else{
        _highScore = _score;
        [UICKeyChainStore setString:[NSString stringWithFormat:@"%i", _score] forKey:@"spaceInvadersHighScore"];
    }
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


@end
