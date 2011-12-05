//
//  Bird.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    BirdTypeRed,
    BirdTypeBlue
} BirdType;

@interface Bird : CCSprite {
    BirdType _birdType;
    int _minMoveDuration;
    int _maxMoveDuration;
    float _weight;
    int _loveEffectSoundId;
    CCAction *_flightAction;
    CCAction *_beakAction;
    CCAction *_eyeAction;
    BOOL _flying;
}

@property (nonatomic, assign) BirdType birdType;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) int loveEffectSoundId;
@property (nonatomic, retain) CCAction *flightAction;
@property (nonatomic, retain) CCAction *beakAction;
@property (nonatomic, retain) CCAction *eyeAction;
@property (nonatomic, assign) BOOL flying;

- (void)initActions;
- (Bird *)flight:(BOOL)state;
- (Bird *)eye:(BOOL)state;
- (Bird *)beak:(BOOL)state;

+ (Bird *)birdWithType:(BirdType)birdType;

@end
