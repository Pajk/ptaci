//
//  AppDelegate.h
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

//#define CGROUP_TOTAL                2
//
//#define SND_ID_BACKGROUND_MUSIC     0
//#define SND_ID_BATTLE_EFFECT        1
//#define SND_ID_LOVE_EFFECT          2

@class LoadingScene;
@class MainMenuScene;
@class StoryScene;
@class ActionScene;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow		*window;
    LoadingScene    *_loadingScene;
    MainMenuScene   *_mainMenuScene;
    StoryScene      *_storyScene;
    ActionScene     *_actionScene;
}

@property (nonatomic, retain) UIWindow *window;
@property (nonatomic, retain) LoadingScene *loadingScene;
@property (nonatomic, retain) MainMenuScene *mainMenuScene;
@property (nonatomic, retain) StoryScene *storyScene;
@property (nonatomic, retain) ActionScene *actionScene;

- (void)loadScenes;
- (void)launchMainMenu;
- (void)launchNewGame;
- (void)launchNextLevel;
- (void)launchHappyEnding;

@end
