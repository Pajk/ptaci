//
//  HelloWorldLayer.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import "ActionScene.h"
#import "Bird.h"
#import "AppDelegate.h"
#import "GameState.h"
#import "Level.h"
#import "GameSoundManager.h"
#import "AutoCleanSprite.h"
#import <list>

#define PTM_RATIO 32
#define ROPE_HEIGHT 100
#define BIRDS_LIMIT 40
#define ROPE_TAG 2

@implementation ActionScene
@synthesize layer = _layer;
@synthesize hudLayer = _hudLayer;
- (id)init {
    if ((self = [super init])) {
        self.hudLayer = [[[HudLayer alloc] init] autorelease];
        self.layer = [[[ActionLayer alloc] initWithHud:self.hudLayer] autorelease];
        [self addChild:_layer];
        [self addChild:_hudLayer];
    }
    return self;    
}
@end

@implementation HudLayer

- (id)init {
    if ((self = [super init])) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
		_statusLabel = [[CCLabelAtlas labelWithString:@"0" charMapFile:@"fps_images.png" itemWidth:16 itemHeight:24 startCharMap:'.'] retain];
        _statusLabel.position = ccp(winSize.width* 0.78, winSize.height * 0.85);
        _statusHeart = [CCSprite spriteWithSpriteFrameName:@"heart.png"];
        _statusHeart.position = ccp(winSize.width* 0.9, winSize.height * 0.9);
        [self addChild:_statusHeart];
        [self addChild:_statusLabel];
    }
    return self;
}

- (void)setStatusString:(NSString *)string {
    _statusLabel.string = string;
}
@end


@interface ActionLayer (PrivateMethods)
-(void) fadeOutMusic;
-(void) updateScore;
-(void) createRope;
@end

@implementation ActionLayer

@synthesize batchNode       = _batchNode;
@synthesize background      = _background;
@synthesize birds           = _birds;
@synthesize levelEnd        = _levelEnd;
@synthesize levelBegin      = _levelBegin;
@synthesize lastTimeBirdAdded = _lastTimeBirdAdded;
@synthesize inLevel         = _inLevel;
@synthesize score           = _score;

SimpleAudioEngine *soundEngine;

