//
//  ActionLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

#import "HUDLayer.h"
#import "Bird.h"
#import "BirdsContactListener.h"

@interface ActionLayer : CCLayerColor
{   
    b2World *_world;
    b2Body *_groundBody;
    
    b2Fixture *_bottomFixture;
    
    b2MouseJoint *_mouseJoint;
	
	b2Body* boxBody;
    
    CCSprite *background;
    
    BirdsContactListener *_birdsContactListener;
    
    CGSize winSize;
    HUDLayer *_hud;
    int _score;
	
	GLESDebugDraw *debugDraw;
    CGFloat worldWidth;
}

@property (nonatomic, assign) int score;

- (id)initWithHUD:(HUDLayer *)hud;
- (void)updateScore;
- (void)createRope;

@end

