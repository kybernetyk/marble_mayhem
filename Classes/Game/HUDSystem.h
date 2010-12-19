/*
 *  HUDSystem.h
 *  ComponentV3
 *
 *  Created by jrk on 12/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once
#include <vector>
#include "EntityManager.h"
#include "Timer.h"
using namespace mx3;

namespace game 
{

#define PREP_STATE_READY 0x00
#define PREP_STATE_3 0x01
#define PREP_STATE_2 0x02
#define PREP_STATE_1 0x03
#define PREP_STATE_GO 0x04
#define PREP_STATE_GAMEOVER 0x05
#define PREP_STATE_SOLVED 0x06

	
	class HUDSystem
	{
	public:
		HUDSystem (EntityManager *entityManager);
		void update (float delta);
		
		void show_prep_label ();
		//void set_prep_text (const char *text);
		void hide_prep_label ();
		
		void change_prep_state (int state);
		
		void reset ();
	protected:
		EntityManager *_entityManager;

		Entity *make_new_label (std::string fontname, vector2D pos, vector2D anchor);
		
//		Entity *fps_label;
		Entity *time_label;
		Entity *score_label;
		ResourceHandle font_handle;

		mx3::rect prep_coords[7];
		
		Entity *prep;
		
		float last_score;
		float score_init_diff;
		float last_time;
		int current_prep_state;
	};


}