//
//  GameScene.h
//  JumpyFrog
//

#import <SpriteKit/SpriteKit.h>

@interface GameScene : SKScene <SKPhysicsContactDelegate> {
    SKSpriteNode* _frog;
    SKColor* _skyColor;
    SKSpriteNode* _restartButton;
    
    SKTexture* _rockTexture;
    SKTexture* _rockTexture2;
    
    SKTexture* _flyTexture1;
    SKTexture* _flyTexture2;
    SKTexture* _flyTexture3;
    SKAction* _flyFly;
    
    SKTexture* _birdTexture1;
    SKTexture* _birdTexture2;
    SKTexture* _birdTexture3;
    SKAction* _birdFly;
    
    SKAction* _moveObstaclesAndRemove;
    
    SKNode* _moving;
    SKNode* _obstacles;
    
    BOOL _restart;
    
    SKLabelNode* _scoreLabel;
    NSInteger _score;
    
    SKLabelNode* _gameOverLabel;
    SKLabelNode* _highScoreLabel;
}
@end
