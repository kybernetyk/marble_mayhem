/*
 *  Game.mm
 *  Donnerfaust
 *
 *  Created by jrk on 1/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "ComponentV3.h"
#include "Game.h"
#include "Scene.h"
#include "globals.h"
#include "RenderDevice.h"
#include "Timer.h"
#include "BB_GameScene.h"
#include "MenuScene.h"
#include "SimpleAudioEngine.h"
#include "NotificationSystem.h"

using namespace mx3;
using namespace game;

namespace game 
{
	#define FIXED_STEP_LOOP
	
	const int TICKS_PER_SECOND = DESIRED_FPS;
	const int SKIP_TICKS = 1000 / TICKS_PER_SECOND;
	const int MAX_FRAMESKIP = 5;
	const float FIXED_DELTA = (1.0/TICKS_PER_SECOND);
	unsigned int next_game_tick = 1;//SDL_GetTicks();
	int loops;
	float interpolation;
	int paused = 0;
	mx3::Timer timer;
	Game *g_pGame;	
	
	mx3::PE_Proxy *g_pMarkerCache[BOARD_NUM_MARKERS];
	mx3::PE_Proxy *g_pExplosionCache[BOARD_NUM_MARKERS];
	mx3::PE_Proxy *g_pSparksCache[BOARD_NUM_MARKERS];

	
	extern std::string sounds[];
	
	void Game::loadGlobalResources ()
	{
		float t1 = mx3::GetFloatTime();
		CV3Log ("starting pre load: %f\n", t1);
		
		
		
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"menu.mp3"];
	//	[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"endless.mp3"];
	//	[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"timed.mp3"];
	
		for (int i = 0; i < NUM_SOUNDS; i++)
		{
			//_soundSystem->registerSound (sounds[i], i);
			
			SoundSystem::preload_sound (sounds[i]);
		}
		
		
		g_TextureManager.accquireTexture ("amatuer_back.png");
		g_TextureManager.accquireTexture ("fruits.png");
		g_TextureManager.accquireTexture ("impact20_0.png");
		Texture2D *t = g_TextureManager.accquireTexture ("schriften.png");
		t->setAntiAliasTexParams();
		
		
		g_TextureManager.accquireTexture ("holzpanel.png");
		g_TextureManager.accquireTexture ("clocks.png");
		g_TextureManager.accquireTexture ("pause.png");
		
		
		g_TextureManager.accquireTexture ("star1.png"); 
		g_TextureManager.accquireTexture ("star2.png"); 
		g_TextureManager.accquireTexture ("star3.png"); 
		g_TextureManager.accquireTexture ("star4.png"); 
		g_TextureManager.accquireTexture ("star5.png"); 
		g_TextureManager.accquireTexture ("star6.png"); 
		g_TextureManager.accquireTexture ("star7.png"); 
		g_TextureManager.accquireTexture ("star8.png"); 
		g_TextureManager.accquireTexture ("star9.png"); 
		
//		for (int i = 0; i < NUM_SOUNDS; i++)
//		{
//			//_soundSystem->registerSound (sounds[i], i);
//			NSString *fn = [NSString stringWithCString: sounds[i].c_str() encoding: NSASCIIStringEncoding];
//			if ([fn length] > 0)
//				[[SimpleAudioEngine sharedEngine] preloadEffect: fn];
//		}
		
		for (int i = 0; i < BOARD_NUM_MARKERS; i++)
		{
			PE_Proxy *pe = g_RenderableManager.accquireParticleEmmiter ("marker.pex");
			pe->z = 5.0;
			pe->do_not_delete = true;
			pe->stop();
			pe->reset();

			g_pMarkerCache[i] = pe;
		}

		for (int i = 0; i < BOARD_NUM_MARKERS; i++)
		{
			PE_Proxy *pe = g_RenderableManager.accquireParticleEmmiter ("goldstar2.pex");
			pe->z = 5.0;
			pe->do_not_delete = true;
			
			g_pExplosionCache[i] = pe;
		}
		
		for (int i = 0; i < BOARD_NUM_MARKERS; i++)
		{
			PE_Proxy *pe = g_RenderableManager.accquireParticleEmmiter ("marker.pex");
			pe->z = 5.0;
			pe->do_not_delete = true;
			
			g_pSparksCache[i] = pe;
		}

		float t2 = mx3::GetFloatTime();
		CV3Log ("pre load ended: %f\n", t2);
		CV3Log ("time to load: %f\n", (t2-t1));
//		
//		
//		NSString *loadTime = [NSString stringWithFormat: @"Loaded assets in %.2f seconds", (t2-t1)];
//		
//		UIAlertView *al = [[UIAlertView alloc] initWithTitle: @"No daddy no!" 
//													 message: loadTime 
//													delegate: nil 
//										   cancelButtonTitle: @"It's" 
//										   otherButtonTitles: @"too big", nil];
//		[al show];
//		[al release];
	}
	
	bool Game::init ()
	{
		g_pGame = this;
		loadGlobalResources();
		
		/*GameScene *gc = new GameScene();
		gc->init();
		delete gc;*/
		
		current_scene = new MenuScene();
		current_scene->init();
		
		next_game_tick = mx3::GetTickCount();
		paused = false;
		return true;
	}

	void Game::update ()
	{
		if (next_scene)
		{
			mx3::Scene *tmp = current_scene;
			
			current_scene = next_scene;
			
			tmp->end();
			delete tmp;
			
			next_scene = NULL;
			next_game_tick = mx3::GetTickCount();
			current_scene->init();
		}
		if (paused)
			return;

		timer.update();
		g_FPS = timer.printFPS(false);
		

#ifdef FIXED_STEP_LOOP
		loops = 0;
		while( mx3::GetTickCount() > next_game_tick && loops < MAX_FRAMESKIP) 
		{
			current_scene->update(FIXED_DELTA);
			next_game_tick += SKIP_TICKS;
			loops++;	
		}
		
#else
		current_scene->update(timer.fdelta());	//blob rotation doesn't work well with high dynamic delta! fix this before enabling dynamic delta
#endif
		
	}


	void Game::render ()
	{
#ifdef __ALLOW_RENDER_TO_TEXTURE__
		RenderDevice::sharedInstance()->setRenderTargetBackingTexture();
		RenderDevice::sharedInstance()->beginRender();
		current_scene->render();
		current_scene->frameDone();
		RenderDevice::sharedInstance()->endRender();

		RenderDevice::sharedInstance()->setRenderTargetScreen();
		RenderDevice::sharedInstance()->beginRender();
		glTranslatef( (0.5 * SCREEN_W),  (0.5 * SCREEN_H), 0);
		//glRotatef(45.0, 0, 0, 1.0);
		glTranslatef( -(0.5 * SCREEN_W),  -(0.5 * SCREEN_H), 0);
		
		RenderDevice::sharedInstance()->renderBackingTextureToScreen();
		RenderDevice::sharedInstance()->endRender();	
#else
		RenderDevice::sharedInstance()->beginRender();
		current_scene->render();
		current_scene->frameDone();
		RenderDevice::sharedInstance()->endRender();
#endif
	}
	
	void Game::terminate()
	{
		current_scene->end();
		current_scene = 0;
		CV3Log ("terminating ...\n");
	}
	
	
	
	void Game::saveGameState ()
	{
		CV3Log ("saving state ...\n");
	}
	
	void Game::restoreGameState ()
	{
		CV3Log ("restoring state ...\n");
	}

	
	void Game::startNewGame ()
	{
		next_scene = new BB_GameScene();
		//next_scene->init();
	}
	
	void Game::returnToMainMenu ()
	{
		if (current_scene->scene_type() != SCENE_TYPE_MAIN_MENU)
			next_scene = new MenuScene();
		//next_scene->init();
	}

	void Game::setPaused (bool b)
	{
		if (b)
			game::paused ++;
		else
			game::paused --;
		

		if (game::paused <= 0)
		{
			game::paused = 0;
			game::next_game_tick = mx3::GetTickCount();
			game::timer.update();
			game::timer.update();
		}
	}
	
	void Game::resetCurrentScene ()
	{
		current_scene->reset();
	}
	
	#pragma mark -
	#pragma mark app background unso
	void Game::appDidFinishLaunching ()
	{
		CV3Log ("Game::appDidFinishLaunching ()\n");
	}
	
	void Game::appDidBecomeActive ()
	{
		CV3Log ("Game::appDidBecomeActive ()\n");
		setPaused(false);
	}
	
	void Game::appWillEnterForeground ()
	{
		CV3Log ("Game::appWillEnterForeground ()\n");
	}
	
	void Game::appWillResignActive ()
	{
		if (current_scene)
		{
			if (current_scene->scene_type() == SCENE_TYPE_GAME && !paused)
			{
				//don't show pause when game over
				if (g_GameState.game_state != GAME_STATE_GAMEOVER &&
					g_GameState.game_state != GAME_STATE_SOLVED)
					post_notification(kShowPauseScreen);
			}
				
		}
		CV3Log ("Game::appWillResignActive ()\n");
		setPaused(true);
	}
	
	void Game::appDidEnterBackground ()
	{
		
		//g_TextureManager.purgeCache();
		CV3Log ("Game::appDidEnterBackground ()\n");		
	}
	
	void Game::appWillTerminate ()
	{
		CV3Log ("Game::appWillTerminate ()\n");		
	}
	
}