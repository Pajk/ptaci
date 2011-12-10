//
//  GameState.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "cocos2d.h"

@class Level;

@interface GameState : NSObject {
    Level *_curLevel;
    Level *_happyEnding;
    int _curLevelIndex;
    int _score;
    NSMutableArray *_levels;
}
@property (nonatomic, retain) Level *curLevel;
@property (nonatomic, retain) Level *happyEnding;
@property (nonatomic, assign) int curLevelIndex;
@property (nonatomic, assign) int score;
@property (nonatomic, retain) NSMutableArray *levels;

- (void)reset;
- (void)nextLevel;
+ (GameState *)sharedState;

@end
