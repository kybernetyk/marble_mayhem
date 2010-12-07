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
}

@property (readwrite, retain) IBOutlet UIView *mainMenuView;
@property (readwrite, retain) IBOutlet UIView *mainView;
@property (readwrite, retain) IBOutlet UIView *pauseView;

- (IBAction) startGame: (id) sender;
- (IBAction) showPauseMenu: (id) sender;
- (IBAction) hidePauseMenu: (id) sender;
- (IBAction) returnToMainMenu: (id) sender;
- (IBAction) showHighScores: (id) sender;
- (IBAction) showInAppStore: (id) sender;
- (IBAction) showPromotion: (id) sender;
@end
