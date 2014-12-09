//
//  GameScene.m
//  SpaceInvaders
//
//  Created by Eric Carlton on 12/4/14.
//  Copyright (c) 2014 Eric Carlton. All rights reserved.
//
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <UICKeyChainStore/UICKeyChainStore.h>

#import "GameScene.h"
#import "GameOverScene.h"

#define INVADER_COLUMNS 11
#define INVADER_ROWS 4
#define INVADER_NAME @"Invader"
#define SHIP_NAME @"Ship"
#define INVADER_BULLET_NAME @"Invader Bullet"
#define SHIP_BULLET_NAME @"Ship Bullet"
#define INVADER_FIRE_TIME 2.0

typedef enum InvaderType{
    InvaderTypeA = 0,
    InvaderTypeB,
    InvaderTypeC,
    InvaderTypeD
}InvaderType;

typedef enum InvaderMovement{
    InvaderMovementRight = 0,
    InvaderMovementDownAndLeft,
    InvaderMovementLeft,
    InvadermovementDownAndRight
}InvaderMovement;

@implementation GameScene{
    /*
     * Difficulty setting.  Stored on keychain as "spaceInvadersDifficultySetting"
     * Represented as a number between 1 - 4 that determines how far the invaders move 
     * over on each movement.
     */
    NSInteger _difficulty;
    
    /*
     * Stored on keychain as "spaceInvadersSoundSetting".
     * Determines if sound effects should be played
     */
    bool _soundOn;
    /*
     * Stored on keychain as "spaceInvadersMusicSetting".
     * Determines if music should be played
     */
    bool _musicOn;
    
    //player controlled sprite
    SKSpriteNode *_myShip;
    
    //player controlled sprite properties
    CGSize _shipSize;
    CGPoint _shipPosition;
    
    //screen properties stored for easy access
    int _screenWidth;
    int _screenHeight;
    
    //used to get accelerometer updates to move ship
    CMMotionManager *_motionManager;
    
    //Physics body categories
    UInt32 _edgeCategory;
    UInt32 _shipCategory;
    UInt32 _shipBulletCategory;
    UInt32 _invaderCategory;
    UInt32 _invaderBulletCategory;
    
    //Invader properties
    CGSize _invaderSize;
    double _lastMoveTime;
    double _moveTime;
    double _lastInvaderFiredTime;
    //determines which way invaders should move
    InvaderMovement _invaderMovt;
    int _numberOfInvaders;
    
    //allows handling of contacts on updates
    NSMutableArray *_contactQueue;
    
    //Labels that make up the "scoreboard"
    SKLabelNode *_healthLbl;
    SKLabelNode *_scoreLbl;
    SKLabelNode *_difficultyLbl;
    
    //scoring properties
    double _health;
    int _score;
    
    /*
     * True while game should continue. Goes false if any of the following
     * conditions are met: 
     *      * Player health reaches 0
     *      * All invaders are destroyed
     *      * Any invader reaches the ship
     */
    bool _gameOver;
    
    //Action to run when a bullet collides with a ship
    SKAction *_explosionAction;
    //Action that plays laser firing sound
    SKAction *_laserSoundAction;
    
    //Plays theme music
    AVAudioPlayer *_gameSceneLoop;
}

-(void)didMoveToView:(SKView *)view {
    
    //Game is starting, game over should be false
    _gameOver = false;
    
    //Physics properties
    [self.physicsWorld setContactDelegate:self];
    
    _edgeCategory = 1 << 0;
    _shipCategory = 1 << 1;
    _shipBulletCategory = 1 << 2;
    _invaderCategory = 1 << 3;
    _invaderBulletCategory = 1 << 4;
    
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    [self.physicsBody setCategoryBitMask:_edgeCategory];
    
    //Screen properties
    [self setBackgroundColor:[UIColor blackColor]];
    
    _screenWidth = self.frame.size.width;
    _screenHeight = self.frame.size.height;
    
    //Set the invaders' and ship's size based on screen
    _shipSize = CGSizeMake(.1 * _screenWidth, .05 * _screenHeight);
    _invaderSize = CGSizeMake(.05 * _screenWidth, .05 * _screenHeight);
    
    //get stored settings
    [self getStoredDifficulty];
    [self determineStoredSettings];
    //pre load explosion action so that the sound file doesn't cause lag while it loads
    [self createExplosionAction];
    
    //start the sound and music if preferences allow
    if(_soundOn) [self createLaserSoundAction];
    if(_musicOn) [self startMusic];
    
    //set the invader properties
    _numberOfInvaders = INVADER_COLUMNS * INVADER_ROWS;
    _moveTime = 1.0;
    _lastMoveTime = 0.0;
    _invaderMovt = InvaderMovementRight;
    _lastInvaderFiredTime = 0.0;
    
    //set the scoring properties
    _health = 100.0;
    _score = 0;
    
    //setup contact queue
    _contactQueue = [NSMutableArray array];
    
    //setup motion manager and start accelerometer updates
    _motionManager = [[CMMotionManager alloc]init];
    [_motionManager startAccelerometerUpdates];
    
    //create all of the features
    [self createFeatures];
}

