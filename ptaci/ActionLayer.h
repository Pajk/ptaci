//
//  ActionLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"
#import "HUDLayer.h"
#import "Bird.h"

@interface ActionLayer : CCLayerColor
{
    CCSprite *_bear;
    CCAction *_walkAction;
    CCAction *_moveAction;
    BOOL _moving;
    
    CCSprite *background;
    Bird *selSprite;
    NSMutableArray *movableSprites;
    
    HUDLayer *_hud;
    int _score;
}

@property (nonatomic, retain) CCSprite *bear;
@property (nonatomic, retain) CCAction *walkAction;
@property (nonatomic, retain) CCAction *moveAction;
@property (nonatomic, assign) int score;

- (id)initWithHUD:(HUDLayer *)hud;
- (void)updateScore;

@end

