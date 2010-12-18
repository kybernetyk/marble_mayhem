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
#import "SoundSystem.h"
#import "SimpleAudioEngine.h"
#import <GameKit/GameKit.h>
#import <QuartzCore/QuartzCore.h>

@implementation AppController
@synthesize mainMenuView;
@synthesize mainView;
@synthesize pauseView;
@synthesize gameOverView;
@synthesize settingsView;

- (void) setBorderAndCornersForView: (UIView *) aView
{
	[[aView layer] setCornerRadius: 8.0];
	[[aView layer] setMasksToBounds: YES];
	
	//0x9f9087
	
	
	
//	UIColor *col = [UIColor colorWithRed: (159.0/255.0) green: (144.0/255.0) blue: (135.0/255.0) alpha:1.0];
//	
//	[[aView layer] setBorderColor: [col CGColor]];
//	[[aView layer] setBorderWidth: 1.0];
	
}

- (id) init
{
	self = [super init];
	if (self)
	{
		[self retain]; //important! IB doesnt retain us!
		
		NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithBool: YES], @"com.minyxgames.fruitmunch.1",
						   [NSNumber numberWithFloat: 0.9], @"sfx_volume",
						   [NSNumber numberWithFloat: 0.5], @"music_volume",
						   [NSNumber numberWithBool: YES], @"particles_enabled",
						   nil];
		
		[[NSUserDefaults standardUserDefaults] registerDefaults: d];
		
		
		NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
		[dc addObserver: self selector: @selector(showMainMenu:) name: kShowMainMenu object: nil];
		[dc addObserver: self selector: @selector(hideMainMenu:) name: kHideMainMenu object: nil];
		[dc addObserver: self selector: @selector(showGameOverView:) name: kShowGameOverView object:nil];
		[dc addObserver: self selector: @selector(fbDidFail:) name: kFacebookSubmitDidFail object: nil];
		[dc addObserver: self selector: @selector(fbDidSucceed:) name: kFacebookSubmitDidSucceed object: nil];
		[dc addObserver: self selector: @selector(showPauseScreen:) name: kShowPauseScreen object: nil];
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
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	float sfx_vol = [defs floatForKey: @"sfx_volume"];
	float music_vol = [defs floatForKey: @"music_volume"];
	BOOL parts = [defs boolForKey: @"particles_enabled"];

/*	if (music_vol <= 0.0)
	{
		CDAudioManager *am = [CDAudioManager sharedManager];
		[am setMode: kAMM_FxOnly];
	}
	else
	{
		CDAudioManager *am = [CDAudioManager sharedManager];
		[am setMode: kAMM_FxPlusMusic];
		
	}*/
	
	
	mx3::SoundSystem::set_sfx_volume (sfx_vol);
	mx3::SoundSystem::set_music_volume (music_vol);
	mx3::SoundSystem::play_sound ("minyx.caf");
	g_ParticlesEnabled = parts;
	
	//[[SimpleAudioEngine sharedEngine] preloadEffect: @MENU_ITEM_SFX];
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
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	game::g_pGame->setPaused (false);
	game::g_pGame->returnToMainMenu();
	[pauseView removeFromSuperview];
	[self showMainMenu: nil];
}

- (void) showPauseMenu: (id) sender
{
	post_notification(kShowPauseScreen, nil);
}

- (void) showPauseScreen: (NSNotification *) notification
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	game::g_pGame->setPaused (true);
	[mainView addSubview: pauseView];
	
}

- (void) hidePauseMenu: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	game::g_pGame->setPaused (false);
	[pauseView removeFromSuperview];
}

- (void) hideMainMenu: (NSNotification *) notification
{
	[mainMenuView removeFromSuperview];
}

- (IBAction) startGame: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
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
		g_GameState.game_mode = [sender tag];

		NSString *strs[] = 
		{
			NULL,
			@"com.minyxgames.fruitmunch.timed",
			NULL,
			@"com.minyxgames.fruitmunch.testlol"
		};
		
		NSString *cat = strs[g_GameState.game_mode];
		
		if (cat)
		{			
			[g_pGameCenterManger reloadHighScoresForCategory: cat];
		}
		
		 
		 
		post_notification(kHideMainMenu);
		
		game::g_pGame->startNewGame();
	}
}