-(void)update:(CFTimeInterval)currentTime {
    
    if([self checkGameOver]) [self endGame];
    
    [self processContactsForUpdate:currentTime];
    [self moveShip];
    [self attemptToFireInvaderBulletForTime:currentTime];
    [self moveInvaderForTime:currentTime];
    
}

//Handle Touches
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /*
     * Fire a bullet from the ship on a tap, but only allow
     * one bullet at a time
     */
    SKNode *existingShipBullet = [self childNodeWithName:SHIP_BULLET_NAME];
    
    if(!existingShipBullet){
        [self fireShipBullet];
    }
    
}

//Physics Contact Delegate
-(void)handleContact:(SKPhysicsContact *)contact{
    if(contact.bodyA.node.parent && contact.bodyB.node.parent){
        
        NSArray *nodeNames = @[contact.bodyA.node.name, contact.bodyB.node.name];
        
        //Contact between Player sprite and invader bullet sprite
        if([nodeNames containsObject:SHIP_NAME] && [nodeNames containsObject:INVADER_BULLET_NAME]){
            
            SKEmitterNode *explosion = [self newExplosion];
            [explosion setPosition:contact.bodyA.node.position];
            
            [explosion runAction:_explosionAction];
            
            [self addChild:explosion];
            
            if([contact.bodyA.node.name isEqualToString:SHIP_NAME]){
                [contact.bodyB.node removeFromParent];
            }else{
                [contact.bodyA.node removeFromParent];
            }
            
            _health -= 10.0;
          
        }
        //contact between invader sprite and Player bullet sprite
        else if([nodeNames containsObject:INVADER_NAME] && [nodeNames containsObject:SHIP_BULLET_NAME]){
            
            SKEmitterNode *explosion = [self newExplosion];
            [explosion setPosition:contact.bodyA.node.position];
            
            [explosion runAction:_explosionAction];
            
            [self addChild:explosion];
            
            [contact.bodyA.node removeFromParent];
            [contact.bodyB.node removeFromParent];
            _score += ( 1 * _difficulty );
            _numberOfInvaders--;
            _moveTime = _numberOfInvaders / 44.0;
        }
        
        //update the score and health labels
        [self updateLabels];
    }
}

