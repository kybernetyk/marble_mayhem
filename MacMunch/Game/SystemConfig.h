/*
 *  SystemConfig.h
 *  ComponentV3
 *
 *  Created by jrk on 10/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once

//entity system checks and infos
#define __VERBOSE__

#ifdef __VERBOSE__
	#define CV3Log printf
#else
	#define CV3Log //
	#define NSLog(...)
#endif

//#define __RUNTIME_INFORMATION__
//#define __ABORT_GUARDS__
//#define __ENTITY_MANAGER_WARNINGS__

//#define USE_GAMECENTER
//#define USE_INAPPSTORE

//#define USE_NEWSFEED


//#define USE_FACEBOOK
//#define FB_APP_ID @"154580501257727"
//#define FB_API_KEY @"ba9e96e77b1f0114604d5637d346b43f"


//#define USE_PROMOTION
//#define PROMOTION_URL @"http://www.minyxgames.com/more_games/promotion_portrait.html"

#define MENU_ITEM_SFX "click.wav"

#define MAX_REGISTERED_SOUNDS 32

#define PORTRAIT 0x01
#define LANDSCAPE 0x02

//device orientation mode
//#define ORIENTATION_LANDSCAPE
#define ORIENTATION_PORTRAIT
#define MAINVIEWNIBNAME @"MainViewController_fmunch"

#define DESIRED_FPS 60.0

//screen size
#ifdef ORIENTATION_PORTRAIT
	#define SCREEN_W 640.0
	#define SCREEN_H 480.0
	#ifndef MAINVIEWNIBNAME
		#define MAINVIEWNIBNAME @"MainViewController_portrait"
	#endif
#endif
#ifdef ORIENTATION_LANDSCAPE
	#define SCREEN_W 480.0
	#define SCREEN_H 320.0
	#ifdef MAINVIEWNIBNAME
		#define MAINVIEWNIBNAME @"MainViewController_landscape"
	#endif
#endif

//allow offscreen texture rendertarget for the RenderDevice
//#define __ALLOW_RENDER_TO_TEXTURE__

//enable/disable gesture recogniz
//#define __ENABLE_GESTURE_RECOGNIZERS__

//Entity Manager
#define MAX_ENTITIES 512
#define MAX_COMPONENTS_PER_ENTITY 32

/* convention for slots:
	use multiples of 2
	lower half is registered for the system
	upper half is free for user use

	example with MAX_COMPONENTS_PER_ENTITY = 32:
	internal system use: 0..15 (0 is reserved and not valid!)
	user use: 16..31
*/