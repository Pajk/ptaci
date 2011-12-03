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
#define ROPE_HEIGHT 100
#define BIRDS_LIMIT 10

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
        
        winSize = [CCDirector sharedDirector].winSize;
		
        // physics init
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        _world = new b2World(gravity, true);
//        float32 timeStep = 1.0f / 60.f;
//        int32 velocityIterations = 10;
//        int32 positionIterations = 8;
//        _world->Step(timeStep, velocityIterations, positionIterations);
        
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        
        CGFloat width = background.contentSize.width/PTM_RATIO;
        // bottom edge
        groundBox.SetAsEdge(b2Vec2(0,ROPE_HEIGHT/PTM_RATIO), b2Vec2(width, ROPE_HEIGHT/PTM_RATIO));
        _bottomFixture = _groundBody->CreateFixture(&groundBoxDef);
        
        // left edge
        groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(0, winSize.height/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        // upper edge
        groundBox.SetAsEdge(b2Vec2(0, (winSize.height+200)/PTM_RATIO), b2Vec2(winSize.width/PTM_RATIO, (winSize.height+200)/PTM_RATIO));
        _groundBody->CreateFixture(&groundBoxDef);
        
        // right edge
        groundBox.SetAsEdge(b2Vec2(width, winSize.height/PTM_RATIO), b2Vec2(width, 0));
        _groundBody->CreateFixture(&groundBoxDef);
        
		// create rope
		[self createRope];
		
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

        Bird *sprite = (Bird *)b->GetUserData();
        
        if (sprite != NULL) {
            sprite.position = ccp(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
        }        
    }
}

- (void)createRope {
	
	// left fitting
	CCSprite *leftFitSprite = [CCSprite spriteWithFile:@"fitting.png"];
	leftFitSprite.position = ccp(0, ROPE_HEIGHT);
	[self addChild:leftFitSprite];
	
	b2CircleShape leftFitShape;
	leftFitShape.m_radius = 10.0f/PTM_RATIO;
	b2FixtureDef leftFitFixture;
	leftFitFixture.shape = &leftFitShape;
	b2BodyDef leftFitBodyDef;
	leftFitBodyDef.position.Set(leftFitSprite.position.x/PTM_RATIO, leftFitSprite.position.y/PTM_RATIO);
	b2Body *leftFitBody = _world->CreateBody(&leftFitBodyDef);
	leftFitBody->CreateFixture(&leftFitFixture);
	
	// right fittng
	CCSprite *rightFitSprite = [CCSprite spriteWithFile:@"fitting.png"];
	rightFitSprite.position = ccp(background.contentSize.width, ROPE_HEIGHT);
	[self addChild:rightFitSprite];
	
	b2CircleShape rightFitShape;
	rightFitShape.m_radius = 10.0f/PTM_RATIO;
	b2FixtureDef rightFitFixture;
	rightFitFixture.shape = &rightFitShape;
	b2BodyDef rightFitBodyDef;
	rightFitBodyDef.position.Set(rightFitSprite.position.x/PTM_RATIO, rightFitSprite.position.y/PTM_RATIO);
	b2Body *rightFitBody = _world->CreateBody(&rightFitBodyDef);
	rightFitBody->CreateFixture(&rightFitFixture);
	
	// rope
	b2PolygonShape ropeShape;
	ropeShape.SetAsBox(50.0f/PTM_RATIO, 10.0f/PTM_RATIO);
	b2FixtureDef ropeFixture;
	ropeFixture.density = 1.0f;
	ropeFixture.shape = &ropeShape;
	b2BodyDef ropeBodyDef;
	ropeBodyDef.linearDamping = 0.2;
	ropeBodyDef.angularDamping = 0.2;
//	b2MassData ropeMass;
//	ropeMass.mass = 1;
//	ropeMass.I = 100;
	
	ropeBodyDef.position.Set(0, ROPE_HEIGHT/PTM_RATIO);
	b2Body *ropeBody = _world->CreateBody(&ropeBodyDef);
//	ropeBody->SetMassData(&ropeMass);
	ropeBody->CreateFixture(&ropeFixture);
	
	ropeBodyDef.position.Set(50.0f/PTM_RATIO, ROPE_HEIGHT/PTM_RATIO);
	ropeBody = _world->CreateBody(&ropeBodyDef);
	//	ropeBody->SetMassData(&ropeMass);
	ropeBody->CreateFixture(&ropeFixture);
	
	b2Body *ropeStart = leftFitBody;
	
	b2DistanceJointDef jointDef;
	b2DistanceJoint* joint;
	float dX = rightFitBody->GetPosition().x*PTM_RATIO;
	NSLog(@"width = %f", dX);
	int numSections = ceil(dX/50.0f);
	int segWidth = dX/numSections;
	NSLog(@"number of sections %d", numSections);
	
	for (int i=0; i<numSections; i++) {
		
		CCSprite *segmentSprite = [CCSprite spriteWithFile:@"segment.png"];
		segmentSprite.position = ccp((i*segWidth), ROPE_HEIGHT);
		[self addChild:segmentSprite];
		
		NSLog(@"add segment at %d %d", (i*segWidth), ROPE_HEIGHT);
			
		// mass data
//		b2MassData massData;
//		massData.mass = 0.8+0.8*i/numSections;
		
		ropeBodyDef.position.Set((i*segWidth)/PTM_RATIO, ROPE_HEIGHT/PTM_RATIO);
//		ropeBody = _world->CreateBody(&ropeBodyDef);
//		ropeBody->SetMassData(&massData);
		ropeBody->CreateFixture(&ropeFixture);
		
//		jointDef.Initialize(ropeStart, ropeBody, ropeStart->GetPosition(),ropeBody->GetPosition());
//		joint = (b2DistanceJoint*) _world->CreateJoint(&jointDef);
//		joint->SetLength(segWidth);

		ropeStart = ropeBody;
	}
	
	CCSprite *segmentSprite = [CCSprite spriteWithFile:@"segment.png"];
	segmentSprite.position = ccp((numSections*segWidth), ROPE_HEIGHT);
	[self addChild:segmentSprite];

	// last joint
//	jointDef.Initialize(ropeBody, rightFitBody, ropeBody->GetPosition(), rightFitBody->GetPosition());
//	joint = (b2DistanceJoint *)_world->CreateJoint(&jointDef);
//	joint->SetLength(segWidth);
}

