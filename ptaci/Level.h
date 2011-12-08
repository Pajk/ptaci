//
//  Level.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject {
}
@end

@interface StoryLevel : Level {
    NSMutableArray *_storyStrings;
    BOOL _isGameOver;
    NSMutableArray *_backgroundNames;
}
@property (nonatomic, retain) NSMutableArray *storyStrings;
@property (nonatomic, retain) NSMutableArray *backgroundNames;
@property (nonatomic, assign) BOOL isGameOver;
@end


@interface ActionLevel : Level {
    float _spawnRate;
    int _minScore;
    NSMutableArray *_spawnIds;
    BOOL _isFinalLevel;
}
@property (nonatomic, assign) int minScore;
@property (nonatomic, assign) float spawnRate;
@property (nonatomic, retain) NSMutableArray *spawnIds;
@property (nonatomic, assign) BOOL isFinalLevel;
@end
