//
//  HUDLayer.mm
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "HUDLayer.h"

#import "ActionLayer.h"
#import "GameScene.h"

@implementation HUDLayer

- (id)init {
    
    if ((self = [super init])) {
        
        CGSize winSize = [CCDirector sharedDirector].winSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			_statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12.0];
        } else {
            _statusLabel = [CCLabelTTF labelWithString:@"" fontName:@"Arial" fontSize:12.0];
        }
        _statusLabel.position = ccp(winSize.width* 0.85, winSize.height * 0.9);
        [self addChild:_statusLabel];        
    }
    return self;
}

- (void)setStatusString:(NSString *)string {
    _statusLabel.string = string;
}

- (void)restartTapped:(id)sender {
    
    // Reload the current scene
    CCScene *scene = [GameScene node];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionZoomFlipX transitionWithDuration:0.5 scene:scene]];
    
}

- (void)showRestartMenu:(BOOL)won {
    
    CGSize winSize = [CCDirector sharedDirector].winSize;
    
    NSString *message;
    if (won) {
        message = @"You win!";
    } else {
        message = @"You lose!";
    }
    
    CCLabelTTF *label;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:12.0];
    } else {
        label = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:12.0];
    }
    label.scale = 0.1;
    label.position = ccp(winSize.width/2, winSize.height * 0.6);
    [self addChild:label];
    
    CCLabelTTF *restartLabel;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        restartLabel = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:12.0];    
    } else {
        restartLabel = [CCLabelTTF labelWithString:message fontName:@"Arial" fontSize:12.0];  
    }
    
    CCMenuItemLabel *restartItem = [CCMenuItemLabel itemWithLabel:restartLabel target:self selector:@selector(restartTapped:)];
    restartItem.scale = 0.1;
    restartItem.position = ccp(winSize.width/2, winSize.height * 0.4);
    
    CCMenu *menu = [CCMenu menuWithItems:restartItem, nil];
    menu.position = CGPointZero;
    [self addChild:menu z:10];
    
    [restartItem runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    [label runAction:[CCScaleTo actionWithDuration:0.5 scale:1.0]];
    
}

@end
