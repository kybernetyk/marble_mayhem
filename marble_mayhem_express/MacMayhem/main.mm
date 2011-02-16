//
//  main.m
//  SDLTest
//
//  Created by jrk on 7/1/11.
//  Copyright 2011 flux forge. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <SDL/SDL.h>

#include "Game.h"
#include "RenderDevice.h"
#include "SoundSystem.h"
#include "BB_GameScene.h"

int SDL_main(int argc, char *argv[])
{
//    return NSApplicationMain(argc,  (const char **) argv);
	
//	printf("lol\n");
	
	// Init SDL video subsystem
	if ( SDL_Init (SDL_INIT_VIDEO) < 0 ) 
	{
        fprintf(stderr, "Couldn't initialize SDL: %s\n",
				SDL_GetError());
		exit(1);
	}

	SDL_WM_SetCaption ("Marble Mayhem",0);
	
	float scale = 1.0;
	
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
	SDL_SetVideoMode(SCREEN_W*scale, SCREEN_H*scale, 0, SDL_OPENGL);
	

	mx3::RenderDevice::sharedInstance()->init(scale);
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:
					   // [NSNumber numberWithBool: YES], @"com.minyxgames.fruitmunch.1",
					   [NSNumber numberWithFloat: 0.9], @"sfx_volume",
					   [NSNumber numberWithFloat: 0.5], @"music_volume",
					   [NSNumber numberWithBool: YES], @"particles_enabled",
					   [NSNumber numberWithInt: 4], @"num_of_fruits",
					   nil];
	
	[[NSUserDefaults standardUserDefaults] registerDefaults: d];
	
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	float sfx_vol = [defs floatForKey: @"sfx_volume"];
	float music_vol = [defs floatForKey: @"music_volume"];
	BOOL parts = [defs boolForKey: @"particles_enabled"];
	int numoffruits = [defs integerForKey: @"num_of_fruits"];
	g_GameState.num_of_fruits = numoffruits;

	NSLog(@"music vol: %f, sound vol: %f", music_vol, sfx_vol);
	
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
	g_ParticlesEnabled = parts;
	
	
	game::Game *the_game = new game::Game();
	the_game->init();
	mx3::SoundSystem::play_sound ("minyx_whisper.wav");

	
	//g_GameState.game_mode = GAME_MODE_TIMED;
	//the_game->startNewGame();
	
	//the_game->setNextScene(new game::GameScene());
	
	
	SDL_Event event; /* Event structure */
	bool bRunning = true;
	while (bRunning)
	{
		NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];

		while(SDL_PollEvent(&event))
		{
			switch(event.type)
			{
				case SDL_QUIT:
					bRunning = false;
					break;
				case SDL_KEYDOWN:
					if ( ( (KMOD_LMETA & event.key.keysym.mod) || (KMOD_RMETA & event.key.keysym.mod)) && event.key.keysym.sym == SDLK_q) 
					{ 
						bRunning = false;
					} 
					
					if (event.key.keysym.sym == SDLK_ESCAPE)
					{
						
						the_game->returnToMainMenu();
					}
					break;					
				default:
					break;
			}
		}

		the_game->update();
		the_game->render();
		//the_game.update();
		//the_game.render();

		SDL_GL_SwapBuffers();
		glClearColor(0.0,0.0,0.7,0.0);
		glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);	 // Clear The Screen And The Depth Buffer
		glLoadIdentity();	
	
		[pool drain];
		usleep(16666);
	}
	
	
	return 0;
}