- (IBAction) showGameOverView: (id) sender
{
	[self setBorderAndCornersForView: rankLabel];
	//mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[mainView addSubview: gameOverView];
	
	[checkMark setHidden: YES];
	[activity stopAnimating];
	[fbShareButton setEnabled: YES];
	
	NSUInteger lastscore = [(GKScore*)[[g_pGameCenterManger top100_scores] lastObject] value];
	NSInteger lastrank = [(GKScore*)[[g_pGameCenterManger top100_scores] lastObject] rank];
	
	NSLog(@"lastscore: %i", lastscore);
	NSLog(@"lastrank: %i", lastrank);
	
	NSInteger playerrank = lastrank+1;
	NSInteger tmp = 0;
	
	for (GKScore *score in [g_pGameCenterManger top100_scores])
	{
		if (g_GameState.score > [score value] &&
			tmp < [score value])
		{
			playerrank = [score rank];
			tmp = [score value];
		}
	}
	
	NSLog(@"playerrank: %i", playerrank);
	g_GameState.player_rank = playerrank;
	
	if (playerrank <= 100)
	{
		NSString *s = [NSString stringWithFormat: @"World Wide Rank #%i!\nYou should brag about it on Facebook!", playerrank];
		[rankLabel setText: s];
		[rankLabel setHidden: NO];
	}
	else
	{
		[rankLabel setHidden: YES];
	}
}

- (IBAction) playAgain: (id) sender
{
	NSString *strs[] = 
	{
		NULL,
		@"com.minyxgames.fruitmunch.timed",
		NULL,
		@"com.minyxgames.fruitmunch.testlol"
	};
	
	NSString *cat = strs[g_GameState.game_mode];
	
	if (cat)
	{			
		[g_pGameCenterManger reloadHighScoresForCategory: cat];
	}
	
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	g_GameState.reset();
//	g_GameState.game_state = 0;
//	g_GameState.next_state = GAME_STATE_PREP;
	game::g_pGame->resetCurrentScene ();
	[gameOverView removeFromSuperview];
}

- (IBAction) goToMainMenuFromGameOverView: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	game::g_pGame->setPaused (false);
	game::g_pGame->returnToMainMenu();
	[gameOverView removeFromSuperview];
	[self showMainMenu: nil];
}

- (IBAction) showSettings: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	float sfx_vol = [defs floatForKey: @"sfx_volume"];
	float music_vol = [defs floatForKey: @"music_volume"];
	BOOL parts = [defs boolForKey: @"particles_enabled"];

	[sfxSlider setValue: sfx_vol];
	[musicSlider setValue: music_vol];
	[particleSwitch setOn: parts];

/*	IBOutlet UISlider *sfxSlider;
	IBOutlet UISlider *musicSlider;
	IBOutlet UISwitch *particleSwitch;*/
	
	[mainView addSubview: settingsView];
}

- (IBAction) hideSettings: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[[NSUserDefaults standardUserDefaults] synchronize];
	[settingsView removeFromSuperview];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
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
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowLeaderBoard object: nil];
	post_notification (kShowLeaderBoard);
}

- (void) showInAppStore: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowInAppStore object: nil];
	post_notification (kShowInAppStore);
}

- (void) showPromotion:(id)sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
//	NSNotificationCenter *dc = [NSNotificationCenter defaultCenter];
//	[dc postNotificationName: kShowPromotions object: nil];
	post_notification (kShowPromotionView);
}

- (IBAction) shareOnFacebook: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	[fbShareButton setEnabled: NO];
	[activity startAnimating];
	
	[[[UIApplication sharedApplication] delegate] initFBShare: self];
}

#pragma mark -
#pragma mark settings panel
- (IBAction) volumeDidChange: (id) sender
{
	UISlider *slider = (UISlider *)sender;
	float vol = [slider value];
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	
	//sfx
	if ([sender tag] == 1)
	{
		//[[SimpleAudioEngine sharedEngine] setEffectsVolume: vol];
		mx3::SoundSystem::set_sfx_volume (vol);
		[defs setFloat: vol forKey: @"sfx_volume"];
	}

	//music
	if ([sender tag] == 2)
	{
		//[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume: vol];
		mx3::SoundSystem::set_music_volume (vol);
		[defs setFloat: vol forKey: @"music_volume"];
	}
}

- (IBAction) particlesDidChange: (id) sender
{
	mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	g_ParticlesEnabled = [sender isOn];
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	[defs setBool: g_ParticlesEnabled forKey: @"particles_enabled"];
}

- (IBAction) playPing: (id) sender
{
	if ([sender tag] == 1)	//sfx slider needs a different ping
		mx3::SoundSystem::play_sound ("Good.mp3");
	else
		mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
}

#pragma mark -
#pragma mark in app datasource
- (NSString *) imageNameForProductID: (NSString *) productID
{
	if ([productID isEqualToString: kInAppFullGame])
		return @"full_game_screen.png";
	
	return nil;
}

- (NSString *) detailImageNameForProductID: (NSString *) productID
{
	if ([productID isEqualToString: kInAppFullGame])
		return @"puzzle_mode.png";
	
	return nil;
}