//Contact helpers
-(void)processContactsForUpdate:(NSTimeInterval)currentTime {
    for (SKPhysicsContact* contact in [_contactQueue copy]) {
        [self handleContact:contact];
        [_contactQueue removeObject:contact];
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact{
    [_contactQueue addObject:contact];
}

//Feature creation helpers
-(void)createFeatures{
    [self createShip];
    [self createInvaders];
    [self createScoreboard];
}

-(void)createShip{
    _myShip = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:_shipSize];
    [_myShip setName:SHIP_NAME];
    _shipPosition = CGPointMake(_screenWidth / 2.0, _myShip.size.height / 2.0);
    [_myShip setPosition:_shipPosition];
    _myShip.physicsBody= [SKPhysicsBody bodyWithRectangleOfSize:_myShip.size];
    [_myShip.physicsBody setAffectedByGravity:NO];
    [_myShip.physicsBody setMass:0.02];
    [_myShip.physicsBody setDynamic:YES];
    [_myShip.physicsBody setCategoryBitMask:_shipCategory];
    [_myShip.physicsBody setCollisionBitMask:_edgeCategory];
    [_myShip.physicsBody setContactTestBitMask:_invaderBulletCategory | _edgeCategory];
    
    [self addChild:_myShip];
}

-(void)createInvaders{
    for(int i = 0; i < INVADER_ROWS; i++){
        for(int j = 0; j < INVADER_COLUMNS; j++){
            
            SKSpriteNode *invader = [self createInvaderOfType:i];
            [invader setPosition:CGPointMake((2.5 * _invaderSize.width) + (1.5 * _invaderSize.width * j), _screenHeight - ((1.5 * _invaderSize.height) + (1.5 *_invaderSize.height * i)))];
            
            invader.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:invader.size];
            [invader.physicsBody setAffectedByGravity:NO];
            [invader.physicsBody setDynamic:YES];
            [invader.physicsBody setCategoryBitMask:_invaderCategory];
            [invader.physicsBody setCollisionBitMask:0x0];
            [invader.physicsBody setContactTestBitMask:_shipBulletCategory | _edgeCategory];
            
            [self addChild:invader];
        }
    }
}

-(SKSpriteNode *)createInvaderOfType:(InvaderType)type{
    UIColor *color;
    
    switch (type) {
        case InvaderTypeA:
            color = [UIColor blueColor];
            break;
        case InvaderTypeB:
            color = [UIColor greenColor];
            break;
        case InvaderTypeC:
            color = [UIColor yellowColor];
            break;
        case InvaderTypeD:
            color = [UIColor orangeColor];
            break;
    }
    
    SKSpriteNode *invader = [[SKSpriteNode alloc]initWithColor:color size:_invaderSize];
    [invader setName:INVADER_NAME];
    return invader;
}

-(void)createScoreboard{
    _scoreLbl = [[SKLabelNode alloc]initWithFontNamed:@"Helvetica"];
    _scoreLbl.fontSize = 20;
    _scoreLbl.fontColor = [SKColor greenColor];
    _scoreLbl.text = [NSString stringWithFormat:@"Score: %04u", _score];
    _scoreLbl.position = CGPointMake(20 + _scoreLbl.frame.size.width/2, self.size.height - (20 + _scoreLbl.frame.size.height/2));
    [self addChild:_scoreLbl];
    
    _healthLbl = [[SKLabelNode alloc]initWithFontNamed:@"Helvetica"];
    _healthLbl.fontSize = 20;
    _healthLbl.fontColor = [SKColor redColor];
    _healthLbl.text = [NSString stringWithFormat:@"Health: %.1f%%", _health];
    _healthLbl.position = CGPointMake(self.size.width - _healthLbl.frame.size.width/2 - 20, self.size.height - (20 + _healthLbl.frame.size.height/2));
    [self addChild:_healthLbl];
    
    _difficultyLbl = [[SKLabelNode alloc]initWithFontNamed:@"Helvetica"];
    _difficultyLbl.fontSize = 20;
    _difficultyLbl.fontColor = [SKColor yellowColor];
    switch (_difficulty) {
        case 1:
            [_difficultyLbl setText:@"Difficulty: Easy"];
            break;
        case 2:
            [_difficultyLbl setText:@"Difficulty: Normal"];
            break;
        case 3:
            [_difficultyLbl setText:@"Difficulty: Hard"];
            break;
        case 4:
            [_difficultyLbl setText:@"Difficulty: Impossible"];
            break;
        default:
            [_difficultyLbl setText:@"Difficulty: Unknown"];
            break;
    }
    _difficultyLbl.position = CGPointMake(self.frame.size.width/2, self.size.height - (20 + _difficultyLbl.frame.size.height/2));
    [self addChild:_difficultyLbl];
    
}

-(void)updateLabels{
    _healthLbl.text = [NSString stringWithFormat:@"Health: %.1f%%", _health];
    _scoreLbl.text = [NSString stringWithFormat:@"Score: %04u", _score];
}


-(void)moveShip{
    if(_motionManager.accelerometerData){
        if(fabs(_motionManager.accelerometerData.acceleration.y)> 0.2){
            [_myShip.physicsBody applyForce:CGVectorMake(-40 * _motionManager.accelerometerData.acceleration.y, 0)];
        }else{
            [_myShip.physicsBody setVelocity:CGVectorMake(0, 0)];
        }
    }
}

