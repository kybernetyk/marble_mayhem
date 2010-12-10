//
//  AppController.m
//  Donnerfaust
//
//  Created by jrk on 2/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "AppController.h"
#include "Game.h"
#include "globals.h"
#import "GameCenterManager.h"
#import "MKStoreManager.h"
#include "NotificationSystem.h"

@implementation AppController
@synthesize mainMenuView;
@synthesize mainView;
@synthesize pauseView;
@synthesize gameOverView;

- (NSSet *) inAppProductIDs
{
	NSSet *iap = [NSSet setWithObjects:
				  kInAppFullGame,
				  @"com.minyxgames.fruitmunch.8",
				  @"com.minyxgames.fruitmunch.9",
				  nil];
	
	return iap;	
}

- (NSArray *) newsItemsForOffline
{
	NSArray *ret = [NSArray arrayWithObjects:
					@"Tip: Try to get AIDS.",
					@"Tip: Don't play with negros!",
					@"Tip: Try to remove many fruits at once to get bonus points.",
					@"Tip: For extra bonus try to rape your sister.",
					nil];
	return ret;
}

- (id) init
{
	self = [super init];
	if (self)
	{
		[self retain]; //important! IB doesnt retain us!
		
//		NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
//						   [NSNumber numberWithBool: YES], @"com.minyxgames.fruitmunch.1",
//						   nil];
//		
//		[[NSUserDefaults standardUserDefaults] registerDefaults: d];
		
		
		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
		[dc addObserver: self selector: @selector(showMainMenu:) name: kShowMainMenu object: nil];
		[dc addObserver: self selector: @selector(hideMainMenu:) name: kHideMainMenu object: nil];
		[dc addObserver: self selector: @selector(showGameOverView:) name: kShowGameOverView object:nil];
	}
	return self;
}

- (void) dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver: self];
	
	NSLog(@"app controller sagt bai!");
	
	[super dealloc];
}

- (void) setup
{
	NSLog(@"appcontroller setup: %@", self);
	
	[self showMainMenu: nil];
}

- (void) showMainMenu: (NSNotification *) notification
{
	NSLog(@"showing main menu ...");
	NSLog(@"main view: %@", mainView);
	NSLog(@"main Menu View: %@", mainMenuView);
	
	[mainView addSubview: mainMenuView];
}

- (void) returnToMainMenu: (id) sender
{
	game::g_pGame->setPaused (false);
	game::g_pGame->returnToMainMenu();
	[pauseView removeFromSuperview];
	[self showMainMenu: nil];
}

- (void) showPauseMenu: (id) sender
{
	game::g_pGame->setPaused (!game::paused);
	[mainView addSubview: pauseView];
}

- (void) hidePauseMenu: (id) sender
{
	game::g_pGame->setPaused (false);
	[pauseView removeFromSuperview];
}

- (void) hideMainMenu: (NSNotification *) notification
{
	[mainMenuView removeFromSuperview];
}

- (IBAction) startGame: (id) sender
{
	if (![MKStoreManager isFeaturePurchased: kInAppFullGame] && [sender tag] != GAME_MODE_TIMED)
	{
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle: @"Unlock the full game!" 
															message: @"This game mode is not accessible until unlocked in the store. Open the store?" 
														   delegate: self 
												  cancelButtonTitle: @"No." 
												  otherButtonTitles: @"Yes!", nil];
		
		[alertView show];
		[alertView autorelease]; 
		
	}
	else
	{
//		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//		[dc postNotificationName: kHideMainMenu object: nil];

		post_notification(kHideMainMenu);
		
		g_GameState.game_mode = [sender tag];
		game::g_pGame->startNewGame();
	}
}

- (IBAction) showGameOverView: (id) sender
{
	[mainView addSubview: gameOverView];
}

- (IBAction) playAgain: (id) sender
{
	g_GameState.reset();
//	g_GameState.game_state = 0;
//	g_GameState.next_state = GAME_STATE_PREP;
	game::g_pGame->resetCurrentScene ();
	[gameOverView removeFromSuperview];
}

- (IBAction) goToMainMenuFromGameOverView: (id) sender
{
	game::g_pGame->setPaused (false);
	game::g_pGame->returnToMainMenu();
	[gameOverView removeFromSuperview];
	[self showMainMenu: nil];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"omg der buttonen indexen: %i, %@", buttonIndex,	[alertView buttonTitleAtIndex: buttonIndex]);
	if (buttonIndex == 1)
	{
//		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//		[dc postNotificationName: kShowInAppStore object: kInAppFullGame];
		post_notification(kShowInAppStore, kInAppFullGame);

	}
}

- (void) showHighScores:(id)sender
{
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowLeaderBoard object: nil];
	post_notification (kShowLeaderBoard);
}

- (void) showInAppStore: (id) sender
{
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowInAppStore object: nil];
	post_notification (kShowInAppStore);
}

- (void) showPromotion:(id)sender
{
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowPromotions object: nil];
	post_notification (kShowPromotions);
}

#pragma mark -
#pragma mark in app datasource
- (NSString *) imageNameForProductID: (NSString *) productID
{
	return @"full_game_screen.png";
}

@end
