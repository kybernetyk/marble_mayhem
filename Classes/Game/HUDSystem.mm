/*
 *  HUDSystem.cpp
 *  ComponentV3
 *
 *  Created by jrk on 12/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "HUDSystem.h"
#include "Texture2D.h"
#include "SoundSystem.h"
#include "Timer.h"
#include "globals.h"
#include "ActionSystem.h"

namespace game 
{
	Action *scale_action ()
	{
		ScaleByAction *actn = new ScaleByAction();
		actn->duration = 0.7;
		actn->scale_x = 2.0;
		actn->scale_y = 2.0;
		
		return actn;
	}
	
	Action *fade_action ()
	{
		FadeToAction *actn = new FadeToAction();
		
		actn->duration = 0.7;
		actn->alpha = 0.0;
		
		return actn;
	}
	
	Action *flyin_and_shake_action ()
	{
		MoveToAction *actn = new MoveToAction();
		actn->duration = 0.3;
		actn->x = SCREEN_W/2-10;
		actn->y = SCREEN_H/2+40;
		
		Action *prev_actn = actn;
		int max = 10;
		for (int i = 0; i < max; i++)
		{
			MoveByAction *mb = new MoveByAction();
			mb->duration = 0.05;
			
			if (i % 2 == 0)
				mb->x = (max-i)*2;
			else
				mb->x = -(max-i)*2;
			
			prev_actn->on_complete_action = mb;
			prev_actn = mb;
		}
		
		
		return actn;
	}
	
	Action *flyout_and_reset_action ()
	{
		MoveToAction *actn = new MoveToAction();
		actn->duration = 0.3;
		actn->x = -SCREEN_W;
		actn->y = SCREEN_H/2+40;
		
		/*		MoveByAction *mb = new MoveByAction();
		 mb->x = 0.0;
		 mb->y = 400;
		 mb->duration = 0.0;
		 actn->on_complete_action = mb;
		 
		 MoveByAction *mb2 = new MoveByAction();
		 mb2->x = 400+SCREEN_W+200;
		 mb2->y = 0;
		 mb2->duration = 0.0;
		 mb->on_complete_action = mb2;
		 */
		
		MoveToAction *mb3 = new MoveToAction();
		mb3->x = SCREEN_W+200;
		mb3->y = SCREEN_H/2+40;
		mb3->duration = 0.0;
		//		mb2->on_complete_action = mb3;
		actn->on_complete_action = mb3;
		
		return actn;
	}
	
	
	Entity *HUDSystem::make_new_label (std::string fontname, vector2D pos, vector2D anchor)
	{
		Entity *e = _entityManager->createNewEntity();
		
		Position *position = _entityManager->addComponent <Position> (e);
		position->x = pos.x;
		position->y = pos.y;
		position->scale_x = position->scale_y = 0.5;
		
		TextLabel *label = _entityManager->addComponent<TextLabel> (e);
		label->res_handle = g_RenderableManager.acquireResource <OGLFont>(fontname);
		label->anchorPoint = anchor;
		label->text = "a label";
		label->z = 6.0;
		
		return e;
		
	}
	
	void HUDSystem::change_prep_state (int state)
	{
		if (current_prep_state == state)
			return;
		
		//handle state changes
		switch (state)
		{
			case PREP_STATE_READY:
				break;
			case PREP_STATE_3:
				prep->get<Position>()->scale_x = 1.0;
				prep->get<Position>()->scale_y = 1.0;
				g_pActionSystem->addActionToEntity (prep, scale_action());
				
				prep->get<Renderable>()->alpha = 1.0;
				g_pActionSystem->addActionToEntity (prep, fade_action());
				break;
			case PREP_STATE_2:
				prep->get<Position>()->scale_x = 1.0;
				prep->get<Position>()->scale_y = 1.0;
				g_pActionSystem->addActionToEntity (prep, scale_action());
				
				prep->get<Renderable>()->alpha = 1.0;
				g_pActionSystem->addActionToEntity (prep, fade_action());
				break;
				
			case PREP_STATE_1:
				prep->get<Position>()->scale_x = 1.0;
				prep->get<Position>()->scale_y = 1.0;
				g_pActionSystem->addActionToEntity (prep, scale_action());
				
				prep->get<Renderable>()->alpha = 1.0;
				g_pActionSystem->addActionToEntity (prep, fade_action());
				break;
				
			case PREP_STATE_GO:
				prep->get<Position>()->scale_x = 1.0;
				prep->get<Position>()->scale_y = 1.0;
				prep->get<Renderable>()->alpha = 1.0;
				break;
				
			case PREP_STATE_GAMEOVER:
				break;
			case PREP_STATE_SOLVED:
				break;
				
			default:
				break;
		}
		
		_entityManager->getComponent <AtlasSprite> (prep)->src = prep_coords[state];
		current_prep_state = state;
	}
	
	HUDSystem::HUDSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;

		font_handle = g_RenderableManager.acquireResource <OGLFont> ("zomg.fnt");
		
		//fps label
		fps_label = _entityManager->createNewEntity();
		_entityManager->addComponent<Name>(fps_label)->name = "fps_label";
		_entityManager->addComponent<Position> (fps_label);
		fps_label->get<Position>()->x = 0.0;
		fps_label->get<Position>()->y = SCREEN_H;
		fps_label->get<Position>()->scale_x = 		fps_label->get<Position>()->scale_y =  0.5;
		TextLabel *label = _entityManager->addComponent<TextLabel> (fps_label);
		label->res_handle = font_handle;
		label->anchorPoint = vector2D_make(0.0, 1.0);
		label->text = "FPS: 0";
		label->z = 6.0;
		
		char s[255];
		sprintf(s, "%i", g_GameState.score);
		score_label = make_new_label ("zomg.fnt", vector2D_make(SCREEN_W/2+4, 32), vector2D_make(0.5, 0.5));
		score_label->get<TextLabel>()->text = s;
		
		time_label = NULL;
		if (g_GameState.game_mode == GAME_MODE_TIMED)
		{
			time_label = make_new_label ("zomg.fnt", vector2D_make(34.0, 32.0), vector2D_make(0.0, 0.5));
			
			Entity *clock = _entityManager->createNewEntity();
			Position *pos = _entityManager->addComponent <Position> (clock);
			pos->x = 18;
			pos->y = 28.0;
			
			Sprite *sprite = _entityManager->addComponent <Sprite> (clock);
			sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad>("clock.png");
			sprite->z = 6.0;
			
			sprintf(s, "%.2f", g_GameState.time_left);
			time_label->get<TextLabel>()->text = s;
		}

		current_prep_state = -1;
		//ready
		rect r0 = {254, 7, 253, 148};
		prep_coords[0] = r0; 

		//3
		rect r1 = {341, 157, 157, 166};
		prep_coords[1] = r1; 
		
		//2
		rect r2 = {184, 159, 150, 185};
		prep_coords[2] = r2; 
		
		//1
		rect r3 = {0, 166, 172, 168};
		prep_coords[3] = r3; 

		//go
		rect r4 = {333, 324, 161, 188};
		prep_coords[4] = r4; 

		//gameover
		rect r5 = {0, 350, 266, 162};
		prep_coords[5] = r5; 

		//solved
		rect r6 = {0, 0, 242, 157};
		prep_coords[6] = r6; 

		
		prep = _entityManager->createNewEntity();
		Position *pos = _entityManager->addComponent <Position> (prep);
		pos->x = SCREEN_W+200;
		pos->y = SCREEN_H/2+40;
		
		AtlasSprite *sprite = _entityManager->addComponent <AtlasSprite> (prep);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedAtlasQuad>("schriften.png");
		sprite->z = 6.0;
		
		change_prep_state (PREP_STATE_READY);
		
		
		
		
		
