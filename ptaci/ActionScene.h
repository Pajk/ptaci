//
//  HelloWorldLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright FIT VUT 2011. All rights reserved.
//

#import "cocos2d.h"
#import "GLES-Render.h"
#import "BirdsContactListener.h"

@interface HudLayer : CCLayer {
    CCLabelTTF *_statusLabel;
    CCSprite *_statusHeart;
}
- (void)setStatusString:(NSString *)string;
@end

@interface ActionLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    HudLayer *_hud;
    CCSprite *_background;
    double  _levelBegin;
    double  _lastTimeBirdAdded;
    BOOL    _inLevel;
    BOOL    _levelEnd;

    CGSize winSize;
    CGFloat worldWidth;
    NSMutableArray *_birds;
    
    b2World *_world;
    b2Body *_groundBody;
    b2Fixture *_bottomFixture;
    b2MouseJoint *_mouseJoint;
    BirdsContactListener *_contactListener;
}
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *background;
@property (nonatomic, retain) NSMutableArray *birds;
@property (nonatomic, assign) double levelBegin;
@property (nonatomic, assign) double lastTimeBirdAdded;
@property (nonatomic, assign) BOOL levelEnd;
@property (nonatomic, assign) BOOL inLevel;

- (id) initWithHud:(HudLayer *)hudLayer;
@end

@interface ActionScene : CCScene {
    ActionLayer *_layer;
    HudLayer *_hudLayer;
}
@property (nonatomic, assign) ActionLayer *layer;
@property (nonatomic, assign) HudLayer *hudLayer;
@end



