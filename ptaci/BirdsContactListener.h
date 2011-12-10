//
//  BirdsContactListener.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "Box2D.h"
#import <vector>
#import <algorithm>

struct BirdsContact {
    b2Fixture *fixtureA;
    b2Fixture *fixtureB;
    bool operator==(const BirdsContact& other) const {
        return (fixtureA == other.fixtureA) && (fixtureB == other.fixtureB);
    }
};

class BirdsContactListener : public b2ContactListener {
    
public:
    std::vector<BirdsContact>_contacts;
    
	virtual void BeginContact(b2Contact* contact);
	virtual void EndContact(b2Contact* contact);
};

