//
//  AppController.m
//  Donnerfaust
//
//  Created by jrk on 2/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import "AppController.h"
#include "Game.h"

@implementation AppController
@synthesize mainMenuView;
@synthesize mainView;
@synthesize pauseView;

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
	
	[super dealloc];
}

- (void) setup
{
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
	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
	[dc postNotificationName: @"HideMainMenu" object: nil];
	
	
	game::g_pGame->startNewGame();
}

@end