-(void)addBird {
    
    if(_world->GetBodyCount() > BIRDS_LIMIT) {
        return;
    }
    
    Bird *bird = [HeavyAndSlowBird bird];
    // Determine where to spawn the bird along the X axis
    int minX = bird.contentSize.width/2;
    int maxX = background.contentSize.width - bird.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the bird slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    bird.position = ccp(actualX, winSize.height + (bird.contentSize.height/2));
    [self addChild:bird];
    
    // Create bird body 
    b2BodyDef birdBodyDef;
    birdBodyDef.type = b2_dynamicBody;
    birdBodyDef.position.Set(bird.position.x/PTM_RATIO, bird.position.y/PTM_RATIO);
    birdBodyDef.userData = bird;
    birdBodyDef.allowSleep = true;
//    birdBodyDef.fixedRotation = true;
    b2Body *birdBody = _world->CreateBody(&birdBodyDef);
    
    // Create circle shape
    b2PolygonShape circle;
    circle.SetAsBox((bird.contentSize.width-20)/PTM_RATIO/2, (bird.contentSize.height-20)/PTM_RATIO/2);
    
    // Create shape definition and add to body
    b2FixtureDef ballShapeDef;
    ballShapeDef.shape = &circle;
    ballShapeDef.density = 0.8f;
    ballShapeDef.friction = 1.0f;
    ballShapeDef.restitution = 0.1f;
    birdBody->CreateFixture(&ballShapeDef);
    //    [self letBirdFall:bird];
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
    
    if (_mouseJoint != NULL) return FALSE;
    CGPoint location = [self convertTouchToNodeSpace:touch];
    b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
    
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
            }
        }
    }

    return TRUE;
}

- (CGPoint)boundLayerPos:(CGPoint)newPos {
    CGPoint retval = newPos;
    retval.x = MIN(retval.x, 0);
    retval.x = MAX(retval.x, -background.contentSize.width+winSize.width); 
    retval.y = self.position.y;
    return retval;
}

- (void)ccTouchMoved:(UITouch *)touch withEvent:(UIEvent *)event {     
    
    CGPoint location = [self convertTouchToNodeSpace:touch];
    
    CGPoint oldTouchLocation = [touch previousLocationInView:touch.view];
    oldTouchLocation = [[CCDirector sharedDirector] convertToGL:oldTouchLocation];
    oldTouchLocation = [self convertToNodeSpace:oldTouchLocation];
    
    if (_mouseJoint == NULL) {
        
        CGPoint translation = ccpSub(location, oldTouchLocation);    
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];      
        
    } else {
        
        b2Vec2 locationWorld = b2Vec2(location.x/PTM_RATIO, location.y/PTM_RATIO);
        _mouseJoint->SetTarget(locationWorld);
//        if (location.x < 100 || location.x > winSize.width-100) {
        CGPoint translation = ccpSub(oldTouchLocation, location);   
        CGPoint newPos = ccpAdd(self.position, translation);
        self.position = [self boundLayerPos:newPos];  
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
