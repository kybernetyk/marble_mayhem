/*
 *  GameLogicSystem.h
 *  ComponentV3
 *
 *  Created by jrk on 10/11/10.
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
	class GameLogicSystem
	{
	public:
		GameLogicSystem (EntityManager *entityManager);
		void update (float delta);
		
		void mark_cell (int col, int row);
		void mark_chain ();
		void handle_chain ();
		void remove_chain ();
		
		bool moves_left ();
		bool moves_left_2 ();
		Entity *_map[BOARD_NUM_COLS][BOARD_NUM_ROWS];
		void update_map ();
		int count_empty_cols ();
		void reset ();
		
		PE_Proxy *get_free_explosion();
		PE_Proxy *get_free_marker();
		
		void remove_all_markers();
	protected:
		std::vector<Entity*> _entities;
		float _delta;
		int marked_color;
		
		int head_row;
		int head_col;
		int num_of_marks;
		int last_sfx;
		int awesome_count;
		int nokaut;
		EntityManager *_entityManager;

		Entity *markers[BOARD_NUM_MARKERS];
		int marker_index;
	};

}