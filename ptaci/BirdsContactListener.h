//
//  BirdsContactListener.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Box2D.h"

class BirdsContactListener : public b2ContactListener { 
    
private:
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
};
