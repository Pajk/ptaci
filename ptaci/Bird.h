//
//  Bird.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

typedef enum {
    BirdTypeSlow,
    BirdTypeFast
} BirdType;

@interface Bird : CCSprite {
    BirdType _birdType;
    int _minMoveDuration;
    int _maxMoveDuration;
    float _weight;
    int _loveEffectSoundId;
}

@property (nonatomic, assign) BirdType birdType;
@property (nonatomic, assign) float weight;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;
@property (nonatomic, assign) int loveEffectSoundId;

+ (Bird *)birdWithType:(BirdType)birdType;

@end
