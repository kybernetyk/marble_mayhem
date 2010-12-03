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

	class HUDSystem
	{
	public:
		HUDSystem (EntityManager *entityManager);
		void update (float delta);
		
		void show_prep_label ();
		void set_prep_text (const char *text);
		void hide_prep_label ();
	protected:
		EntityManager *_entityManager;

		Entity *make_new_label (std::string fontname, vector2D pos, vector2D anchor);
		
		Entity *fps_label;
		Entity *time_label;
		Entity *score_label;
		OGLFont *font;
		
		Entity *prep_label;
		
		float last_score;
		float score_init_diff;
		float last_time;
	};


}