//		
//		prep_label = make_new_label ("zomg.fnt", vector2D_make( SCREEN_W+200, SCREEN_H/2+40), vector2D_make(0.5,0.5));
//		prep_label->get<Position>()->scale_x = 1.0;
//		prep_label->get<Position>()->scale_y = 1.0;
//		prep_label->get<TextLabel>()->text = "Plankton!";
		
		last_time = g_GameState.time_left;
		last_score = g_GameState.score;
		score_init_diff = 0;
		
		
	}
	
	void HUDSystem::reset ()
	{
		prep->get<Position>()->x = SCREEN_W+200;
		prep->get<Position>()->y = SCREEN_H/2+40;
		current_prep_state = -1;
	}
	

	void HUDSystem::show_prep_label ()
	{
		g_pActionSystem->addActionToEntity (prep, flyin_and_shake_action());		
	}
	
/*	void HUDSystem::set_prep_text (const char *text)
	{
		TextLabel *label = _entityManager->getComponent<TextLabel>(prep_label);
		label->text = text;
	}*/
	
	
	void HUDSystem::hide_prep_label ()
	{
		g_pActionSystem->addActionToEntity (prep, flyout_and_reset_action());
	}

	char s[255];
	
	void HUDSystem::update (float delta)
	{
		if (time_label)
		{
			last_time += delta;
			if (last_time >= 0.01)
			{
				last_time = 0.0;
				sprintf(s, "%.2f", g_GameState.time_left);
				time_label->get<TextLabel>()->text = s;
				
			}
		}
		
		if ((int)last_score != g_GameState.score)
		{
			if (score_init_diff == 0)
			{
				score_init_diff = (g_GameState.score - (int)last_score);
			}
			float add = (g_GameState.score - last_score);
			add *= 2.5;
			if (add < 3.0)
				add = 3.0;
			
			
			last_score += (add * delta);
			
			if ((int)last_score >= g_GameState.score)
			{
				last_score = g_GameState.score;
				score_init_diff = 0;
			}
			
			sprintf(s, "%i", (int)last_score);
			score_label->get<TextLabel>()->text = s;

		}
		
		
		static float d = 0.0;
		d += delta;
		if (d > 2.0)
		{
			d = 0.0;
			sprintf(s, "Fps: %.2f", g_FPS);
			fps_label->get<TextLabel>()->text = s;
		}
		
	}

}