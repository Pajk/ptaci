//
//  MainMenuScene.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "cocos2d.h"

@interface MainMenuLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_main_bkgrnd;
    CCSprite *_main_birds;
}
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *main_bkgrnd;
@property (nonatomic, assign) CCSprite *main_birds;
@end

@interface MainMenuScene : CCScene {
    MainMenuLayer *_layer;    
}
@property (nonatomic, assign) MainMenuLayer *layer;
@end
