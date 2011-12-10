//
//  StoryScene.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "cocos2d.h"

@interface StoryLayer : CCLayer {
    CCSpriteBatchNode *_batchNode;
    CCSprite *_main_bkgrnd;
    CCSprite *_story_image;
    CCLabelTTF *_label;
    CCSprite *_tapToCont;
    CCSprite *_spriteNewGame;
    int _curStoryIndex;
}

@property (nonatomic, assign) CCSpriteBatchNode *batchNode;
@property (nonatomic, assign) CCSprite *main_bkgrnd;
@property (nonatomic, assign) CCLabelTTF *label;
@property (nonatomic, assign) CCSprite *tapToCont;
@property (nonatomic, assign) CCSprite *spriteNewGame;
@property (nonatomic, assign) CCSprite *story_image;
@property (nonatomic, assign) int curStoryIndex;

@end

@interface StoryScene : CCScene {
    StoryLayer *_layer;
}

@property (nonatomic, assign) StoryLayer *layer;

@end
