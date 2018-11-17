//
//  GameScene.m
//  JumpyFrog
//

#import "GameScene.h"

@implementation GameScene {
    
}

static const uint32_t frogCategory = 1 << 0;
static const uint32_t worldCategory = 1 << 1;
static const uint32_t obstacleCategory = 1 << 2;
static const uint32_t flyCategory = 1 << 4;
static const uint32_t scoreCategory = 1 << 3;

- (void)didMoveToView:(SKView *)view {
    self.physicsWorld.contactDelegate = self;
    
    _restart = NO;
    
    //frog gravity speed
    self.physicsWorld.gravity = CGVectorMake( 0.0, -5.0 );
    
    // background scene setup
    _skyColor = [SKColor colorWithRed:121.0/255.0 green:201.0/255.0 blue:247.0/255.0 alpha:1.0];
    [self setBackgroundColor:_skyColor];
    
    _moving = [SKNode node];
    [self addChild:_moving];
    
    _obstacles = [SKNode node];
    [_moving addChild:_obstacles];
    
    SKTexture* groundTexture = [SKTexture textureWithImageNamed:@"ground"];
    groundTexture.filteringMode = SKTextureFilteringNearest;
    SKTexture* bgTexture = [SKTexture textureWithImageNamed:@"bg"];
    bgTexture.filteringMode = SKTextureFilteringNearest;
    
    SKAction* moveGroundSprite = [SKAction moveByX:-groundTexture.size.width*2 y:0 duration:0.01 * groundTexture.size.width*2];
    SKAction* resetGroundSprite = [SKAction moveByX:groundTexture.size.width*2 y:0 duration:0];
    SKAction* moveGroundSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveGroundSprite, resetGroundSprite]]];
    
    for( int i = 0; i < 2 + self.frame.size.width / ( groundTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:groundTexture];
        sprite.position = CGPointMake(i * sprite.size.width, -self.frame.size.width/2);
        [sprite runAction:moveGroundSpritesForever];
        [_moving addChild:sprite];
    }
    
    SKAction* moveSkylineSprite = [SKAction moveByX:-bgTexture.size.width*2 y:0 duration:0.1 * bgTexture.size.width*2];
    SKAction* resetSkylineSprite = [SKAction moveByX:bgTexture.size.width*2 y:0 duration:0];
    SKAction* moveSkylineSpritesForever = [SKAction repeatActionForever:[SKAction sequence:@[moveSkylineSprite, resetSkylineSprite]]];
    
    for( int i = 0; i < 2 + self.frame.size.width / ( bgTexture.size.width * 2 ); ++i ) {
        SKSpriteNode* sprite = [SKSpriteNode spriteNodeWithTexture:bgTexture];
        sprite.zPosition = -20;
        sprite.position = CGPointMake(i * sprite.size.width, self.frame.size.width/2-60);
        [sprite runAction:moveSkylineSpritesForever];
        [_moving addChild:sprite];
    }
    
    //frog setup
    SKTexture* frogTexture1 = [SKTexture textureWithImageNamed:@"Frog1"];
    frogTexture1.filteringMode = SKTextureFilteringNearest;
    SKTexture* frogTexture2 = [SKTexture textureWithImageNamed:@"Frog2"];
    frogTexture2.filteringMode = SKTextureFilteringNearest;
    
    SKAction* jump = [SKAction repeatActionForever:[SKAction animateWithTextures:@[frogTexture1, frogTexture2] timePerFrame:0.2]];
    
    //view.showsPhysics = YES;
    
    _frog = [SKSpriteNode spriteNodeWithTexture:frogTexture1];
    [_frog setScale:2.0];
    _frog.position = CGPointMake(-(self.frame.size.width / 4), CGRectGetMidY(self.frame));
    [_frog runAction:jump];
    
    _frog.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_frog.size.height/2];
    _frog.physicsBody.dynamic = YES;
    _frog.physicsBody.allowsRotation = NO;
    
    _frog.physicsBody.categoryBitMask = frogCategory;
    _frog.physicsBody.collisionBitMask = worldCategory | obstacleCategory;
    _frog.physicsBody.contactTestBitMask = worldCategory | obstacleCategory | flyCategory;
    
    [self addChild:_frog];
    
    //ground physics body
    SKNode* ground = [SKNode node];
    ground.position = CGPointMake(0, -groundTexture.size.height/2-70);
    ground.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(self.frame.size.width, groundTexture.size.height)];
    ground.physicsBody.dynamic = NO;
    ground.physicsBody.categoryBitMask = worldCategory;
    [self addChild:ground];
    
    //rocks setup
    _rockTexture = [SKTexture textureWithImageNamed:@"rocks"];
    _rockTexture.filteringMode = SKTextureFilteringNearest;
    _rockTexture2 = [SKTexture textureWithImageNamed:@"rock2"];
    _rockTexture2.filteringMode = SKTextureFilteringNearest;
    
    //flies setup
    _flyTexture1 = [SKTexture textureWithImageNamed:@"fly1"];
    _flyTexture1.filteringMode = SKTextureFilteringNearest;
    _flyTexture2 = [SKTexture textureWithImageNamed:@"fly2"];
    _flyTexture2.filteringMode = SKTextureFilteringNearest;
    _flyTexture3 = [SKTexture textureWithImageNamed:@"fly3"];
    _flyTexture3.filteringMode = SKTextureFilteringNearest;
    _flyFly = [SKAction repeatActionForever:[SKAction animateWithTextures:@[_flyTexture1, _flyTexture2, _flyTexture3] timePerFrame:0.2]];
    
    //bird enemies setup
    _birdTexture1 = [SKTexture textureWithImageNamed:@"bird1"];
    _birdTexture1.filteringMode = SKTextureFilteringNearest;
    _birdTexture2 = [SKTexture textureWithImageNamed:@"bird2"];
    _birdTexture2.filteringMode = SKTextureFilteringNearest;
    _birdTexture3 = [SKTexture textureWithImageNamed:@"bird3"];
    _birdTexture3.filteringMode = SKTextureFilteringNearest;
    _birdFly = [SKAction repeatActionForever:[SKAction animateWithTextures:@[_birdTexture1, _birdTexture2, _birdTexture3] timePerFrame:0.2]];
    
    CGFloat distanceToMove = self.frame.size.width + 2 * _rockTexture.size.width;
    SKAction* moveObstacles = [SKAction moveByX:-distanceToMove y:0 duration:0.01 * distanceToMove];
    SKAction* removeObstacles = [SKAction removeFromParent];
    _moveObstaclesAndRemove = [SKAction sequence:@[moveObstacles, removeObstacles]];
    
    SKAction* spawn = [SKAction performSelector:@selector(spawnPipes) onTarget:self];
    SKAction* delay = [SKAction waitForDuration:4.0];
    SKAction* spawnThenDelay = [SKAction sequence:@[spawn, delay]];
    SKAction* spawnThenDelayForever = [SKAction repeatActionForever:spawnThenDelay];
    [self runAction:spawnThenDelayForever];
    
    //setup score counting
    _score = 0;
    _scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
    _scoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), 550);
    _scoreLabel.zPosition = 100;
    _scoreLabel.fontSize = 80;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)_score];
    [self addChild:_scoreLabel];
}

