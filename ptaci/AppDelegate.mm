//
//  AppDelegate.m
//  ptaci
//
//  Created by Pavel Pokorny on 12/1/11.
//  Copyright FIT VUT 2011. All rights reserved.
//

#import "AppDelegate.h"
#import "cocos2d.h"
#import "LoadingScene.h"
#import "CDAudioManager.h"
#import "MainMenuScene.h"
#import "StoryScene.h"
#import "ActionScene.h"
#import "GameState.h"
#import "Level.h"
#import "GameSoundManager.h"

@implementation AppDelegate

@synthesize loadingScene = _loadingScene;
@synthesize mainMenuScene = _mainMenuScene;
@synthesize storyScene = _storyScene;
@synthesize actionScene = _actionScene;
@synthesize window;

- (void) applicationDidFinishLaunching:(UIApplication*)application
{
    // Sound initialization
	[[GameSoundManager sharedManager] setup];
    
	// Init the window
	window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// Use CADisplayLink director
	[CCDirector setDirectorType:kCCDirectorTypeDisplayLink];
	
	CCDirector *director = [CCDirector sharedDirector];
	
	//
	// Create the EAGLView manually
	//  1. Create a RGB565 format. Alternative: RGBA8
	//	2. depth format of 0 bit. Use 16 or 24 bit for 3d effects, like CCPageTurnTransition
	//
	EAGLView *glView = [EAGLView viewWithFrame:[window bounds]
								   pixelFormat:kEAGLColorFormatRGB565
								   depthFormat:0];
	
	// Attach the openglView to the director
	[director setOpenGLView:glView];
	
	// Enables High Res mode (Retina Display) on iPhone 4 and maintains low res on all other devices
	//if( ! [director enableRetinaDisplay:YES] )
	//	CCLOG(@"Retina Display Not supported");
	
	// Set landscape mode
	[director setDeviceOrientation:kCCDeviceOrientationLandscapeLeft];
	
    // FPS
	[director setAnimationInterval:1.0/50];
    
    // Show FPS on screen
	[director setDisplayFPS:NO];
	
	// Make the OpenGLView a child of the view controller
	[director setOpenGLView:glView];
	
	// Make the glview a child of the main window
	[window addSubview:glView];
	
    // Make the window visible
	[window makeKeyAndVisible];
	
	// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
	// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
	// You can change anytime.
    // Default: kCCTexture2DPixelFormat_RGBA8888
	[CCTexture2D setDefaultAlphaPixelFormat:kCCTexture2DPixelFormat_RGBA8888];
	
    // Alocate and run the loading scene
    self.loadingScene = [[[LoadingScene alloc] init] autorelease];		
	[director runWithScene: _loadingScene];
}

// Preload all scenes from game, they are initialized only once (here)
- (void)loadScenes {
    // Create a shared opengl context so any textures can be shared with the main content
    EAGLContext *k_context = [[[EAGLContext alloc]
                               initWithAPI:kEAGLRenderingAPIOpenGLES1
                               sharegroup:[[[[CCDirector sharedDirector] openGLView] context] sharegroup]] autorelease];    
    [EAGLContext setCurrentContext:k_context];
    
    self.mainMenuScene = [[[MainMenuScene alloc] init] autorelease];
    self.storyScene = [[[StoryScene alloc] init] autorelease];
    self.actionScene = [[[ActionScene alloc] init] autorelease];
}

// Show main menu using fade transition effect
- (void)launchMainMenu {
    [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:_mainMenuScene]];
}

// Start current level, it could be game or story level
- (void)launchCurLevel {
    Level *curLevel = [[GameState sharedState] curLevel];
    if ([curLevel isKindOfClass:[StoryLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:_storyScene]];
    } else if ([curLevel isKindOfClass:[ActionLevel class]]) {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFade transitionWithDuration:0.5f scene:_actionScene]];
    }
}

// Set next level as current and start it
- (void)launchNextLevel {
    [[GameState sharedState] nextLevel];
    [self launchCurLevel];
}

// Reset game state and start new game
- (void)launchNewGame { 
    [[GameState sharedState] reset];
    [self launchCurLevel];    
}

// Show ending story level
- (void)launchHappyEnding {
    [[(StoryLevel*)[GameState sharedState].happyEnding storyStrings] removeAllObjects];
    [[(StoryLevel*)[GameState sharedState].happyEnding storyStrings] addObject:[NSString stringWithFormat:@"Pipipiip PIPIIIP!!!\n piiIIP.\nScore: %d", [GameState sharedState].score]];
    
    [GameState sharedState].curLevel = [GameState sharedState].happyEnding;
    [self launchCurLevel];
}

- (void)applicationWillResignActive:(UIApplication *)application {
	[[CCDirector sharedDirector] pause];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	[[CCDirector sharedDirector] resume];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
	[[CCDirector sharedDirector] purgeCachedData];
}

-(void) applicationDidEnterBackground:(UIApplication*)application {
	[[CCDirector sharedDirector] stopAnimation];
}

-(void) applicationWillEnterForeground:(UIApplication*)application {
	[[CCDirector sharedDirector] startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
	CCDirector *director = [CCDirector sharedDirector];
	
	[[director openGLView] removeFromSuperview];
	
	[window release];
	
	[director end];	
}

- (void)applicationSignificantTimeChange:(UIApplication *)application {
	[[CCDirector sharedDirector] setNextDeltaTimeZero:YES];
}

- (void)dealloc {
    self.loadingScene = nil;
    self.mainMenuScene = nil;
    self.storyScene = nil;
    self.actionScene = nil;
	[[CCDirector sharedDirector] end];
	[window release];
	[super dealloc];
}

@end
