//
//  AppController.h
//  Donnerfaust
//
//  Created by jrk on 2/12/10.
//  Copyright 2010 flux forge. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kInAppFullGame @"com.minyxgames.fruitmunch.1"

@interface AppController : NSObject 
{
	UIView *mainView;
	UIView *mainMenuView;
	UIView *pauseView;
	UIView *gameOverView;
	UIView *settingsView;

	//game over
	IBOutlet UIButton *fbShareButton;
	IBOutlet UIActivityIndicatorView *activity;
	IBOutlet UIImageView *checkMark;
	IBOutlet UILabel *rankLabel;
	
	//settings
	IBOutlet UISlider *sfxSlider;
	IBOutlet UISlider *musicSlider;
	IBOutlet UISwitch *particleSwitch;
}

@property (readwrite, retain) IBOutlet UIView *mainMenuView;
@property (readwrite, retain) IBOutlet UIView *mainView;
@property (readwrite, retain) IBOutlet UIView *pauseView;
@property (readwrite, retain) IBOutlet UIView *gameOverView;
@property (readwrite, retain) IBOutlet UIView *settingsView;


- (IBAction) startGame: (id) sender;
- (IBAction) showPauseMenu: (id) sender;
- (IBAction) hidePauseMenu: (id) sender;
- (IBAction) returnToMainMenu: (id) sender;
- (IBAction) showHighScores: (id) sender;
- (IBAction) showInAppStore: (id) sender;
- (IBAction) showPromotion: (id) sender;
- (IBAction) shareOnFacebook: (id) sender;

- (IBAction) showSettings: (id) sender;
- (IBAction) hideSettings: (id) sender;

- (IBAction) playAgain: (id) sender;
- (IBAction) goToMainMenuFromGameOverView: (id) sender;

//settings panel
- (IBAction) volumeDidChange: (id) sender;
- (IBAction) particlesDidChange: (id) sender;
- (IBAction) playPing: (id) sender;

@end
