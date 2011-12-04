//
//  Bird.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bird.h"
#import "AppDelegate.h"

@implementation Bird

@synthesize birdType = _birdType;
@synthesize weight = _weight;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;
@synthesize loveEffectSoundId = _loveEffectSoundId;

+ (Bird *)birdWithType:(BirdType)birdType {
    Bird *bird = nil;
    switch (birdType) {
        case BirdTypeSlow:
            bird = [[[Bird alloc] initWithSpriteFrameName:@"Cat.png"] autorelease];
            bird.weight = 0.8f;
            bird.minMoveDuration = 6;
            bird.maxMoveDuration = 15;
            bird.loveEffectSoundId = SND_ID_LOVE_EFFECT;
            break;
            
        case BirdTypeFast:
            bird = [[[super alloc] initWithSpriteFrameName:@"Bird.png"] autorelease];
            bird.weight = 0.5f;
            bird.minMoveDuration = 3;
            bird.maxMoveDuration = 5;
            bird.loveEffectSoundId = SND_ID_LOVE_EFFECT;

        default:
            break;
    }
    bird.birdType = birdType;
    return bird;
}

@end
