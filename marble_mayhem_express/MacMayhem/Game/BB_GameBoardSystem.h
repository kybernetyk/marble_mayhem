/*
 *  GameBoardSystem.h
 *  Donnerfaust
 *
 *  Created by jrk on 17/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once
#include <vector>
#include "EntityManager.h"
#include "globals.h"
using namespace mx3;

namespace game
{
	class GameBoardElement;
	
	class BB_GameBoardSystem
	{
	public:
		BB_GameBoardSystem (EntityManager *entityManager);
		void update (float delta);
		void reset ();
	protected:
		bool can_move_down ();
		
	
		void handle_state_idle ();
		void handle_state_falling ();		//move block down (fall)
		void handle_state_move_sideways ();	//move block sideways (sweep mode)
		
		void refill ();					//vertical fill
		void refill_horizontal ();		//horizontal fill for sweep mode
		
		Entity *_map[BB_BOARD_NUM_COLS][BB_BOARD_NUM_ROWS];
		void update_map ();
		void update_map_with_prevs ();
		Entity *_current_entity;
		int spark_rows[BB_BOARD_NUM_COLS];
		

		EntityManager *_entityManager;
		GameBoardElement *_current_gbe;
		Position *_current_position;
		std::vector<Entity*> _entities;
		float _delta;
		int fruit_alternator;
		float refill_pause_time_between_rows;
		float refill_pause_timer;
	};
	
}

