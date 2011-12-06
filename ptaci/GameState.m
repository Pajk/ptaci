//
//  GameState.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameState.h"

#import "Level.h"
#import "Bird.h"

@implementation GameState

@synthesize levels = _levels;
@synthesize curLevelIndex = _curLevelIndex;
@synthesize curLevel = _curLevel;

static GameState *_sharedState = nil;

+ (GameState *)sharedState {
    if (!_sharedState) {
        _sharedState = [[GameState alloc] init];
    }
    return _sharedState;
}

- (id)init {
    
    if ((self = [super init])) {
        
        self.levels = [[[NSMutableArray alloc] init] autorelease];
        
        // Story 1
        StoryLevel *story1 = [[[StoryLevel alloc] init] autorelease];
        [story1.storyStrings addObject:@"Bla ble blo\n\nPip piip." ];
        [story1.storyStrings addObject:@"A bli blo piiip..."];
        [_levels addObject:story1];
        
        // Level 1
        ActionLevel *level1 = [[[ActionLevel alloc] init] autorelease];
        level1.spawnSeconds = 20;
        level1.spawnRate = 4;
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [_levels addObject:level1];
        
        // Story 2
        StoryLevel *story2 = [[[StoryLevel alloc] init] autorelease];
        [story2.storyStrings addObject:@"Piiiiiip pipiiiii." ];
        [_levels addObject:story2];
        
        // Level 2
        ActionLevel *level2 = [[[ActionLevel alloc] init] autorelease];
        level2.spawnSeconds = 25;
        level2.spawnRate = 3;
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [_levels addObject:level2];
        
        // Story 3
        StoryLevel *story3 = [[[StoryLevel alloc] init] autorelease];
        [story3.storyStrings addObject:@"You are bird master!"]; 
        [_levels addObject:story3];
        
        // Level 3
        ActionLevel *level3 = [[[ActionLevel alloc] init] autorelease];
        level3.spawnSeconds = 30;        
        level3.spawnRate = 1;
        level3.isFinalLevel = YES;
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [_levels addObject:level3];
    }
    return self;
}

- (void)reset {
    self.curLevelIndex = 0;
    self.curLevel = [_levels objectAtIndex:_curLevelIndex];
}

- (void)nextLevel {
    
    self.curLevelIndex++;
    if (_curLevelIndex < _levels.count) {
        self.curLevel = [_levels objectAtIndex:_curLevelIndex];
    } 
    
}

- (void) dealloc {
    _sharedState = nil;
    [super dealloc];
}

@end
