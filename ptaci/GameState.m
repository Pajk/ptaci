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
@synthesize happyEnding = _happyEnding;

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
        [story1.backgroundNames addObject:@"help_ok.png"];
        [story1.backgroundNames addObject:@"help_wrong.png"];
        [_levels addObject:story1];
        
        // Level 1
        ActionLevel *level1 = [[[ActionLevel alloc] init] autorelease];
        level1.minScore = 20;
        level1.spawnRate = 4;
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level1.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [_levels addObject:level1];
        
        // Story 2
        StoryLevel *story2 = [[[StoryLevel alloc] init] autorelease];
        [story2.storyStrings addObject:@"Level 2" ];
        [_levels addObject:story2];
        
        // Level 2
        ActionLevel *level2 = [[[ActionLevel alloc] init] autorelease];
        level2.minScore = 25;
        level2.spawnRate = 3;
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level2.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [_levels addObject:level2];
        
        // Story 3
        StoryLevel *story3 = [[[StoryLevel alloc] init] autorelease];
        [story3.storyStrings addObject:@"Level 3\nYou are bird master!"]; 
        [_levels addObject:story3];
        
        // Level 3
        ActionLevel *level3 = [[[ActionLevel alloc] init] autorelease];
        level3.minScore = 30;        
        level3.spawnRate = 1;
        level3.isFinalLevel = YES;
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeRed]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [level3.spawnIds addObject:[NSNumber numberWithInt:BirdTypeBlue]];
        [_levels addObject:level3];
        
        // Happy ending
        StoryLevel *happyEnding = [[[StoryLevel alloc] init] autorelease];
        [happyEnding.storyStrings addObject:@"You killed all birdoos! Poor birdoos!\nShame on you:("];       
        happyEnding.isGameOver = YES;
        self.happyEnding = happyEnding;
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
