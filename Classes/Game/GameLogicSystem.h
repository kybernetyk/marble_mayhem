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
		
		void mark_chain ();
		void handle_chain ();
		void remove_chain ();
		
		bool moves_left ();

		Entity *_map[BOARD_NUM_COLS][BOARD_NUM_ROWS];
		void update_map ();
		int count_empty_cols ();
		
	protected:
		std::vector<Entity*> _entities;
		float _delta;
		int marked_color;
		
		int head_row;
		int head_col;
		int num_of_marks;
		
		EntityManager *_entityManager;
#define MAX_MARKERS 32
		Entity *markers[MAX_MARKERS];
		int marker_index;
	};

}