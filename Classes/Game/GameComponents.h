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

#define FRUIT_ORANGE 0x00
#define FRUIT_LEMON 0x01
#define FRUIT_BANANA 0x02
#define FRUIT_GRAPES 0x03
	
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
		
		float fall_duration;
		bool landed;
		
		bool marked;
		
		GameBoardElement ()
		{
			_id = COMPONENT_ID;
			prev_row = prev_col = row = col = 0;
			type = FRUIT_ORANGE;
			prev_state = state = GBE_STATE_IDLE;
			y_off = 0.0;
			y_move_timer = 0.0;
			landed = false;

			marked = false;
			
			fall_duration = 0.25;
		}
		
		DEBUGINFO ("Game Board Element. state = %i, landed = %i\n",  state, landed)
	};
	
	
}