- (NSString *) detailImageCaptionForProductID: (NSString *) productID
{
	if ([productID isEqualToString: kInAppFullGame])
		return @"Puzzle Mode";
	
	return nil;
}

#pragma mark -
#pragma mark facebook datasource
- (void) fbDidFail: (NSNotification *) notification
{
	[checkMark setHidden: YES];
	[fbShareButton setEnabled: YES];
	[activity stopAnimating];
}

- (void) fbDidSucceed: (NSNotification *) notification
{
	[checkMark setHidden: NO];
	[activity stopAnimating];
	
}

- (NSString *) titleForFBShare
{
	NSString *ret = nil;
	
	if (g_GameState.player_rank <= 100)
		ret = @"World Wide Top 100 Score!!!";
	if (g_GameState.player_rank <= 75)
		ret = @"World Wide Top 75 Score!!!";
	if (g_GameState.player_rank <= 50)
		ret = @"World Wide Top 50 Score!!!";
	if (g_GameState.player_rank <= 25)
		ret = @"World Wide Top 25 Score!!!";
	if (g_GameState.player_rank <= 10)
		ret = @"World Wide Top 10 Score!!!";
	if (g_GameState.player_rank <= 5)
		ret = @"World Wide Top 5 Score!!!";
	if (g_GameState.player_rank <= 1)
		ret = @"I am #1!!! WORLD WIDE!!!";

	if (ret)
		return ret;
	
	if (g_GameState.game_mode == GAME_MODE_TIMED)
		return @"My Fruit Munch Time Challenge Score!";
	if (g_GameState.game_mode == GAME_MODE_SWEEP)
		return @"My Fruit Munch Puzzle Mode Score!";
	
	return @"Fruit Munch";
}
- (NSString *) captionForFBShare
{
	NSString *ret = nil;
	if (g_GameState.game_mode == GAME_MODE_TIMED)
		ret = [NSString stringWithFormat: @"I took a try on the Fruit Munch Time Challenge and scored %i points!", g_GameState.score];
	if (g_GameState.game_mode == GAME_MODE_SWEEP)
		ret = [NSString stringWithFormat: @"I took a try on the Fruit Munch Puzzle Mode and scored %i points!", g_GameState.score];
	
	NSString *add = nil;
	
	if (g_GameState.player_rank <= 100)
		add = [NSString stringWithFormat: @" That's world wide rank #%i!",g_GameState.player_rank];
	if (g_GameState.player_rank <= 25)
		add = [NSString stringWithFormat: @" That's world wide rank #%i!!",g_GameState.player_rank];
	if (g_GameState.player_rank <= 10)
		add = [NSString stringWithFormat: @" That's TOP 10!",g_GameState.player_rank];
	if (g_GameState.player_rank <= 5)
		add = [NSString stringWithFormat: @" That's TOP 5!",g_GameState.player_rank];
	if (g_GameState.player_rank <= 1)
		add = [NSString stringWithFormat: @" That's WORLD WIDE #1!!!",g_GameState.player_rank];
	
	if (add)
		ret = [ret stringByAppendingString: add];
	
	return ret;
}
- (NSString *) descriptionForFBShare
{
	int minutes = (int)(g_GameState.time_played / 60.0);
	int rest = ((int)g_GameState.time_played) - (minutes * 60.0);
	
	if (g_GameState.game_mode == GAME_MODE_TIMED)
		return [NSString stringWithFormat: @"Total # of fruits removed: %i. Session length: %02i:%02i min:sec. Fruit Munch is awesome!", g_GameState.total_killed, minutes, rest];

	if (g_GameState.game_mode == GAME_MODE_SWEEP)
		return [NSString stringWithFormat: @"Fruits left: %i. Session length: %02i:%02i min:sec. Fruit Munch is awesome!", g_GameState.fruits_on_board, minutes, rest];
	
	return @":-)";
}
- (NSString *) linkForFBShare
{
	return @"http://www.minyxgames.com";
}
- (NSString *) picurlForFBShare
{
	return @"http://www.minyxgames.com/minyx-ultra/icon_90.png";
}
#pragma mark -
#pragma mark in inapp
- (NSSet *) inAppProductIDs
{
	NSSet *iap = [NSSet setWithObjects:
				  kInAppFullGame,
				  @"com.minyxgames.fruitmunch.8",
				  @"com.minyxgames.fruitmunch.9",
				  nil];
	
	return iap;	
}

#pragma mark -
#pragma mark news
- (NSArray *) newsItemsForOffline
{
	return nil;
	
	NSArray *ret = [NSArray arrayWithObjects:
					@"Tip: Try to get AIDS.",
					@"Tip: Don't play with negros!",
					@"Tip: Try to remove many fruits at once to get bonus points.",
					@"Tip: For extra bonus try to rape your sister.",
					nil];
	return ret;
}


@end