- (b2Vec2)toMeters:(CGPoint)point {
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

- (CGPoint)toPixels:(b2Vec2)vec {
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

- (id) initWithHud:(HudLayer *)hudLayer {
    if ((self = [super init])) {
        
        self.birds = [[[NSMutableArray alloc] init] autorelease];
        
        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        
        [self addChild:_batchNode z:-1];
        
        // Show game score
        _hud = hudLayer;
        
        // Add main background to scene
        winSize = [CCDirector sharedDirector].winSize;
        self.background = [CCSprite spriteWithSpriteFrameName:@"Game_background1.png"];
        _background.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_background];
        
        // World width will be same as background widht
        worldWidth = _background.contentSize.width;
        
		//Get the sound engine instance
		soundEngine = [GameSoundManager sharedManager].soundEngine;
        
        // Initialize physics
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
        
        float widthInMeters = worldWidth / PTM_RATIO;
        float heightInMeters = (winSize.height + 150) / PTM_RATIO; 
        b2Vec2 lowerLeftCorner = b2Vec2(0, 0);
        b2Vec2 lowerRightCorner = b2Vec2(widthInMeters, 0); 
        b2Vec2 upperLeftCorner = b2Vec2(0, heightInMeters);
        b2Vec2 upperRightCorner = b2Vec2(widthInMeters, heightInMeters);
        
        // Bottom
        groundBox.SetAsEdge(lowerLeftCorner, lowerRightCorner);
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        // Top
        groundBox.SetAsEdge(upperLeftCorner, upperRightCorner);
        _groundBody->CreateFixture(&groundBoxDef);
        // Left
        groundBox.SetAsEdge(upperLeftCorner, lowerLeftCorner);
        _groundBody->CreateFixture(&groundBoxDef);
        // Right
        groundBox.SetAsEdge(upperRightCorner, lowerRightCorner);
        _groundBody->CreateFixture(&groundBoxDef);
        
        // Create birds contact listener
        _contactListener = new BirdsContactListener();
        _world->SetContactListener(_contactListener);
		
		// accelerometer
		self.isAccelerometerEnabled = YES;
		
        // Create rope
        [self createRope];
        
        // Set score
        _score = 0;
    }
    return self;
}

- (void)onEnter {
    
    [super onEnter];
    
    // Clear out old birds
    for (CCSprite *bird in _birds) {
        [_batchNode removeChild:bird cleanup:YES];
    }
    [_birds removeAllObjects];
    
    // Reset stats
    self.levelBegin = 0;
    self.lastTimeBirdAdded = 0;
    self.inLevel = YES;
    self.levelEnd = NO;

    // turn on bird spawning
    [self schedule:@selector(update:)];
    [self schedule:@selector(gameLogic:) interval:0.1f];
    
    // Register touch events
    [self registerWithTouchDispatcher];
    
    // Render score
    [self updateScore];
}

- (void)loveEventFor:(Bird *)birdA with:(Bird *)birdB {
    self.score++;
    int rnd = arc4random()%3;
    if (rnd == 0) {
        [soundEngine playEffect:@"love1.wav" pitch:1.0f pan:0.0f gain:1.0f];
    } else if (rnd == 1) {
        [soundEngine playEffect:@"love2.wav" pitch:1.0f pan:0.0f gain:1.0f];
    } else {
        [soundEngine playEffect:@"love3.wav" pitch:1.0f pan:0.0f gain:1.0f];
    }
    
    NSString *color = @"red";
    if (birdA.birdType == BirdTypeBlue) {
        color = @"blue";
    }
    
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 6; ++i) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                               [NSString stringWithFormat:@"%@-love%d.png", color, i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:animFrames delay:0.2f];
    
    AutoCleanSprite *loveSprite = [AutoCleanSprite spriteWithSpriteFrameName:[NSString stringWithFormat:@"%@-love1.png", color]];       
    loveSprite.position = birdA.position;
    loveSprite.tag = 3;
    
    CCAction *loveAction = [CCSequence actions:                          
                              [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO],
                              [CCCallFunc actionWithTarget:loveSprite selector:@selector(removeFromParent)],
                              nil];
    
    [_batchNode addChild:loveSprite z:5];
    [loveSprite runAction:loveAction];
}

- (void)battleEventFor:(Bird *)birdA with:(Bird *)birdB {
    if (self.score > 0) {
        self.score--;
    }
    if (arc4random()%2) {
        [soundEngine playEffect:@"fight1.wav" pitch:1.0f pan:0.0f gain:1.0f];
    } else {
        [soundEngine playEffect:@"fight2.wav" pitch:1.0f pan:0.0f gain:1.0f];
    }
    
    NSMutableArray *animFrames = [NSMutableArray array];
    for(int i = 1; i <= 15; ++i) {
        [animFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                  [NSString stringWithFormat:@"fight%d.png", i]]];
    }
    CCAnimation *anim = [CCAnimation animationWithFrames:animFrames delay:0.2f];
    
    AutoCleanSprite *battleSprite = [AutoCleanSprite spriteWithSpriteFrameName:@"fight1.png"];        
    battleSprite.position = birdA.position;
    battleSprite.tag = 3;

    CCAction *battleAction = [CCSequence actions:  
                        [CCAnimate actionWithAnimation:anim restoreOriginalFrame:NO],
                        [CCCallFunc actionWithTarget:battleSprite selector:@selector(removeFromParent)],
                        nil];
    
    [_batchNode addChild:battleSprite z:5];
    [battleSprite runAction:battleAction];
}

