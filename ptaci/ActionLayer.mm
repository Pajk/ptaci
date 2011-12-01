//
//  ActionLayer.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ActionLayer.h"
#import "Bird.h"

#define PTM_RATIO 32

@implementation ActionLayer

@synthesize bear = _bear;
@synthesize moveAction = _moveAction;
@synthesize walkAction = _walkAction;
@synthesize score = _score;

- (id)initWithHUD:(HUDLayer *)hud
{
	if( (self=[super initWithColor:ccc4(0,0,255,255)])) {
        
        // save reference to hud layer
        _hud = hud;
        // update user score
        _score = 0;
        [self updateScore];
        
        // set layer background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        background = [CCSprite spriteWithFile:@"blue-shooting-stars.png"];
        background.anchorPoint = ccp(0,0);
        [self addChild:background];
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
		
        // physics init
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        _world = new b2World(gravity, true);
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        groundBox.SetAsEdge(b2Vec2(0,100/PTM_RATIO), b2Vec2(background.contentSize.width/PTM_RATIO, 100/PTM_RATIO));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        // turn on bird spawning
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(tick:)];
        
        movableSprites = [[NSMutableArray alloc] init];
        
        [self registerWithTouchDispatcher];
	}
	return self;
}

- (void)tick:(ccTime) dt {
    _world->Step(dt, 10, 10);
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {    
        if (b->GetUserData() != NULL) {
            Bird *sprite = (Bird *)b->GetUserData();
            if (sprite.weight == 100) {
                continue;
            }
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO,
                                  b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }        
    }
}

//-(void)letBirdFall:(Bird *)bird {
//    
//    CGSize winSize = [[CCDirector sharedDirector] winSize];
//    
//    // Determine speed of the bird
//    int minDuration = bird.minMoveDuration;
//    int maxDuration = bird.maxMoveDuration;
//    int rangeDuration = maxDuration - minDuration;
//    
//    int actualDuration = (arc4random() % rangeDuration) + minDuration;
//    
//    // Create the actions
//    id actionMove = [CCMoveTo actionWithDuration:actualDuration 
//                                        position:ccp(bird.position.x, winSize.height/2 - 100 + bird.contentSize.height/2)];
//    id actionMoveDone = [CCCallFuncN actionWithTarget:self 
//                                             selector:@selector(spriteMoveFinished:)];
//    [bird runAction:[CCSequence actions:actionMove, actionMoveDone, nil]];
//}

-(void)addBird {
    
    //    CCSprite *bird = [CCSprite spriteWithFile:@"Icon.png"]; 
    Bird *bird = nil;
    if ((arc4random() % 2) == 0) {
        bird = [HeavyAndSlowBird bird];
    } else {
        bird = [LightweightAndFastBird bird];
    }
    
    // Determine where to spawn the bird along the X axis
    CGSize winSize = [[CCDirector sharedDirector] winSize];
    int minX = bird.contentSize.width/2;
    int maxX = background.contentSize.width - bird.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the bird slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    bird.position = ccp(actualX, winSize.height + (bird.contentSize.height/2));
    [self addChild:bird];
    
    // Create ball body 
    b2BodyDef ballBodyDef;
    ballBodyDef.type = b2_dynamicBody;
    ballBodyDef.position.Set(bird.position.x/PTM_RATIO, bird.position.y/PTM_RATIO);
    ballBodyDef.userData = bird;
    b2Body * ballBody = _world->CreateBody(&ballBodyDef);
    
    // Create circle shape
    b2PolygonShape circle;
    circle.SetAsBox((bird.contentSize.width-20)/PTM_RATIO/2, (bird.contentSize.height-20)/PTM_RATIO/2);
    
    // Create shape definition and add to body
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.8f;
    ballShapeDef.friction = 1.0f;
    ballShapeDef.restitution = 0.1f;
    _birdFixture = ballBody->CreateFixture(&ballShapeDef);
    
    [movableSprites addObject:bird];
    
//    [self letBirdFall:bird];
    
}

-(void)spriteMoveFinished:(id)sender {
    Bird *bird = (Bird *)sender;
    // [self removeChild:sprite cleanup:YES];
    [movableSprites addObject:bird];
}

-(void)gameLogic:(ccTime)dt {
    [self addBird];
}

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (void)selectSpriteForTouch:(CGPoint)touchLocation {
    Bird *newSprite = nil;
    for (Bird *sprite in movableSprites) {
        if (CGRectContainsPoint(sprite.boundingBox, touchLocation)) {            
            newSprite = sprite;
            NSLog(@"selected bird");
            break;
        }
    }    
    if (newSprite != selSprite) {
        
        CCRotateTo * rotLeft = [CCRotateBy actionWithDuration:0.1 angle:-4.0];
        CCRotateTo * rotCenter = [CCRotateBy actionWithDuration:0.1 angle:0.0];
        CCRotateTo * rotRight = [CCRotateBy actionWithDuration:0.1 angle:4.0];
        CCSequence * rotSeq = [CCSequence actions:rotLeft, rotCenter, rotRight, rotCenter, nil];
        [newSprite runAction:[CCRepeatForever actionWithAction:rotSeq]];            
        selSprite = newSprite;
    }
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {    
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    [self selectSpriteForTouch:touchLocation];      
    return TRUE;    
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGSize winSize = [CCDirector sharedDirector].winSize;
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -background.contentSize.width+winSize.width); 
    retval.y = self.position.y;
    return retval;
}

- (void)panForTranslation:(CGPoint)translation {    
    if (selSprite) {
        CGPoint newPos = ccpAdd(selSprite.position, translation);
        selSprite.position = newPos;
        selSprite.weight = 100;
    } else {
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];      
    }  
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {     
    CGPoint touchLocation = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    CGPoint translation = ccpSub(touchLocation, oldTouchLocation);    
    [self panForTranslation:translation];
    
//    if (touchLocation.x < 30) {
//        CGPoint newPos = ccpAdd(self.position, translation);
//        self.position = [self boundLayerPos:newPos];  
//    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (selSprite) {
        [selSprite stopAllActions];
        [selSprite runAction:[CCRotateTo actionWithDuration:0.1 angle:0]];
        selSprite.weight = 10;
//        [movableSprites removeObject:selSprite];
//        [self letBirdFall:selSprite];
    } else {
        // nothing?
    }
}

- (void)updateScore {
    [_hud setStatusString:[NSString stringWithFormat:@"Score: %d", _score]];
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
    self.bear = nil;
    self.walkAction = nil;
    
    [movableSprites release];
    movableSprites = nil;
    
    delete _world;
    _groundBody = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