-(void)spawnPipes {
    SKNode* obstaclePair = [SKNode node];
    obstaclePair.position = CGPointMake(self.frame.size.width/2 + _rockTexture.size.width, -50);
    
    //determine which rock to spawn
    NSInteger rand = (NSInteger)(0 + arc4random_uniform(1 - 0 + 1));
    CGFloat y = arc4random() % (NSInteger)( self.frame.size.height / 8 - 50);
    if(rand==0){
        SKSpriteNode* rocks = [SKSpriteNode spriteNodeWithTexture:_rockTexture];
        rocks.position = CGPointMake( 0, y );
        rocks.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:rocks.size];
        rocks.physicsBody.dynamic = NO;
        rocks.physicsBody.categoryBitMask = obstacleCategory;
        rocks.physicsBody.contactTestBitMask = frogCategory;
        obstaclePair.zPosition = -10;
        [obstaclePair addChild:rocks];
    }
    else if(rand==1) {
        SKSpriteNode* rock = [SKSpriteNode spriteNodeWithTexture:_rockTexture2];
        rock.position = CGPointMake( 0, CGRectGetMidY(self.frame)+25);
        rock.physicsBody = [SKPhysicsBody bodyWithTexture:_rockTexture2 size:CGSizeMake(_rockTexture2.size.width, _rockTexture2.size.height)];
        rock.physicsBody.dynamic = NO;
        rock.physicsBody.categoryBitMask = obstacleCategory;
        rock.physicsBody.contactTestBitMask = frogCategory;
        obstaclePair.zPosition = 10;
        [obstaclePair addChild:rock];
    }
    
    //choose to spawn fly or bird
    NSInteger rand2 = (NSInteger)(0 + arc4random_uniform(1 - 0 + 1));
    if(rand2==0) {
        SKSpriteNode* fly = [SKSpriteNode spriteNodeWithTexture:_flyTexture1];
        fly.position = CGPointMake( 0, y + _rockTexture.size.height + (100 + arc4random_uniform(150 - 100 + 150)));
        fly.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:fly.size.width/2];
        fly.physicsBody.dynamic = NO;
        fly.physicsBody.categoryBitMask = flyCategory;
        fly.physicsBody.contactTestBitMask = frogCategory;
        [fly runAction:_flyFly];
        [obstaclePair addChild:fly];
    }
    else if(rand2==1) {
        SKSpriteNode* bird = [SKSpriteNode spriteNodeWithTexture:_birdTexture1];
        [bird setScale:2.0];
        bird.position = CGPointMake( 0, y + _rockTexture.size.height + (70 + arc4random_uniform(150 - 70 + 150)));
        bird.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bird.size.width/2];
        bird.physicsBody.dynamic = NO;
        bird.physicsBody.categoryBitMask = obstacleCategory;
        bird.physicsBody.contactTestBitMask = frogCategory;
        [bird runAction:_birdFly];
        [obstaclePair addChild:bird];
    }
    
    SKNode* contactNode = [SKNode node];
    contactNode.position = CGPointMake(_rockTexture.size.width + _frog.size.width / 2, CGRectGetMidY( self.frame ) );
    contactNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(_rockTexture.size.width, self.frame.size.height )];
    contactNode.physicsBody.dynamic = NO;
    contactNode.physicsBody.categoryBitMask = scoreCategory;
    contactNode.physicsBody.contactTestBitMask = frogCategory;
    [obstaclePair addChild:contactNode];
    
    [obstaclePair runAction:_moveObstaclesAndRemove];
    [_obstacles addChild:obstaclePair];
}