- (void)update:(ccTime)dt {
    
    if (!_inLevel) return;
    
    for (Bird *bird in _birds) {
        if (bird.flying == YES) {
            continue;
        }
        int rnd = arc4random()%500;
        if (rnd == 1) {
            [bird stopAllActions];
            [bird eye:TRUE];
        } else if (rnd == 10) {
            [bird stopAllActions];
            [bird beak:TRUE];
        } else if (rnd == 20) {
            bird.flipX = YES;
        } else if (rnd == 30) {
            bird.flipX = NO;
        }
    }
    
    // Advance the physics world by one step, using fixed time steps
//    float timeStep = 0.03f;
    int32 velocityIterations = 8;
    int32 positionIterations = 8;
    _world->Step(dt, velocityIterations, positionIterations);
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {   
        CCSprite *sprite = (CCSprite *)b->GetUserData();
        if (sprite != NULL) {
            sprite.position = [self toPixels:b->GetPosition()];
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            
            if (sprite.tag == BIRD_TAG) {
                Bird * bird = (Bird *)sprite;
                if (bird.flying == YES) {
                    b2Vec2 force = b2Vec2(0, 15.0f);
                    b->ApplyForce(force, b->GetWorldCenter());
                    int rnd = arc4random()%100;
                    if (rnd < 25) {
                        b2Vec2 force = b2Vec2(5.0f, .0f);
                        b->ApplyForce(force, b->GetWorldCenter());
                    } else if (rnd < 50) {
                        b2Vec2 force = b2Vec2(-5.0f, .0f);
                        b->ApplyForce(force, b->GetWorldCenter());
                    }
                }
            }
        }        
    }
    
    // Remove collided birds from scene
    std::vector<b2Body *>toBattle; 
    std::vector<b2Body *>toLove;
    std::vector<BirdsContact>::iterator pos;
    std::list<b2Body *>toDestroy;
    
    for(pos = _contactListener->_contacts.begin(); pos != _contactListener->_contacts.end(); ++pos) {
        BirdsContact contact = *pos;
        
        b2Body *bodyA = contact.fixtureA->GetBody();
        b2Body *bodyB = contact.fixtureB->GetBody();
        if (bodyA->GetUserData() != NULL && bodyB->GetUserData() != NULL) {
            CCSprite *spriteA = (CCSprite *) bodyA->GetUserData();
            CCSprite *spriteB = (CCSprite *) bodyB->GetUserData();
            
            if (spriteA && spriteB) {
                // Bird - Bird contact
                if ([spriteA isKindOfClass:[Bird class]] &&
                    [spriteB isKindOfClass:[Bird class]]) {
                    
                    Bird *birdA = (Bird*)spriteA;
                    Bird *birdB = (Bird*)spriteB;
                    
                    [birdA flight:NO];
                    [birdB flight:NO];
                    
                    // Same type -> love making
                    if ([birdA birdType] == [birdB birdType]) {
                        [self loveEventFor:birdA with:birdB];
                    // Different types -> battle
                    } else {
                        [self battleEventFor:birdA with:birdB];
                    }
                    toDestroy.push_back(bodyA);
                    toDestroy.push_back(bodyB);
                    [self updateScore];
                }
            }
        }        
    }
    
    toDestroy.unique();
    std::list<b2Body *>::iterator pos2;
    for(pos2 = toDestroy.begin(); pos2 != toDestroy.end(); ++pos2) {
        b2Body *body = *pos2;     
        if (body && body->GetUserData() != NULL) {
            CCSprite *sprite = (CCSprite *) body->GetUserData();
            if (sprite) {
                [_batchNode removeChild:sprite cleanup:YES];
                [_birds removeObject:sprite];
            }
        }
        
        for (b2JointEdge* jointEdge = body->GetJointList(); jointEdge != NULL; jointEdge = jointEdge->next) {
            b2Joint* targetJoint = jointEdge->joint;
            if (_mouseJoint == targetJoint) {
                _mouseJoint = NULL;
            } 
        }
        _world->DestroyBody(body);
    }
}

-(void)addBird:(Bird *)bird {
    
    // Determine where to spawn the bird along the X axis
    int actualX, positionTaken, diff, tries = 0;
    int minX = bird.contentSize.width/2;
    int maxX = worldWidth - bird.contentSize.width/2;
    int rangeX = maxX - minX;
    
    do {
        positionTaken = 0;
        tries++;
        actualX = (arc4random() % rangeX) + minX;
        for (CCSprite *bird in _birds) {
            diff = abs(actualX - bird.position.x);
            if(diff < minX) {
                positionTaken = 1;
                break;
            }
        }

    } while (tries < 10 && positionTaken);
    
    
    // Create the bird slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    bird.position = ccp(actualX, winSize.height + bird.contentSize.height/2);
    [_batchNode addChild:bird z:1];
    
    // Create bird body 
    b2BodyDef birdBodyDef;
    birdBodyDef.type = b2_dynamicBody;
    birdBodyDef.position = [self toMeters:bird.position];
    birdBodyDef.userData = bird;
    birdBodyDef.allowSleep = true;
    birdBodyDef.fixedRotation = true;
    b2Body *birdBody = _world->CreateBody(&birdBodyDef);
    
    // Create box shape and assing it to the bird fixture
    b2PolygonShape birdShape;
    
    birdShape.SetAsBox((bird.contentSize.width)/PTM_RATIO/2, (bird.contentSize.height-5)/PTM_RATIO/2);
    
    // Create shape definition and add to body
    b2FixtureDef birdShapeDef;
    birdShapeDef.shape = &birdShape;
    birdShapeDef.density = bird.weight;
    birdShapeDef.friction = 1.0f;
//    birdShapeDef.restitution = 0.1f;
    birdBody->CreateFixture(&birdShapeDef);

	// Add to birds array
	bird.tag = BIRD_TAG;
	[_birds addObject:bird];
}

