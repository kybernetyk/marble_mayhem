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
	
#define GBE_STATE_IDLE 0
#define GBE_STATE_MOVING_FALL 1

#define GBE_CONNECTED_NONE (1 << 0)	
#define GBE_CONNECTED_TO_UP (1 << 1)
#define GBE_CONNECTED_TO_LEFT (1 << 2)
#define GBE_CONNECTED_TO_DOWN (1 << 3)
#define GBE_CONNECTED_TO_RIGHT (1 << 4)	
	
	struct GameBoardElement : public Component
	{
		static ComponentID COMPONENT_ID;
		
		int row;
		int col;
		
		int prev_row;
		int prev_col;
		
		int type;
		
		unsigned int state;

		float y_move_timer;
		float y_off;
		
		float fall_duration;
		bool landed;
		unsigned int connection_state;
		unsigned int prev_connection_state;
		
		GameBoardElement ()
		{
			_id = COMPONENT_ID;
			prev_row = prev_col = row = col = 0;
			type = FRUIT_ORANGE;
			state = GBE_STATE_IDLE;
			prev_connection_state = connection_state = GBE_CONNECTED_NONE;// GBE_CONNECTED_NONE;
			y_off = 0.0;
			y_move_timer = 0.0;
			landed = false;

	
			fall_duration = 0.1;
		}
		
		DEBUGINFO ("Game Board Element. connection state = %i, prev con = %i, state = %i, landed = %i\n", connection_state, prev_connection_state, state, landed)
	};
	
	
}