//Movement and movement helpers
-(void)moveInvaderForTime:(NSTimeInterval)currentTime{
    if(currentTime - _lastMoveTime < _moveTime){
        return;
    }else{
        [self determineInvaderMovementDirection];
        
        [self enumerateChildNodesWithName:INVADER_NAME usingBlock:^(SKNode *node, BOOL *stop) {
            switch(_invaderMovt){
                case InvaderMovementLeft:
                    node.position = CGPointMake(node.position.x - _invaderSize.width * _difficulty * .25, node.position.y);
                    break;
                case InvaderMovementRight:
                    node.position = CGPointMake(node.position.x + _invaderSize.width * _difficulty * .25, node.position.y);
                    break;
                case InvaderMovementDownAndLeft:
                case InvadermovementDownAndRight:
                    node.position = CGPointMake(node.position.x, node.position.y - _invaderSize.height * _difficulty * .25);
                    break;
            }
        }];
    }
    
    _lastMoveTime = currentTime;
}

-(void)determineInvaderMovementDirection{
    __block InvaderMovement possibleDirection = _invaderMovt;
    
    [self enumerateChildNodesWithName:INVADER_NAME usingBlock:^(SKNode *node, BOOL *stop) {
        switch(_invaderMovt){
            case InvaderMovementRight:
                if(CGRectGetMaxX(node.frame) >= node.scene.size.width - 1.0f){
                    possibleDirection = InvaderMovementDownAndLeft;
                    *stop = true;
                }
                break;
            case InvaderMovementLeft:
                if(CGRectGetMinX(node.frame) <= 1.0f){
                    possibleDirection = InvadermovementDownAndRight;
                    *stop = true;
                }
                break;
            case InvaderMovementDownAndLeft:
                possibleDirection = InvaderMovementLeft;
                *stop = true;
                break;
            case InvadermovementDownAndRight:
                possibleDirection = InvaderMovementRight;
                *stop = true;
                break;
        }
    }];
    
    if(possibleDirection != _invaderMovt){
        _invaderMovt = possibleDirection;
    }
}

//Bullet Firing Methods
-(void)fireShipBullet{
    SKSpriteNode *bullet = [[SKSpriteNode alloc]initWithColor:[UIColor whiteColor] size:CGSizeMake(10.0, 10.0)];
    [bullet setName:SHIP_BULLET_NAME];
    [bullet setPosition:CGPointMake(_myShip.position.x, _myShip.position.y + (_myShip.size.height / 2) + 10)];
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    [bullet.physicsBody setMass: .02];
    [bullet.physicsBody setAffectedByGravity:NO];
    [bullet.physicsBody setCategoryBitMask:_shipBulletCategory];
    [bullet.physicsBody setContactTestBitMask:_invaderCategory];
    [bullet.physicsBody setCollisionBitMask:0x0];
    [bullet.physicsBody setVelocity:CGVectorMake(0, 0)];
    
    SKAction* bulletAction = [SKAction sequence:@[[SKAction moveTo:CGPointMake(bullet.position.x, _screenHeight) duration:.75],
                                                  [SKAction waitForDuration:3.0/60.0],
                                                  [SKAction removeFromParent]]];
    if(_laserSoundAction) [bullet runAction:_laserSoundAction];
    [bullet runAction:bulletAction];
    
    [self addChild:bullet];
    
}

-(void)fireInvaderBulletFromPoint:(CGPoint)firingPoint{
    SKSpriteNode *bullet = [[SKSpriteNode alloc]initWithColor:[UIColor grayColor] size:CGSizeMake(10.0, 10.0)];
    [bullet setName:INVADER_BULLET_NAME];
    [bullet setPosition:firingPoint];
    bullet.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:bullet.size];
    [bullet.physicsBody setMass: .02];
    [bullet.physicsBody setAffectedByGravity:NO];
    [bullet.physicsBody setCategoryBitMask:_invaderBulletCategory];
    [bullet.physicsBody setContactTestBitMask:_shipCategory];
    [bullet.physicsBody setCollisionBitMask:0x0];
    [bullet.physicsBody setVelocity:CGVectorMake(0, 0)];
    
    SKAction* bulletAction = [SKAction sequence:@[[SKAction moveTo:CGPointMake(bullet.position.x, 0) duration:1.5],
                                                  [SKAction waitForDuration:3.0/60.0],
                                                  [SKAction removeFromParent]]];
    
    if(_laserSoundAction) [bullet runAction:_laserSoundAction];
    [bullet runAction:bulletAction];
    
    [self addChild:bullet];
}

