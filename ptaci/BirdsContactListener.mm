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

#define ROPE_TAG 2

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
        
        if (tagA == BIRD_TAG) {
            [((Bird *)spriteA) flight:NO];
        } else if (tagB == BIRD_TAG) {
            [((Bird *)spriteB) flight:NO];
        }
        return;
    }
    
    // Create contact only for bird to bird
    if ( !( [spriteA isKindOfClass:[Bird class]]) ||
         !( [spriteB isKindOfClass:[Bird class]]) ) {
        return;
    }
    
    // Dont create new contact if one of the fixtures is already in contact with some other bird
    for (std::vector<BirdsContact>::iterator it = _contacts.begin(); it != _contacts.end(); ++it) {
    
        if ((*it).fixtureA == contact->GetFixtureA() || (*it).fixtureA == contact->GetFixtureB() ||
            (*it).fixtureB == contact->GetFixtureA() || (*it).fixtureB == contact->GetFixtureB()) {
            return;
        }
    }
    
    // Dont collide if one of the birds is still flying (from outer space to rope)
    if (((Bird*)spriteA).flying == YES && ((Bird*)spriteB).flying == YES) {
        return;
    }
    
    // We need to copy out the data because the b2Contact passed in is reused.
    BirdsContact birdContact = { contact->GetFixtureA(), contact->GetFixtureB() };
    _contacts.push_back(birdContact);
}

void BirdsContactListener::EndContact(b2Contact* contact) {
//    CCSprite *spriteA = (CCSprite *)contact->GetFixtureA()->GetBody()->GetUserData();
//    CCSprite *spriteB = (CCSprite *)contact->GetFixtureB()->GetBody()->GetUserData();
//    NSLog(@"%d + %d", spriteA.tag, spriteB.tag);
//    if (spriteA && spriteB && spriteA.tag == BIRD_TAG && spriteB.tag == ROPE_TAG) {
//        ((Bird *)spriteA).flying = YES;
//    } else if (spriteA && spriteB && spriteB.tag == BIRD_TAG && spriteA.tag == ROPE_TAG) {
//        ((Bird *)spriteB).flying = YES;
//    }
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