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
#define BIRDS_LIMIT 40

@implementation ActionLayer

@synthesize score = _score;

- (b2Vec2)toMeters:(CGPoint)point {
    return b2Vec2(point.x / PTM_RATIO, point.y / PTM_RATIO);
}

- (CGPoint)toPixels:(b2Vec2)vec {
    return ccpMult(CGPointMake(vec.x, vec.y), PTM_RATIO);
}

-(void) enableBox2dDebugDrawing {
    debugDraw = new GLESDebugDraw( PTM_RATIO );
    _world->SetDebugDraw(debugDraw);
    
    uint32 flags = 0;
    flags += b2DebugDraw::e_shapeBit;
    //		flags += b2DebugDraw::e_jointBit;
    //		flags += b2DebugDraw::e_aabbBit;
    //		flags += b2DebugDraw::e_pairBit;
    //		flags += b2DebugDraw::e_centerOfMassBit;
    debugDraw->SetFlags(flags);		
}

- (void)draw {
    glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    
    
	// Draws the Box2d Data in RetinaDisplay
	glPushMatrix();
	
	float scale = CC_CONTENT_SCALE_FACTOR();
	glScalef( scale, scale, 1 );
	
	_world->DrawDebugData();
    
	glPopMatrix();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);	
    
}

- (id)initWithHUD:(HUDLayer *)hud
{
	if((self=[super initWithColor:ccc4(0,0,255,255)])) {
        
        // save reference to hud layer
        _hud = hud;
        // update user score
        _score = 0;
        [self updateScore];
        
        // set layer background
        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGB565];
        background = [CCSprite spriteWithFile:@"blue-shooting-stars.png"];
        worldWidth = background.contentSize.width;
        
//        background.anchorPoint = ccp(0,0);
//        [self addChild:background];
//        [CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_Default];
        
        winSize = [CCDirector sharedDirector].winSize;
		
        // physics init
        b2Vec2 gravity;
        gravity.Set(0.0f, -10.0f);
        _world = new b2World(gravity, true);
		
		// Debug Draw functions
        [self enableBox2dDebugDrawing];
		
		uint32 flags = 0;
		flags |= b2DebugDraw::e_shapeBit;
		flags |= b2DebugDraw::e_jointBit;
		// flags |= b2DebugDraw::e_aabbBit;
		// flags |= b2DebugDraw::e_pairBit;
		// flags |= b2DebugDraw::e_centerOfMassBit; 
		debugDraw->SetFlags(flags);
		
        // Create edges around the entire screen
        b2BodyDef groundBodyDef;
        groundBodyDef.position.Set(0,0);
        _groundBody = _world->CreateBody(&groundBodyDef);
        
        b2PolygonShape groundBox;
        b2FixtureDef groundBoxDef;
        groundBoxDef.shape = &groundBox;
        
        float widthInMeters = worldWidth / PTM_RATIO;
        float heightInMeters = (winSize.height + 200) / PTM_RATIO; 
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
        _birdsContactListener = new BirdsContactListener();
        _world->SetContactListener(_birdsContactListener);		
		
		// create rope
		[self createRope];
        
        // turn on bird spawning
        [self schedule:@selector(gameLogic:) interval:1.0];
        [self schedule:@selector(tick:)];
        
        [self registerWithTouchDispatcher];
	}
	return self;
}

- (void)tick:(ccTime) delta {
    // Advance the physics world by one step, using fixed time steps
    float timeStep = 0.03f;
    int32 velocityIterations = 8;
    int32 positionIterations = 1;
    _world->Step(timeStep, velocityIterations, positionIterations);
    
    for(b2Body *b = _world->GetBodyList(); b; b=b->GetNext()) {   

//        SPRITES
//        Bird *sprite = (Bird *)b->GetUserData();
//        if (sprite != NULL) {
//            sprite.position = [self toPixels:b->GetPosition()];
//            sprite.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
//        }        
    }
}

- (void)createRope {
    
}

-(void)addBird {
    
    if(_world->GetBodyCount() > BIRDS_LIMIT) {
        return;
    }
    
    Bird *bird = nil;
    if (arc4random()%(unsigned)2) {
        bird = [HeavyAndSlowBird bird];
    } else {
        bird = [LightweightAndFastBird bird];
    }
    // Determine where to spawn the bird along the X axis
    int minX = bird.contentSize.width/2;
    int maxX = worldWidth - bird.contentSize.width/2;
    int rangeX = maxX - minX;
    int actualX = (arc4random() % rangeX) + minX;
    
    // Create the bird slightly off-screen along the right edge,
    // and along a random position along the Y axis as calculated above
    bird.position = ccp(actualX, winSize.height + (bird.contentSize.height/2));
//    SPRITES
//    [self addChild:bird];
    
    // Create bird body 
    b2BodyDef birdBodyDef;
    birdBodyDef.type = b2_dynamicBody;
    birdBodyDef.position = [self toMeters:bird.position];
    birdBodyDef.userData = bird;
    birdBodyDef.allowSleep = true;
    birdBodyDef.fixedRotation = true;
    b2Body *birdBody = _world->CreateBody(&birdBodyDef);
    
    // Create box shape and assing it to the bird fixture
    b2PolygonShape shape;
    shape.SetAsBox((bird.contentSize.width-10)/PTM_RATIO/2, (bird.contentSize.height-10)/PTM_RATIO/2);
    
    // Create shape definition and add to body
    b2FixtureDef birdShapeDef;
    birdShapeDef.shape = &shape;
    birdShapeDef.density = 0.8f;
    birdShapeDef.friction = 1.0f;
    birdShapeDef.restitution = 0.1f;
    birdBody->CreateFixture(&birdShapeDef);
}

-(void)gameLogic:(ccTime)dt {
    [self addBird];
}

-(void) registerWithTouchDispatcher
{
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    
    if (_mouseJoint != NULL) return FALSE;
    CGPoint location = [self convertTouchToNodeSpace:touch];
    b2Vec2 locationWorld = [self toMeters:location];
    
    // itereate all bodies in our world and all their fixtures
    // and check if touch location match with their position
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
    retval.x = MAX(retval.x, -worldWidth+winSize.width); 
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
        
        b2Vec2 locationWorld = [self toMeters:location];
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
- (void)dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)

    delete _birdsContactListener;
    delete _world;
    _groundBody = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
