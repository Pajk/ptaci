//
//  Level.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Level : NSObject {}
@end

@interface StoryLevel : Level {
    NSMutableArray *_storyStrings;
    NSMutableArray *_storyImages;
    BOOL _isGameOver;
}
@property (nonatomic, retain) NSMutableArray *storyStrings;
@property (nonatomic, retain) NSMutableArray *storyImages;
@property (nonatomic, assign) BOOL isGameOver;
@end


@interface ActionLevel : Level {
    float _spawnRate;
    int _minScore;
    BOOL _isFinalLevel;
    NSMutableArray *_spawnIds;
}
@property (nonatomic, assign) float spawnRate;
@property (nonatomic, assign) int minScore;
@property (nonatomic, assign) BOOL isFinalLevel;
@property (nonatomic, retain) NSMutableArray *spawnIds;
@end
