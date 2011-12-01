//
//  Bird.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface Bird : CCSprite {
    int _minMoveDuration;
    int _maxMoveDuration;
    int _weight;
}

@property (nonatomic, assign) int weight;
@property (nonatomic, assign) int minMoveDuration;
@property (nonatomic, assign) int maxMoveDuration;

@end

@interface LightweightAndFastBird : Bird {
}
+(id)bird;
@end

@interface HeavyAndSlowBird : Bird {
}
+(id)bird;
@end