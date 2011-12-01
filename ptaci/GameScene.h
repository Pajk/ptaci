//
//  HelloWorldLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface BirdsLayer : CCLayerColor
{
}

@end

@interface GameScene : CCScene
{
    BirdsLayer *_layer;
}
@property (nonatomic, retain) BirdsLayer *layer;
@end

