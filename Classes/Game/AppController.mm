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

@implementation AppController
@synthesize mainMenuView;
@synthesize mainView;
@synthesize pauseView;

- (NSSet *) inAppProductIDs
{
	NSSet *iap = [NSSet setWithObjects:
				  kInAppFullGame,
				  nil];
	
	return iap;	
}

- (id) init
{
	self = [super init];
	if (self)
	{
		[self retain];
		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
		[dc addObserver: self selector: @selector(showMainMenu:) name: @"ShowMainMenu" object: nil];
		[dc addObserver: self selector: @selector(hideMainMenu:) name: @"HideMainMenu" object: nil];
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
		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
		[dc postNotificationName: @"HideMainMenu" object: nil];
		
		
		g_GameState.game_mode = [sender tag];
		game::g_pGame->startNewGame();
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	NSLog(@"omg der buttonen indexen: %i, %@", buttonIndex,	[alertView buttonTitleAtIndex: buttonIndex]);
	if (buttonIndex == 1)
	{
		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
		[dc postNotificationName: @"ShowInAppStore" object: kInAppFullGame];
	}
}

- (void) showHighScores:(id)sender
{
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc postNotificationName: @"ShowGameCenterLeaderBoard" object: nil];
}

- (void) showInAppStore: (id) sender
{
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc postNotificationName: @"ShowInAppStore" object: nil];

}

- (void) showPromotion:(id)sender
{
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc postNotificationName: @"ShowPromotionView" object: nil];
}

#pragma mark -
#pragma mark in app datasource
- (NSString *) imageNameForProductID: (NSString *) productID
{
	return @"orange.png";
}

@end