- (void)didBeginContact:(SKPhysicsContact *)contact {
    // stop all moving objects
    if(_moving.speed > 0) {
        if( ( contact.bodyA.categoryBitMask & scoreCategory ) == scoreCategory || ( contact.bodyB.categoryBitMask & scoreCategory ) == scoreCategory ) {
            _score++;
            _scoreLabel.text = [NSString stringWithFormat:@"%ld", _score];
            
            [_scoreLabel runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
        } else if (( contact.bodyA.categoryBitMask & worldCategory ) == worldCategory || ( contact.bodyB.categoryBitMask & worldCategory ) == worldCategory ) {
            //do nothing
        } else if(( contact.bodyA.categoryBitMask & flyCategory ) == flyCategory || ( contact.bodyB.categoryBitMask & flyCategory ) == flyCategory ) {
            _score+=2;
            _scoreLabel.text = [NSString stringWithFormat:@"%ld", _score];
            
            [_scoreLabel runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
        }
        else {
            _moving.speed = 0;
            
            _frog.physicsBody.collisionBitMask = worldCategory;
            
            //halt frog
            [_frog runAction:[SKAction rotateByAngle:M_PI * _frog.position.y * 0.01 duration:_frog.position.y * 0.003] completion:^{
                _frog.speed = 0;
            }];
            
            // flash background red if contact with obstacle is detected
            [self removeActionForKey:@"flash"];
            [self runAction:[SKAction sequence:@[[SKAction repeatAction:[SKAction sequence:@[[SKAction runBlock:^{
                self.backgroundColor = [SKColor redColor];
            }], [SKAction waitForDuration:0.05], [SKAction runBlock:^{
                self.backgroundColor = _skyColor;
            }], [SKAction waitForDuration:0.05]]] count:4], [SKAction runBlock:^{
                _restart = YES;
            }]]] withKey:@"flash"];
            
            //game over label
            SKLabelNode* gameOverLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
            gameOverLabel.name = @"gameOverLabel";
            gameOverLabel.position = CGPointMake( CGRectGetMidX( self.frame ), 380);
            gameOverLabel.zPosition = 100;
            gameOverLabel.fontSize = 80;
            gameOverLabel.text = [NSString stringWithFormat:@"Game Over"];
            [self addChild:gameOverLabel];
            [gameOverLabel runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
            
            //high score label
            
            SKLabelNode* highScoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
            highScoreLabel.name = @"highScoreLabel";
            highScoreLabel.position = CGPointMake( CGRectGetMidX( self.frame ), 300);
            highScoreLabel.zPosition = 100;
            highScoreLabel.fontSize = 60;
            highScoreLabel.text = [NSString stringWithFormat:@"High Score:%ld", (long)_score];
            [self addChild:highScoreLabel];
            [highScoreLabel runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
            
            // tap to restart label
            SKLabelNode* restartLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
            restartLabel.name = @"restartLabel";
            restartLabel.position = CGPointMake( CGRectGetMidX( self.frame ), 230);
            restartLabel.zPosition = 100;
            restartLabel.fontSize = 40;
            restartLabel.text = [NSString stringWithFormat:@"(tap to restart)"];
            [self addChild:restartLabel];
            [restartLabel runAction:[SKAction sequence:@[[SKAction scaleTo:1.5 duration:0.1], [SKAction scaleTo:1.0 duration:0.1]]]];
            
            //square background
            SKShapeNode* tile = [SKShapeNode node];
            tile.name = @"tile";
            [tile setPath:CGPathCreateWithRoundedRect(CGRectMake(-220, 150, 450, 350), 30, 30, nil)];
            tile.strokeColor = tile.fillColor = [UIColor colorWithRed:0.0/255.0
                                                                green:255.0/255.0
                                                                 blue:120.0/255.0
                                                                alpha:0.8];
            tile.zPosition = 99;
            [self addChild:tile];
            
        }
    }
}

- (void)touchDownAtPoint:(CGPoint)pos {
    
}

- (void)touchMovedToPoint:(CGPoint)pos {
    
}

- (void)touchUpAtPoint:(CGPoint)pos {
    
}

- (void) resetScene {
    //reset frog pos
    _frog.position = CGPointMake(-(self.frame.size.width / 4), CGRectGetMidY(self.frame));
    _frog.physicsBody.velocity = CGVectorMake(0, 0);
    _frog.physicsBody.collisionBitMask = worldCategory | obstacleCategory;
    _frog.speed = 1.0;
    _frog.zRotation = 0.0;
    
    //reset obstacles
    [_obstacles removeAllChildren];
    
    //reset score
    _score = 0;
    _scoreLabel.text = [NSString stringWithFormat:@"%ld", _score];
    
    [[self childNodeWithName:@"highScoreLabel"] removeFromParent];
    [[self childNodeWithName:@"gameOverLabel"] removeFromParent];
    [[self childNodeWithName:@"restartLabel"] removeFromParent];
    
    [[self childNodeWithName:@"tile"] removeFromParent];
    
    _moving.speed = 1;
    _restart = NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(_moving.speed > 0) {
        _frog.physicsBody.velocity = CGVectorMake(0, 0);
        [_frog.physicsBody applyImpulse:CGVectorMake(0, 60)];
    } else if (_restart) {
        
        
        [self resetScene];
    }
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    for (UITouch *t in touches) {[self touchMovedToPoint:[t locationInNode:self]];}
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *t in touches) {[self touchUpAtPoint:[t locationInNode:self]];}
}

CGFloat clamp(CGFloat min, CGFloat max, CGFloat value) {
    if( value > max ) {
        return max;
    } else if( value < min ) {
        return min;
    } else {
        return value;
    }
}

-(void)update:(CFTimeInterval)currentTime {
    // Called before each frame is rendered
    if(_moving.speed > 0) {
        _frog.zRotation = clamp(-0.5, 0.3, _frog.physicsBody.velocity.dy * (_frog.physicsBody.velocity.dy < 0 ? 0.003 : 0.001));
    }
}



@end
