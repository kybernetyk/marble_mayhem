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
		
		int max = 10;
		for (int i = 0; i < max; i++)
		{
			MoveByAction *mb = new MoveByAction();
			mb->duration = 0.05;
			
			if (i % 2 == 0)
				mb->x = (max-i)*2;
			else
				mb->x = -(max-i)*2;
			
			action_append_action (actn, mb);
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
		//actn->on_complete_action = mb3;
		action_append_action(actn, mb3);
		
		return actn;
	}

	
	
	
	Entity *HUDSystem::make_new_label (std::string fontname, vector2D pos, vector2D anchor)
	{
		Entity *e = _entityManager->createNewEntity();
		
		Position *position = _entityManager->addComponent <Position> (e);
		position->x = pos.x;
		position->y = pos.y;
		//position->scale_x = position->scale_y = 0.5;
		
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
		
		printf("state: %i\n", state);

		//handle state changes
		switch (state)
		{
			case PREP_STATE_READY:
				show_prep_label();
				if (clock)
					clock->get<FrameAnimation>()->state = ANIMATION_STATE_PAUSE;
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
				show_prep_label();
				if (clock)
					clock->get<FrameAnimation>()->state = ANIMATION_STATE_PAUSE;
				break;
			case PREP_STATE_SOLVED:
				show_prep_label();
				if (clock)
					clock->get<FrameAnimation>()->state = ANIMATION_STATE_PAUSE;
				break;
			
			case PREP_STATE_PLAY:
				hide_prep_label();	
				if (clock)
					clock->get<FrameAnimation>()->state = ANIMATION_STATE_PLAY;
				break;
				
			default:
				break;
		}
		
		if (state != PREP_STATE_PLAY)
			_entityManager->getComponent <AtlasSprite> (prep)->src = prep_coords[state];
		
		current_prep_state = state;
	}
	
	HUDSystem::HUDSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;

	//	font_handle = g_RenderableManager.acquireResource <OGLFont> ("zomg.fnt");
		
		//fps label
		fps_label = _entityManager->createNewEntity();
		_entityManager->addComponent<Name>(fps_label)->name = "fps_label";
		_entityManager->addComponent<Position> (fps_label);
		fps_label->get<Position>()->x = 0.0;
		fps_label->get<Position>()->y = SCREEN_H;
		//fps_label->get<Position>()->scale_x = 		fps_label->get<Position>()->scale_y =  0.5;
		TextLabel *label = _entityManager->addComponent<TextLabel> (fps_label);
		label->res_handle = g_RenderableManager.acquireResource <OGLFont> ("impact20.fnt");;
		label->anchorPoint = vector2D_make(0.0, 1.0);
		label->text = "FPS: 0";
		label->z = 6.0;
		
		char s[255];
		sprintf(s, "%i", g_GameState.score);
		score_label = make_new_label ("impact20.fnt", vector2D_make(SCREEN_W/2+4, 30), vector2D_make(0.5, 0.5));
		score_label->get<TextLabel>()->text = s;
		
		time_label = NULL;
		clock = NULL;
		if (g_GameState.game_mode == GAME_MODE_TIMED)
		{
			time_label = make_new_label ("impact20.fnt", vector2D_make(34.0+4, 30.0), vector2D_make(0.0, 0.5));
			
			clock = _entityManager->createNewEntity();
			Position *pos = _entityManager->addComponent <Position> (clock);
			pos->x = 18;
			pos->y = 27.0;
			
			AtlasSprite *sprite = _entityManager->addComponent <AtlasSprite> (clock);
			sprite->res_handle = g_RenderableManager.acquireResource <TexturedAtlasQuad>("clocks.png");
			sprite->src = rect_make(0.0, 0.0, 32.0, 32.0);
			sprite->z = 6.0;
			
			FrameAnimation *fa = _entityManager->addComponent <FrameAnimation> (clock);
			fa->destroy_on_finish = false;
			fa->loop = true;
			fa->frames_per_second = 24;
			fa->start_frame = 23;
			fa->end_frame = 1;
			fa->current_frame = fa->start_frame;		
			fa->frame_size = rect_make(0.0, 0.0, 32.0, 32.0);
			fa->state = ANIMATION_STATE_PAUSE;
			
			
			sprintf(s, "%.2f", g_GameState.time_left);
			time_label->get<TextLabel>()->text = s;
		}

		current_prep_state = -1;
		//ready
		rect r0 = {254, 7, 253, 148};
		prep_coords[PREP_STATE_READY] = r0; 

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
		sprite->src = prep_coords[PREP_STATE_READY];
		sprite->z = 6.0;
		
		//change_prep_state (PREP_STATE_READY);
		
		
		
		
		
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

	//typedef void(^Block)(void);

	void HUDSystem::show_prep_label ()
	{
		Action *a = flyin_and_shake_action();
//		Block bl = ^{
//			printf("penis\n");
//		};
//		a->on_complete_block = Block_copy (bl);
		
//		Block bl = ^{
//			printf("this: %p\n",this);
//			this->hide_prep_label();
//		};
//		a->set_on_complete_block (bl);
		
		g_pActionSystem->addActionToEntity (prep, a);		
	}
	
/*	void HUDSystem::set_prep_text (const char *text)
	{
		TextLabel *label = _entityManager->getComponent<TextLabel>(prep_label);
		label->text = text;
	}*/
	
	
	void HUDSystem::hide_prep_label ()
	{
		Action *a = flyout_and_reset_action();
		
//		__block MoveToAction *action;
//		ActionBlock bl = ^{
//			action = new MoveToAction();
//			action->y = 480/2;
//			action->x = 320/2;
//			
//			g_pActionSystem->addActionToEntity (prep, action);
//		};
//		action_set_complete_block (a, bl);
		
		
		g_pActionSystem->addActionToEntity (prep, a);
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
		if (d > 0.0)
		{
			d = 0.0;
			sprintf(s, "Fps: %.2f", g_FPS);
			fps_label->get<TextLabel>()->text = s;
		}
		
	}

}