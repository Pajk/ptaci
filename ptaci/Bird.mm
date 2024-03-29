//
//  Bird.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "Bird.h"
#import "AppDelegate.h"

@implementation Bird

@synthesize birdType        = _birdType;
@synthesize weight          = _weight;
@synthesize flightAction    = _flightAction;
@synthesize beakAction      = _beakAction;
@synthesize eyeAction       = _eyeAction;
@synthesize flying          = _flying;
@synthesize flyLeft         = _flyLeft;

// Create all bird animations
- (void)initActions {
    
    NSString *color = @"blue";
    if (self.birdType == BirdTypeRed) {
        color = @"red";
    }
   
    // Animate blue bird flight
    NSMutableArray *flightAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i) {
        [flightAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-wing%d.png", color, i]]];
    }
    for(int i = 4; i >= 1; --i) {
        [flightAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-wing%d.png", color, i]]];
    }
    CCAnimation *flightAnim = [CCAnimation animationWithFrames:flightAnimFrames delay:0.05f];
    self.flightAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:flightAnim restoreOriginalFrame:NO]];
    
    // Animate blue bird beak
    NSMutableArray *beakAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i) {
        [beakAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-beak%d.png", color, i]]];
    }
    for(int i = 4; i >= 1; --i) {
        [beakAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-beak%d.png", color, i]]];
    }
    CCAnimation *beakAnim = [CCAnimation animationWithFrames:beakAnimFrames delay:0.2f];
    self.beakAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:beakAnim restoreOriginalFrame:NO]];
    
    // Animate blue bird eye blink action
    NSMutableArray *eyeAnimFrames = [NSMutableArray array];
    for(int i = 1; i <= 4; ++i) {
        [eyeAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-eye%d.png", color, i]]];
    }
    for(int i = 4; i >= 1; --i) {
        [eyeAnimFrames addObject:[[CCSpriteFrameCache sharedSpriteFrameCache] spriteFrameByName:
                                     [NSString stringWithFormat:@"%@-eye%d.png", color, i]]];
    }
    CCAnimation *eyeAnim = [CCAnimation animationWithFrames:eyeAnimFrames delay:0.1f];
    self.eyeAction = [CCRepeatForever actionWithAction:[CCAnimate actionWithAnimation:eyeAnim restoreOriginalFrame:NO]];
    
}

- (Bird *)flight:(BOOL)state {
    if (state) {
        _flying = YES;
        [self runAction:_flightAction];
    } else {
        _flying = NO;
        [self stopAction:_flightAction];
    }
    return self;
}

- (Bird *)beak:(BOOL)state {
    if (state) {
        [self runAction:_beakAction];
    } else {
        [self stopAction:_beakAction];
    }
    return self;
}

- (Bird *)eye:(BOOL)state {
    if (state) {
        [self runAction:_eyeAction];
    } else {
        [self stopAction:_eyeAction];
    }
    return self;
}

// Create new bird object with given type
+ (Bird *)birdWithType:(BirdType)birdType {
    Bird *bird = nil;
    switch (birdType) {
        case BirdTypeBlue:
            bird = [[[Bird alloc] initWithSpriteFrameName:@"blue-wing1.png"] autorelease];
            bird.weight = 2.0f;
            break;
            
        case BirdTypeRed:
            bird = [[[super alloc] initWithSpriteFrameName:@"red-wing1.png"] autorelease];
            bird.weight = 1.0f;
            break;

        default:
            return nil;
            break;
    }
    bird.birdType = birdType;
    [bird initActions];
    return bird;
}

@end
