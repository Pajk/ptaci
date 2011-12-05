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
#import <list>

#define PTM_RATIO 32
#define ROPE_HEIGHT 100
#define BIRDS_LIMIT 40
#define BIRD_TAG 1
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
        _statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12.0];
        _statusLabel.position = ccp(winSize.width* 0.85, winSize.height * 0.9);
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
@synthesize birdColision    = _birdColision;
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
        
        // Show game score
        _hud = hudLayer;
        
        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        
        [self addChild:_batchNode z:-1];
        
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
        float heightInMeters = (winSize.height + 500) / PTM_RATIO; 
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
		
        // Create rope
        [self createRope];
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

    // turn on bird spawning
    [self schedule:@selector(update:)];
    [self schedule:@selector(gameLogic:) interval:0.1f];
    
    // Register touch events
    [self registerWithTouchDispatcher];
    
    // Render score
    _score = 0;
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
}

- (void)battleEventFor:(Bird *)birdA with:(Bird *)birdB {
    self.score--;
    if (arc4random()%2) {
        [soundEngine playEffect:@"fight1.wav" pitch:1.0f pan:0.0f gain:1.0f];
    } else {
        [soundEngine playEffect:@"fight2.wav" pitch:1.0f pan:0.0f gain:1.0f];
    }
}

- (void)update:(ccTime)dt {
    
    if (!_inLevel) return;
    
    for (Bird *bird in _birds) {
        int rnd = arc4random()%100;
        if (rnd < 10) {
            [bird stopAllActions];
            [bird eye:TRUE];
        } else if (rnd > 10 && rnd < 20) {
            [bird stopAllActions];
            [bird beak:TRUE];
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
    bird.position = ccp(actualX, winSize.height + (bird.contentSize.height));
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
    birdShape.SetAsBox((bird.contentSize.width)/PTM_RATIO/2, (bird.contentSize.height)/PTM_RATIO/2);
    
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
    for (NSNumber *birdIdNumber in curLevel.spawnIds) {
        int birdId = birdIdNumber.intValue;
        Bird *bird = [Bird birdWithType:(BirdType)birdId];
        [bird flight:YES];
        if (bird != nil) {
            [self addBird:bird];
        }
    }
}

-(void)gameLogic:(ccTime)dt {
    
    if (!_inLevel) return;
    
    ActionLevel *curLevel = (ActionLevel *) [GameState sharedState].curLevel;
    double now = [[NSDate date] timeIntervalSince1970];
    
    if (_levelBegin == 0) {
		//Start background music
		soundEngine.backgroundMusicVolume = 1.0f;
		[soundEngine rewindBackgroundMusic];
		[soundEngine playBackgroundMusic:@"game.caf"];
        self.levelBegin = now;
        return;
    } else {
        if (now - _levelBegin >= curLevel.spawnSeconds) {
            
            if (_birds.count < 2) {
                _inLevel = FALSE;
                [self fadeOutMusic];
                [[CCTouchDispatcher sharedDispatcher] removeAllDelegates];
                AppDelegate*delegate = [[UIApplication sharedApplication] delegate];
                [delegate launchNextLevel];
            } 
            return;            
        }
    }
    
    // Spawn biirdoos
    if(_lastTimeBirdAdded == 0 || now - _lastTimeBirdAdded >= curLevel.spawnRate) {
        [self addBirds];
        self.lastTimeBirdAdded = now;
    }
}

-(void) registerWithTouchDispatcher
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
        for(b2Fixture *f = b->GetFixtureList(); f; f=f->GetNext()) {
            if (f->TestPoint(locationWorld)) {
                b2MouseJointDef md;
                md.bodyA = _groundBody;
                md.bodyB = b;
                md.target = locationWorld;
                md.collideConnected = true;
                md.maxForce = 1000.0f * b->GetMass();
                
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
//    fd.friction = 0.2f;
//    fd.restitution = 0.01f;
	
	b2BodyDef fixDef;
	fixDef.type = b2_kinematicBody;
	fixDef.position.Set(0, ROPE_HEIGHT/PTM_RATIO);
    fixDef.allowSleep = true;
	b2Body *leftFix = _world->CreateBody(&fixDef);
    
    b2RevoluteJointDef jd;
    jd.collideConnected = false;
//    tohle muzem omezit, ale pak se to musi prenastavit pro posledni blok
//    jd.lowerAngle = 0.0f * b2_pi;
//    jd.upperAngle = 0.1f * b2_pi;
//    jd.lowerAngle = -0.5f * b2_pi; // -90 degrees
//    jd.upperAngle = 0.25f * b2_pi; // 45 degrees
    jd.enableLimit = true;
    jd.maxMotorTorque = 10.0f;
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
	fixDef.type = b2_kinematicBody;
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
    [_hud setStatusString:[NSString stringWithFormat:@"%d <3", _score]];
}

-(void) fadeOutMusic {
	[[GameSoundManager sharedManager] fadeOutMusic];
}	

@end