-(void)addBirds {
    
    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;
    if ([curLevel.spawnIds count] > 0) {
        NSNumber *birdType = [curLevel.spawnIds lastObject];
        Bird *bird = [Bird birdWithType:(BirdType)birdType.intValue];
        [bird flight:YES];
        [self addBird:bird];
        [curLevel.spawnIds removeLastObject];
    } else {
        _levelEnd = YES;
    }
}

- (void)getNextLevel {
    
    b2Body *tmp = NULL;
    for(b2Body *b = _world->GetBodyList(); b;) {   
        CCSprite *sprite = (CCSprite *)b->GetUserData();
        
        tmp = b;
        b = b->GetNext();
        
        if (sprite && sprite.tag && sprite.tag == BIRD_TAG) {
            [_batchNode removeChild:sprite cleanup:YES];
            [_birds removeObject:sprite];
            _world->DestroyBody(tmp);
        }
        tmp = NULL;
    }
    
    // Remove animations (fight, love)
    for (CCSprite *sprt in _batchNode.children) {
        if (sprt.tag == 3) {
            [_batchNode removeChild:sprt cleanup:YES];
        }
    }
    
    _inLevel = FALSE;
    [self fadeOutMusic];
    [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
    
    AppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;        
    if (curLevel.isFinalLevel) {
        [delegate launchHappyEnding];
    } else {
        [delegate launchNextLevel];
    }
}

- (void)gameLogic:(ccTime)dt {
    
    if (!_inLevel) return;
    
    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;
    double now = [[NSDate date] timeIntervalSince1970];
    
    if (_levelBegin == 0) {
		//Start background music
		soundEngine.backgroundMusicVolume = 1.0f;
		[soundEngine rewindBackgroundMusic];
		[soundEngine playBackgroundMusic:@"game.caf"];
        self.levelBegin = now;
        
    } else if (_levelEnd) {
        if (_birds.count < 2) {
            [self getNextLevel];
        } else if (_birds.count == 2) {
            Bird *birdA = [_birds objectAtIndex:0];
            Bird *birdB = [_birds objectAtIndex:1];
            if (birdA.birdType != birdB.birdType) {
                [self getNextLevel];
            }
        }
    }
    
    // Spawn biirdoos
    if(_lastTimeBirdAdded == 0 || now - _lastTimeBirdAdded >= curLevel.spawnRate) {
        [self addBirds];
        self.lastTimeBirdAdded = now;
    }
}

- (void)registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return FALSE;
    CGPoint location = [self convertTouchToNodeSpace:touch];
    b2Vec2 locationWorld = [self toMeters:location];
    
    // Itereate all bodies in our world and all their fixtures
    // and check if touch location match with their position.
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {
        // User can grab only birds
        if(((CCSprite*)b->GetUserData()).tag != BIRD_TAG) {
            continue;
        }
        for(b2Fixture *f = b->GetFixtureList(); f; f=f->GetNext()) {
            if (f->TestPoint(locationWorld)) {
                b2MouseJointDef md;
                md.bodyA = _groundBody;
                md.bodyB = b;
                md.target = locationWorld;
                md.collideConnected = true;
                md.maxForce = 1000.0f * b->GetMass();
                
                ((Bird*)b->GetUserData()).flying = YES;
                
                _mouseJoint = (b2MouseJoint *)_world->CreateJoint(&md);
                b->SetAwake(true);
                
                [soundEngine playEffect:@"pickup2.wav" pitch:1.0f pan:0.0f gain:1.0f];
            }
        }
    }
    return TRUE;
}


- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {     
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    if (_mouseJoint) {
        b2Vec2 locationWorld = [self toMeters:location];
        _mouseJoint->SetTarget(locationWorld);
    }
}

- (void)ccTouchCancelled:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

- (void)ccTouchEnded:(UITouch *)touch withEvent:(UIEvent *)event {
    if (_mouseJoint) {
        _world->DestroyJoint(_mouseJoint);
        _mouseJoint = NULL;
    }
}

- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
	
	b2Vec2 originGravity = _world->GetGravity();
    b2Vec2 gravity(-acceleration.y * 5, originGravity.y);
    _world->SetGravity(gravity);
	
}

- (void)createRope {
    
	static float segmentWidth = 24.0f;
	static float segmentHeight = 5.0f;
	
//	NSLog(@"sirka sveta %f", worldWidth);
//	NSLog(@"segment size %f %f", segmentWidth, segmentHeight);
//	NSLog(@"pocet potrebnych segmentu %f", worldWidth/segmentWidth);
	
    b2PolygonShape shape;
    shape.SetAsBox(segmentWidth/PTM_RATIO/2, segmentHeight/PTM_RATIO/2);
    
    b2FixtureDef fd;
    fd.shape = &shape;
    fd.density = 1.0f;
//    fd.friction = 0.5f;
//    fd.restitution = 0.01f;
	
	b2BodyDef fixDef;
	fixDef.type = b2_staticBody;
	fixDef.position.Set(0, ROPE_HEIGHT/PTM_RATIO);
    fixDef.allowSleep = true;
	b2Body *leftFix = _world->CreateBody(&fixDef);
    
    b2RevoluteJointDef jd;
    jd.collideConnected = false;
//    tohle muzem omezit, ale pak se to musi prenastavit pro posledni blok
//    jd.lowerAngle = 0.0f * b2_pi;
//    jd.upperAngle = 0.0f * b2_pi;
//    jd.lowerAngle = -0.5f * b2_pi; // -90 degrees
//    jd.upperAngle = 0.25f * b2_pi; // 45 degrees
//    jd.enableLimit = true;
    jd.maxMotorTorque = 1000.0f;
    jd.motorSpeed = 0.0f;
    jd.enableMotor = true;
	
    b2Body* prevBody = leftFix;
    for (int32 i = 0; i < (worldWidth/segmentWidth); ++i)
    {   
        // Create and display sprite
        CCSprite * sprite = [CCSprite spriteWithSpriteFrameName:@"Bridge_block.png"];
        sprite.position = ccp((i * segmentWidth) + segmentWidth/2, ROPE_HEIGHT);
        sprite.tag = ROPE_TAG;
        [_batchNode addChild:sprite z:1];
        
		fixDef.type = b2_dynamicBody;
        fixDef.position = [self toMeters:sprite.position];
        fixDef.userData = sprite;
        b2Body* body = _world->CreateBody(&fixDef);
        body->CreateFixture(&fd);
        
        b2Vec2 anchor((i * segmentWidth)/PTM_RATIO, ROPE_HEIGHT/PTM_RATIO);
		jd.Initialize(prevBody, body, anchor);
		_world->CreateJoint(&jd);
        
		// NSLog(@"anchor point %d %d", i * PTM_RATIO, ROPE_HEIGHT);
        
        prevBody = body;
    }
    
    // Last sprite has to be "joint" to right edge
    fixDef.position.Set(worldWidth/PTM_RATIO, ROPE_HEIGHT/PTM_RATIO);
	fixDef.type = b2_staticBody;
	b2Body *rightFix = _world->CreateBody(&fixDef);
   	
	b2Vec2 anchor(worldWidth/PTM_RATIO, ROPE_HEIGHT/PTM_RATIO);
	jd.Initialize(prevBody, rightFix, anchor);
	_world->CreateJoint(&jd);
}

- (void) dealloc
{
    self.birds = nil;
    
    [super dealloc];
}

- (void)updateScore {
    [_hud setStatusString:[NSString stringWithFormat:@"%d", _score]];
}

-(void) fadeOutMusic {
	[[GameSoundManager sharedManager] fadeOutMusic];
}	

@end