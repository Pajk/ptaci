//
//  LoadingScene.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface LoadingScene : CCScene {
}

@end

@interface LoadingLayer : CCLayer {
    CCSprite *_defaultImage;
    CCSpriteBatchNode *_batchNode;
    CCSprite *_main_bkgrnd;
    CCSprite *_main_title;
    CCSprite *_tapToCont;
    CCSprite *_loading;
    BOOL _isLoading;
    BOOL _imagesLoaded;
    BOOL _scenesLoaded;
}

@property (nonatomic, assign) CCSprite *defaultImage;
@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *main_bkgrnd;
@property (nonatomic, assign) CCSprite *main_title;
@property (nonatomic, assign) CCSprite *tapToCont;
@property (nonatomic, assign) CCSprite *loading;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL imagesLoaded;
@property (nonatomic, assign) BOOL scenesLoaded;

@end