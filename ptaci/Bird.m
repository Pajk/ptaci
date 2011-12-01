//
//  Bird.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Bird.h"

@implementation Bird

@synthesize weight = _weight;
@synthesize minMoveDuration = _minMoveDuration;
@synthesize maxMoveDuration = _maxMoveDuration;

@end

@implementation HeavyAndSlowBird

+ (id)bird {
    
    HeavyAndSlowBird *bird = nil;
    if ((bird = [[[super alloc] initWithFile:@"Icon.png"] autorelease])) {
        bird.weight = 10;
        bird.minMoveDuration = 6;
        bird.maxMoveDuration = 15;
    }
    return bird;
}

@end

@implementation LightweightAndFastBird

+ (id)bird {
    
    LightweightAndFastBird *bird = nil;
    if ((bird = [[[super alloc] initWithFile:@"Icon-Small.png"] autorelease])) {
        bird.weight = 1;
        bird.minMoveDuration = 3;
        bird.maxMoveDuration = 5;
    }
    return bird;
}

@end
