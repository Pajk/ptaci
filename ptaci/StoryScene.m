//
//  StoryScene.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//


#import "StoryScene.h"
#import "GameState.h"
#import "Level.h"
#import "AppDelegate.h"

@implementation StoryScene
@synthesize layer = _layer;

- (id)init {
    if ((self = [super init])) {
        self.layer = [[[StoryLayer alloc] init] autorelease];
        [self addChild:_layer];
    }
    return self;
}

@end

@implementation StoryLayer

@synthesize batchNode       = _batchNode;
@synthesize main_bkgrnd     = _main_bkgrnd;
@synthesize label           = _label;
@synthesize curStoryIndex   = _curStoryIndex;
@synthesize tapToCont       = _tapToCont;
@synthesize spriteNewGame   = _spriteNewGame;

- (id)init {
    if ((self = [super init])) {
        
        // Add a sprite sheet based on the loaded texture and add it to the scene
        self.batchNode = [CCSpriteBatchNode batchNodeWithTexture:[[CCTextureCache sharedTextureCache] addImage:@"sprites.png"]];
        [self addChild:_batchNode];
        
        // Add main background to scene
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"Menu_background.png"];
        _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_main_bkgrnd];
        
        // Add a label to the scene
        self.label = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(winSize.width-40, winSize.height-70) alignment:UITextAlignmentCenter fontName:@"Verdana" fontSize:24];
        _label.position = ccp(winSize.width/2, winSize.height/2);
        _label.color = ccc3(0, 0, 0);
        [self addChild:_label];
        
        // Add "tap to continue" sprite
        self.tapToCont = [CCSprite spriteWithSpriteFrameName:@"continue.png"];
        _tapToCont.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + 30);
        _tapToCont.visible = NO;
        [_batchNode addChild:_tapToCont];
        
        // Add "new game" sprite
        self.spriteNewGame = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        _spriteNewGame.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + 30);
        _spriteNewGame.visible = NO;
        [_batchNode addChild:_spriteNewGame];
    }
    return self;
}

- (void)displayCurStoryString {
    
    StoryLevel *curLevel = (StoryLevel *)[GameState sharedState].curLevel;
    NSString *curStoryString = [curLevel.storyStrings objectAtIndex:_curStoryIndex];
    [_label setString:curStoryString];
    
    if (curLevel.isGameOver && _curStoryIndex == curLevel.storyStrings.count - 1) {
        _spriteNewGame.visible = YES;
        _tapToCont.visible = NO;
    } else {
        _spriteNewGame.visible = NO;
        _tapToCont.visible = YES;
    }
    
}

- (void)onEnter {
    [super onEnter];
	
    // Display the current string
    _curStoryIndex = 0;
    [self displayCurStoryString];
    
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
    
    // Animate "tap to continue"
    [_tapToCont runAction:[CCRepeatForever actionWithAction:
                           [CCSequence actions:
                            [CCFadeOut actionWithDuration:2.0f],
                            [CCFadeIn actionWithDuration:2.0f],
                            nil]]];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _curStoryIndex++;
    StoryLevel *curLevel = (StoryLevel *)[GameState sharedState].curLevel;
    if (_curStoryIndex < curLevel.storyStrings.count) {
        [self displayCurStoryString];
    } else {
        AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        if (curLevel.isGameOver) {
            [delegate launchMainMenu];
        } else {
            [delegate launchNextLevel];
        }
    }
    return TRUE;
}

@end
