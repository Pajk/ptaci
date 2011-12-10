//
//  StoryScene.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
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
@synthesize story_image     = _story_image;
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
        
        // Add a label to the scene
        self.label = [CCLabelTTF labelWithString:@"" dimensions:CGSizeMake(winSize.width-40, winSize.height-70) alignment:UITextAlignmentCenter fontName:@"Verdana" fontSize:24];
        _label.position = ccp(winSize.width/2, winSize.height/2);
        _label.color = ccc3(0, 0, 0);
        [self addChild:_label];
        
        // Add "tap to continue" sprite
        self.tapToCont = [CCSprite spriteWithSpriteFrameName:@"continue.png"];
        _tapToCont.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + 30);
        _tapToCont.visible = NO;
        [_batchNode addChild:_tapToCont z:10];
        
        // Add "new game" sprite
        self.spriteNewGame = [CCSprite spriteWithSpriteFrameName:@"play.png"];
        _spriteNewGame.position = ccp(winSize.width / 2, _tapToCont.contentSize.height/2 + 30);
        _spriteNewGame.visible = NO;
        [_batchNode addChild:_spriteNewGame z:10];
        
        // Add background
        self.main_bkgrnd = [CCSprite spriteWithSpriteFrameName:@"menu_background.png"];
        _main_bkgrnd.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:_main_bkgrnd z:3];
    }
    return self;
}

- (void)displayCurStoryString {
    
    StoryLevel *curLevel = (StoryLevel *)[GameState sharedState].curLevel;
    
    // Set story string, could be some simple story but its just pipiiip
    // becouse we dont understand those birds:). If story string is not set, 
    // show empty label, do not hide or destroy it, its reused in others story sreens
    if (curLevel.storyStrings.count > 0) {
        NSString *curStoryString = [curLevel.storyStrings objectAtIndex:_curStoryIndex];
        [_label setString:curStoryString];
    } else {
        [_label setString:@""];
    }
    
    // Remove previous story image if exists
    if (_story_image) {
        [_batchNode removeChild:_story_image cleanup:YES];
        _story_image = nil;
    }

    // Show actual story image, it will on top of menu_background
    if (curLevel.storyImages.count > _curStoryIndex) {
        CGSize winSize = [CCDirector sharedDirector].winSize;
        self.story_image = [CCSprite spriteWithSpriteFrameName:[curLevel.storyImages objectAtIndex:_curStoryIndex]];
        _story_image.position = ccp(winSize.width/2, winSize.height/2);
        [_batchNode addChild:self.story_image z:5];
    }

    // Show 'continue' or 'new game' if gameOver set
    if (curLevel.isGameOver) {
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
    
    // Animate "tap to continue"
    [_tapToCont runAction:[CCRepeatForever actionWithAction:
                           [CCSequence actions:
                            [CCFadeOut actionWithDuration:2.0f],
                            [CCFadeIn actionWithDuration:2.0f],
                            nil]]];
    
    // Register with touch dispatcher
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate:self priority:0 swallowsTouches:YES];
}

- (BOOL)ccTouchBegan:(UITouch *)touch withEvent:(UIEvent *)event {
    _curStoryIndex++;
    StoryLevel *curLevel = (StoryLevel *)[GameState sharedState].curLevel;
    if (_curStoryIndex < curLevel.storyStrings.count || _curStoryIndex < curLevel.storyImages.count) {
        [self displayCurStoryString];
    } else {
        [[CCTouchDispatcher sharedDispatcher] removeDelegate:self];
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
