//
//  Level.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "Level.h"

// Level is just clean NSObject but needed for level hierarchy
@implementation Level
@end

@implementation StoryLevel
@synthesize storyStrings    = _storyStrings;
@synthesize isGameOver      = _isGameOver;
@synthesize storyImages     = _storyImages;

- (id)init {
    if ((self = [super init])) {
        self.storyStrings = [[[NSMutableArray alloc] init] autorelease];  
        self.storyImages = [[[NSMutableArray alloc] init] autorelease];
    }
    return self;
}

- (void) dealloc {
    self.storyStrings = nil;
    self.storyImages = nil;
    [super dealloc];
}

@end

@implementation ActionLevel
@synthesize minScore        = _minScore;
@synthesize spawnRate       = _spawnRate;
@synthesize spawnIds        = _spawnIds;
@synthesize isFinalLevel    = _isFinalLevel;

- (id)init {
    if ((self = [super init])) {
        self.spawnIds = [[[NSMutableArray alloc] init] autorelease];        
    }
    return self;
}

- (void) dealloc {
    self.spawnIds = nil;
    [super dealloc];
}

@end