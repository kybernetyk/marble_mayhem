/*
 *  globals.h
 *  ComponentV3
 *
 *  Created by jrk on 11/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once

namespace game 
{
	struct GameState
	{
		int score;
		float time_left;
		
		int game_state;
		int next_state;
		
		int game_mode;
		
		int killed_last_frame;
	};


#define GAME_MODE_TIMED 0x01
#define GAME_MODE_ENDLESS 0x02

#define GAME_STATE_PREP 0x01
#define GAME_STATE_PLAY 0x02
#define GAME_STATE_GAMEOVER 0x03
	
	
#define BOARD_X_OFFSET (0+20)
#define BOARD_Y_OFFSET (72+20)
	
#define BOARD_NUM_COLS 8
#define BOARD_NUM_ROWS (10+1)
	
#define NUM_SOUNDS 10
	
#define SFX_TIME_UP 0x00
#define SFX_GET_READY 0x01
#define SFX_GO 0x02
#define SFX_GAME_OVER 0x03
#define SFX_FRUIT_LAND 0x04
#define SFX_FRUIT_REMOVE_2 0x05
#define SFX_FRUIT_REMOVE_3 0x06
#define SFX_FRUIT_REMOVE_4 0x07
#define SFX_FRUIT_REMOVE_5 0x08	
#define SFX_FRUIT_REMOVE_6 0x09	
	
}

extern game::GameState g_GameState;
extern double g_FPS;
	

