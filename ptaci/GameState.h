//
//  GameState.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@class Level;

@interface GameState : NSObject {
    // Level pointer
    Level *_curLevel;
    
    // Normal levels
    NSMutableArray *_levels;
    int _curLevelIndex;
}

@property (nonatomic, retain) NSMutableArray *levels;
@property (nonatomic, assign) int curLevelIndex;
@property (nonatomic, retain) Level *curLevel;

- (void)reset;
- (void)nextLevel;
+ (GameState *)sharedState;

@end
