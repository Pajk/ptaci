//
//  Bird.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "cocos2d.h"

#define BIRD_TAG 1

typedef enum {
    BirdTypeRed,
    BirdTypeBlue
} BirdType;

@interface Bird : CCSprite {
    BirdType _birdType;
    CCAction *_flightAction;
    CCAction *_beakAction;
    CCAction *_eyeAction;
    BOOL _flying;
    BOOL _flyLeft;
    float _weight;
}
@property (nonatomic, assign) BirdType birdType;
@property (nonatomic, retain) CCAction *flightAction;
@property (nonatomic, retain) CCAction *beakAction;
@property (nonatomic, retain) CCAction *eyeAction;
@property (nonatomic, assign) BOOL flying;
@property (nonatomic, assign) BOOL flyLeft;
@property (nonatomic, assign) float weight;

- (void)initActions;
- (Bird *)flight:(BOOL)state;
- (Bird *)eye:(BOOL)state;
- (Bird *)beak:(BOOL)state;

+ (Bird *)birdWithType:(BirdType)birdType;

@end
