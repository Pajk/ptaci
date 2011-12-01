//
//  HUDLayer.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCLabelTTF * _statusLabel;
}

- (void)showRestartMenu:(BOOL)won;
- (void)setStatusString:(NSString *)string;

@end
