/*
 *  Game.h
 *  Donnerfaust
 *
 *  Created by jrk on 1/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once

#include "Timer.h"
#include "globals.h"

namespace mx3 
{
	class Scene;
	class PE_Proxy;
}

namespace game 
{
	class Game
	{
	public:
		bool init ();
		void loadGlobalResources ();
		void terminate ();

		void update ();
		void render (); 
		
		void saveGameState ();
		void restoreGameState ();
		
		void startNewGame ();
		void returnToMainMenu ();
		
		void appDidFinishLaunching ();
		void appDidBecomeActive ();
		void appWillEnterForeground ();
		void appWillResignActive ();
		void appDidEnterBackground ();
		void appWillTerminate ();
		
		void resetCurrentScene ();
		
		void setNextScene (mx3::Scene *nscene)
		{
			next_scene = nscene;
		}
		
		void setPaused (bool b);
		
	protected:
		mx3::Scene *current_scene;
		mx3::Scene *next_scene;
	};

	extern int paused_count;
	extern mx3::Timer timer;
	extern unsigned int next_game_tick;
	
	extern Game *g_pGame;
	
	extern mx3::PE_Proxy *g_pMarkerCache[BOARD_NUM_MARKERS];
	extern mx3::PE_Proxy *g_pExplosionCache[BOARD_NUM_MARKERS];
}