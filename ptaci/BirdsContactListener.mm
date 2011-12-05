//
//  BirdsContactListener.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/3/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "BirdsContactListener.h"
#import "cocos2d.h" 
#import "Bird.h"

BirdsContactListener::BirdsContactListener() : _contacts() {
}

BirdsContactListener::~BirdsContactListener() {
}

void BirdsContactListener::BeginContact(b2Contact* contact) {
    
    CCSprite *spriteA = (CCSprite *)contact->GetFixtureA()->GetBody()->GetUserData();
    CCSprite *spriteB = (CCSprite *)contact->GetFixtureB()->GetBody()->GetUserData();
    NSInteger tagA = spriteA.tag;
    NSInteger tagB = spriteB.tag;
    
    // Contact bird <-> rope
    if ( tagA == 2 || tagB == 2) {
        if (tagA == 1) {
            [((Bird *)spriteA) flight:NO];
            
        } else if (tagB == 1) {
            [((Bird *)spriteB) flight:NO];
        }
        return;
    }
    
    // Create contact only for bird to bird
    if ( !( [((CCSprite *)contact->GetFixtureA()->GetBody()->GetUserData()) isKindOfClass:[Bird class]]) ||
         !( [((CCSprite *)contact->GetFixtureB()->GetBody()->GetUserData()) isKindOfClass:[Bird class]]) ) {
        return;
    }
    
    // Dont create new contact if one of the fixtures is in contact
    for (std::vector<BirdsContact>::iterator it = _contacts.begin(); it != _contacts.end(); ++it) {
    
        if ((*it).fixtureA == contact->GetFixtureA() || (*it).fixtureA == contact->GetFixtureB() ||
            (*it).fixtureB == contact->GetFixtureA() || (*it).fixtureB == contact->GetFixtureB()) {
            return;
        }
    }
    
    // We need to copy out the data because the b2Contact passed in is reused.
    BirdsContact birdContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(birdContact);
}

void BirdsContactListener::EndContact(b2Contact* contact) {
    BirdsContact birdContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    std::vector<BirdsContact>::iterator pos;
    pos = std::find(_contacts.begin(), _contacts.end(), birdContact);
    if (pos != _contacts.end()) {
        _contacts.erase(pos);
    }
}

void BirdsContactListener::PreSolve(b2Contact* contact, const b2Manifold* oldManifold) {
}

void BirdsContactListener::PostSolve(b2Contact* contact, const b2ContactImpulse* impulse) {
}

//
//void BirdsContactListener::BeginContact(b2Contact* contact)
//{
//    b2Body* bodyA = contact->GetFixtureA()->GetBody();
//    b2Body* bodyB = contact->GetFixtureB()->GetBody();
//    
//    CCSprite* spriteA = (CCSprite*)bodyA->GetUserData();
//    CCSprite* spriteB = (CCSprite*)bodyB->GetUserData();
//    
//    // Bird - Bird contact
//    if ([spriteA isKindOfClass:[Bird class]] &&
//        [spriteB isKindOfClass:[Bird class]]) {
//        
//        Bird *birdA = (Bird*)spriteA;
//        Bird *birdB = (Bird*)spriteB;
//        
//        // Same type -> love making
//        if ([spriteA isKindOfClass:[spriteB class]]) {
//            [this->layer updateScore];
//            birdA.color = ccRED;
//            birdB.color = ccRED;
//        // Different types -> battle
//        } else {
//            birdA.color = ccBLACK;
//            birdB.color = ccBLACK;
//        }
//    }
//}
//
//void BirdsContactListener::EndContact(b2Contact* contact)
//{
//    b2Body* bodyA = contact->GetFixtureA()->GetBody();
//    b2Body* bodyB = contact->GetFixtureB()->GetBody();
//    CCSprite* spriteA = (CCSprite*)bodyA->GetUserData();
//    CCSprite* spriteB = (CCSprite*)bodyB->GetUserData();
//    
//    if (spriteA != NULL && spriteB != NULL) {
//        spriteA.color = ccWHITE;
//        spriteB.color = ccWHITE;
//    }
//}
