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

namespace mx3 
{
	class Scene;
}

namespace game 
{
	class Game
	{
	public:
		bool init ();
		void terminate ();

		void update ();
		void render (); 
		
		void saveGameState ();
		void restoreGameState ();
	protected:
		mx3::Scene *scene;
	};

	extern bool paused;
	extern mx3::Timer timer;
	extern unsigned int next_game_tick;
	
	extern Game *g_pGame;
}