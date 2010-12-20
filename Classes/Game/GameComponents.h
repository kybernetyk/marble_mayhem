/*
 *  GameComponens.h
 *  ComponentV3
 *
 *  Created by jrk on 16/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once

#include "Component.h"

using namespace mx3;
namespace game
{
#pragma mark -
#pragma mark game 

#define NUM_OF_FRUITS 4
	
#define GBE_STATE_IDLE 0
#define GBE_STATE_MOVING_FALL 1

	
	struct GameBoardElement : public Component
	{
		static ComponentID COMPONENT_ID;
		
		int row;
		int col;
		
		int prev_row;
		int prev_col;
		
		int type;
		
		unsigned int prev_state;
		unsigned int state;

		float y_move_timer;
		float y_off;
		
		float x_move_timer;
		float x_off;
		
		float fall_duration;
		bool landed;
		
		bool marked;
		
		bool moving_sideways;
		
		float vy;
		bool nograv;
		
		GameBoardElement ()
		{
			_id = COMPONENT_ID;
			prev_row = prev_col = row = col = 0;
			type = 0;
			prev_state = state = GBE_STATE_IDLE;
			y_off = 0.0;
			y_move_timer = 0.0;
			landed = false;
			vy = 1.0;

			nograv = false;
			marked = false;
			moving_sideways = false;
			x_move_timer = 0.0;
			x_off = 0.0;
			
			fall_duration = 0.25;
		}
		
		DEBUGINFO ("Game Board Element. state = %i, landed = %i\n",  state, landed)
	};
	
	struct Star : public Component
	{
		static ComponentID COMPONENT_ID;

		float fall_speed;
		
		Star ()
		{
			_id = COMPONENT_ID;
			fall_speed = 0.0;
		}
		
		DEBUGINFO ("Star")
	};
	
}
