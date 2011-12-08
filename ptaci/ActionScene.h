//
//  HelloWorldLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "GLES-Render.h"
#import "BirdsContactListener.h"

@interface HudLayer : CCLayer {
    CCLabelTTF * _statusLabel;
}
- (void)setStatusString:(NSString *)string;
@end

@interface ActionLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_background;
    NSMutableArray *_birds;
    double _levelBegin;
    double _lastTimeBirdAdded;
    BOOL _inLevel;
    BOOL _levelEnd;
    HudLayer *_hud;
    int _score;
    
    b2World *_world;
    b2Body *_groundBody;
    b2Fixture *_bottomFixture;
    b2MouseJoint *_mouseJoint;
    BirdsContactListener *_contactListener;
    CGSize winSize;
    CGFloat worldWidth;
}
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *background;
@property (nonatomic, retain) NSMutableArray *birds;
@property (nonatomic, assign) BOOL levelEnd;
@property (nonatomic, assign) double levelBegin;
@property (nonatomic, assign) double lastTimeBirdAdded;
@property (nonatomic, assign) BOOL inLevel;
@property (nonatomic, assign) int score;

- (id) initWithHud:(HudLayer *)hudLayer;
@end

@interface ActionScene : CCScene {
    ActionLayer *_layer;
    HudLayer *_hudLayer;
}
@property (nonatomic, assign) ActionLayer *layer;
@property (nonatomic, assign) HudLayer *hudLayer;
@end



