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
#include "GameScene.h"
#include "MenuScene.h"
#include "SimpleAudioEngine.h"

using namespace mx3;
using namespace game;

namespace game 
{
	#define FIXED_STEP_LOOP
	
	const int TICKS_PER_SECOND = DESIRED_FPS;
	const int SKIP_TICKS = 1000 / TICKS_PER_SECOND;
	const int MAX_FRAMESKIP = 5;
	const double FIXED_DELTA = (1.0/TICKS_PER_SECOND);
	unsigned int next_game_tick = 1;//SDL_GetTicks();
	int loops;
	float interpolation;
	bool paused = false;
	mx3::Timer timer;
	Game *g_pGame;	
	
	extern std::string sounds[];
	
	void Game::loadGlobalResources ()
	{
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"menu.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"endless.mp3"];
		[[SimpleAudioEngine sharedEngine] preloadBackgroundMusic: @"timed.mp3"];
	
		g_TextureManager.accquireTexture ("back.png");
		g_TextureManager.accquireTexture ("banana40.png");
		g_TextureManager.accquireTexture ("bug40.png");
		g_TextureManager.accquireTexture ("clock.png");
		g_TextureManager.accquireTexture ("grapes40.png");
		g_TextureManager.accquireTexture ("strawberry.png");
		g_TextureManager.accquireTexture ("bug40.png");
		g_TextureManager.accquireTexture ("orange40.png");
		g_TextureManager.accquireTexture ("pause.png");
		g_TextureManager.accquireTexture ("zomg.png");
		
		for (int i = 0; i < NUM_SOUNDS; i++)
		{
			//_soundSystem->registerSound (sounds[i], i);
			NSString *fn = [NSString stringWithCString: sounds[i].c_str() encoding: NSASCIIStringEncoding];
			if ([fn length] > 0)
				[[SimpleAudioEngine sharedEngine] preloadEffect: fn];
		}
		
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
		RenderDevice::sharedInstance()->beginRender();
		current_scene->render();
		current_scene->frameDone();
		RenderDevice::sharedInstance()->endRender();
	}
	
	void Game::terminate()
	{
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
		next_scene = new GameScene();
		next_scene->init();
	}
	
	void Game::returnToMainMenu ()
	{
		next_scene = new MenuScene();
		next_scene->init();
	}

	void Game::setPaused (bool b)
	{
		game::paused = b;

		if (!game::paused)
		{
			game::next_game_tick = mx3::GetTickCount();
			game::timer.update();
			game::timer.update();
		}
	}
}