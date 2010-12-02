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

using namespace mx3;
using namespace game;

namespace game 
{
	#define FIXED_STEP_LOOP
	
	const int TICKS_PER_SECOND = 60;
	const int SKIP_TICKS = 1000 / TICKS_PER_SECOND;
	const int MAX_FRAMESKIP = 5;
	const double FIXED_DELTA = (1.0/TICKS_PER_SECOND);
	unsigned int next_game_tick = 1;//SDL_GetTicks();
	int loops;
	float interpolation;
	bool paused = false;
	mx3::Timer timer;
		
	
	

	bool Game::init ()
	{
		
		scene = new Scene();
		scene->init();
		
		next_game_tick = mx3::GetTickCount();
		paused = false;
		return true;
	}

	void Game::update ()
	{
		
		if (paused)
			return;

		timer.update();
		g_FPS = timer.printFPS(false);
		

#ifdef FIXED_STEP_LOOP
		loops = 0;
		while( mx3::GetTickCount() > next_game_tick && loops < MAX_FRAMESKIP) 
		{
			scene->update(FIXED_DELTA);
			next_game_tick += SKIP_TICKS;
			loops++;	
		}
		
#else
		scene->update(timer.fdelta());	//blob rotation doesn't work well with high dynamic delta! fix this before enabling dynamic delta
#endif
		
	}

	void Game::render ()
	{
		RenderDevice::sharedInstance()->beginRender();
		scene->render(1.0);
		scene->frameDone();
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


}