-(void)attemptToFireInvaderBulletForTime:(NSTimeInterval)currentTime{
    
    if(currentTime - _lastInvaderFiredTime < INVADER_FIRE_TIME)
        return;
    
    SKNode *invaderBullet = [self childNodeWithName:INVADER_BULLET_NAME];
    if(!invaderBullet){
        
        NSMutableArray *invaders = [NSMutableArray array];
        [self enumerateChildNodesWithName:INVADER_NAME usingBlock:^(SKNode *node, BOOL *stop) {
            [invaders addObject:node];
        }];
        
        if(invaders.count > 0){
            NSInteger randomInvaderIndex = arc4random_uniform((u_int32_t)invaders.count);
            
            SKNode *randomInvader = [invaders objectAtIndex:randomInvaderIndex];
            CGPoint bulletFiringPosition = CGPointMake(randomInvader.position.x, randomInvader.position.y - (randomInvader.frame.size.height / 2) - 10);
            
            [self fireInvaderBulletFromPoint:bulletFiringPosition];
            _lastInvaderFiredTime = currentTime;
        }
    }
    
}

//Retrieve stored setting methods
-(void)getStoredDifficulty{
    
    NSString *_difficultyString = [UICKeyChainStore stringForKey:@"spaceInvadersDifficultySetting"];
    
    if(_difficultyString){
        _difficulty = [_difficultyString integerValue];
    }else{
        _difficulty = 2;
    }
  
}

-(SKEmitterNode *)newExplosion{
    
    NSString *firePath = [[NSBundle mainBundle] pathForResource:@"Explosion" ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:firePath];
    
    return explosion;
    
}

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

//Sound and music methods
-(void)createExplosionAction{
    
    if(_soundOn){
        _explosionAction = [SKAction sequence:@[[SKAction playSoundFileNamed:@"Explosion.mp3" waitForCompletion:false],
                                               [SKAction waitForDuration:1.0],
                                               [SKAction removeFromParent]]];
    }else{
        _explosionAction = [SKAction sequence:@[[SKAction waitForDuration:1.0],
                             [SKAction removeFromParent]]];
    }
}

-(void)createLaserSoundAction{
    _laserSoundAction = [SKAction playSoundFileNamed:@"Laser.mp3" waitForCompletion:false];
}

-(void)startMusic{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Meteor Blaze!" ofType:@"mp3"];
    NSError *error;
    _gameSceneLoop = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:filePath] error:&error];
    if (error) {
        NSLog(@"Error in audioPlayer: %@", [error localizedDescription]);
    } else {
        _gameSceneLoop.numberOfLoops = -1;
        [_gameSceneLoop prepareToPlay];
        [_gameSceneLoop play];
    }
}


//Game Over methods
-(BOOL)checkGameOver{
    
    __block bool invadersLanded = false;
    
    [self enumerateChildNodesWithName:INVADER_NAME usingBlock:^(SKNode *node, BOOL *stop) {
        double invaderHeight = CGRectGetMinY(node.frame);
        if(invaderHeight <= 2 * _myShip.size.height){
            invadersLanded = true;
            *stop = true;
        }
    }];
    
    return _health <= 0 || _numberOfInvaders <= 0 || invadersLanded;
}

-(void)endGame {
    
    if (!_gameOver) {
        [_gameSceneLoop stop];
        _gameOver = true;
        [_motionManager stopAccelerometerUpdates];
        GameOverScene* gameOverScene = [[GameOverScene alloc] initWithSize:self.size];
        [gameOverScene setScore:_score];
        [self.view presentScene:gameOverScene transition:[SKTransition doorsOpenHorizontalWithDuration:1.0]];
    }
    
}


@end
