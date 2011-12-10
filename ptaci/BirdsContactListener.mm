//
//  BirdsContactListener.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 FIT VUT. All rights reserved.
//

#import "BirdsContactListener.h"
#import "cocos2d.h" 
#import "Bird.h"

#define ROPE_TAG 2

// Contact created, add it to contacts collection for further processing in ActionScene
void BirdsContactListener::BeginContact(b2Contact* contact) {
    b2Fixture *fixtureA = contact->GetFixtureA();
    b2Fixture *fixtureB = contact->GetFixtureB();
    CCSprite *spriteA = (CCSprite *)fixtureA->GetBody()->GetUserData();
    CCSprite *spriteB = (CCSprite *)fixtureB->GetBody()->GetUserData();
    NSInteger tagA = spriteA.tag;
    NSInteger tagB = spriteB.tag;
    
    // Contact bird <-> rope
    if (tagA == BIRD_TAG && tagB == ROPE_TAG) {
        [((Bird *)spriteA) flight:NO];
        return;
    } else if (tagA == ROPE_TAG && tagB == BIRD_TAG) {
        [((Bird *)spriteB) flight:NO];
        return;
    }
    
    // Create contact only for bird to bird
    if (tagA != BIRD_TAG || tagB != BIRD_TAG) {
        return;
    }
    
    // Dont create new contact if one of the fixtures is already in contact with some other bird
    for (std::vector<BirdsContact>::iterator it = _contacts.begin(); it != _contacts.end(); ++it) {
    
        if ((*it).fixtureA == fixtureA || (*it).fixtureA == fixtureB ||
            (*it).fixtureB == fixtureA || (*it).fixtureB == fixtureB) {
            return;
        }
    }
    
    // Dont collide if one of the birds is still flying (from outer space to rope)
    if (((Bird*)spriteA).flying == YES && ((Bird*)spriteB).flying == YES) {
        return;
    }
    
    // We need to copy out the data because the b2Contact passed in is reused
    BirdsContact birdContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(birdContact);
}

// Contact ended, remove it from contacts collection
void BirdsContactListener::EndContact(b2Contact* contact) {
    
    BirdsContact birdContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<BirdsContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), birdContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}
