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

void BirdsContactListener::BeginContact(b2Contact* contact)
{
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    
    CCSprite* spriteA = (CCSprite*)bodyA->GetUserData();
    CCSprite* spriteB = (CCSprite*)bodyB->GetUserData();
    
    // Bird - Bird contact
    if ([spriteA isKindOfClass:[Bird class]] &&
        [spriteB isKindOfClass:[Bird class]]) {
        
        Bird *birdA = (Bird*)spriteA;
        Bird *birdB = (Bird*)spriteB;
        
        // Same type -> love making
        if ([spriteA isKindOfClass:[spriteB class]]) {
            birdA.color = ccRED;
            birdB.color = ccRED;
        // Different types -> battle
        } else {
            birdA.color = ccBLACK;
            birdB.color = ccBLACK;
        }
    }
}

void BirdsContactListener::EndContact(b2Contact* contact)
{
    b2Body* bodyA = contact->GetFixtureA()->GetBody();
    b2Body* bodyB = contact->GetFixtureB()->GetBody();
    CCSprite* spriteA = (CCSprite*)bodyA->GetUserData();
    CCSprite* spriteB = (CCSprite*)bodyB->GetUserData();
    
    if (spriteA != NULL && spriteB != NULL) {
        spriteA.color = ccWHITE;
        spriteB.color = ccWHITE;
    }
}