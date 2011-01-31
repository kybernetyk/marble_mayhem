/*
 *  GameLogicSystem.cpp
 *  ComponentV3
 *
 *  Created by jrk on 10/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "ComponentV3.h"
#include "InputDevice.h"
#include "ActionSystem.h"

#include "BB_GameLogicSystem.h"
#include "SoundSystem.h"
#include "globals.h"

#include "Component.h"
#include "GameComponents.h"

namespace game 
{
	extern mx3::PE_Proxy *g_pMarkerCache[BB_BOARD_NUM_MARKERS];
	extern mx3::PE_Proxy *g_pExplosionCache[BB_BOARD_NUM_MARKERS];

	static int prev_col = -1;
	static int prev_row = -1;
	static bool may_react = true;
	
	BB_GameLogicSystem::BB_GameLogicSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;

		memset (markers, 0x00, BB_BOARD_NUM_MARKERS * sizeof(Entity*));
		memset(_map,0x00,BB_BOARD_NUM_COLS*BB_BOARD_NUM_ROWS*sizeof(Entity*));
		reset();
	}

	PE_Proxy *BB_GameLogicSystem::get_free_explosion()
	{
		PE_Proxy *prox = NULL;
		
		for (int i = 0; i < BB_BOARD_NUM_MARKERS; i++)
		{
			prox = g_pExplosionCache[i];
			
			if (!prox->shoudHandle())
				return prox;
		}
		return NULL;
	}
	
	
	PE_Proxy *BB_GameLogicSystem::get_free_marker()
	{
		PE_Proxy *prox = NULL;
		
		for (int i = 0; i < BB_BOARD_NUM_MARKERS; i++)
		{
			prox = g_pMarkerCache[i];
			
			if (!prox->shoudHandle())
				return prox;
		}
		return NULL;
	}
	
	
	void BB_GameLogicSystem::reset ()
	{
		marked_color = -1;
		head_row = -1;
		head_col = -1;
		num_of_marks = 0;
		last_sfx = -1;
		awesome_count = 0;
		nokaut = 0;
		may_react = true;

		remove_all_markers();
		
		memset (markers, 0x00, BB_BOARD_NUM_MARKERS * sizeof(Entity*));
		marker_index = 0;
	}
	
	void BB_GameLogicSystem::remove_chain ()
	{
		std::vector<Entity*> entities;
		_entityManager->getEntitiesPossessingComponents(entities, GameBoardElement::COMPONENT_ID, Position::COMPONENT_ID, ARGLIST_END );
		std::vector<Entity*>::const_iterator it = entities.begin();
		
		Entity *current_entity = NULL;
		GameBoardElement *current_gbe = NULL;
		while (it != entities.end())
		{
			current_entity = *it;
			++it;
			current_gbe = _entityManager->getComponent <GameBoardElement> (current_entity);
			
			if (current_gbe->marked)
			{
				if (num_of_marks >= 2)
				{
					_entityManager->addComponent <MarkOfDeath> (current_entity);
					if (g_ParticlesEnabled)
					{
						PE_Proxy *pe = get_free_explosion();
						if (pe)
						{
							ParticleSystem::createParticleEmitter (pe,
																   0.25,
																   vector2D_make(current_gbe->col * BB_TILESIZE_X + BB_BOARD_X_OFFSET, current_gbe->row*BB_TILESIZE_Y+BB_BOARD_Y_OFFSET));
							pe->setDuration(0.25);
							pe->reset();
							pe->start();
						}
					}
				}
				current_gbe->marked = false;
			}
		}
	}
	
	
	void BB_GameLogicSystem::handle_chain ()
	{
		//score if the chain had 2 or more entries
		if (num_of_marks >= 2)
		{
			int score = (num_of_marks * 15) * num_of_marks;
			float num = num_of_marks;
			
			float time_add = ((float)(num*0.18*num*0.18));		//0.18
			
			//only add time for chain if we're playinh (not game over)
			if (g_GameState.game_state == GAME_STATE_PLAY && g_GameState.next_state == GAME_STATE_PLAY)
			{
			//	g_GameState.time_left += time_add * (float)((float)g_GameState.num_of_fruits/4.0);
			}
			g_GameState.score += score * (float)((float)g_GameState.num_of_fruits/4.0);
			g_GameState.killed_last_frame = num_of_marks;
			
			int sfx = (num_of_marks-2);
			sfx += SFX_FRUIT_REMOVE_2;
			sfx = std::min(SFX_FRUIT_REMOVE_6, sfx);
			
			SoundSystem::make_new_sound (sfx);
			int bonus = 0;
			if (num_of_marks >= 4)
			{
				sfx = SFX_AWESOME;
				
				if (num_of_marks >= 5)
					sfx = SFX_EXCELLENT;
				if (num_of_marks >= 6)
					sfx = SFX_INCREDIBLE;
				if (num_of_marks >= 7)
					sfx = SFX_IMPRESSIVE;

				BOOL play = YES;
				
				if (sfx == SFX_AWESOME)
				{	
					awesome_count ++;
					
					if (awesome_count > 4)
						awesome_count = 4;
	
					if (awesome_count > 3)
						play = NO;
				}
				else
				{	
					awesome_count --;
					
					if (awesome_count < 0)
						awesome_count = 0;
				}
				
				
				if (sfx == SFX_AWESOME)
				{
					if (last_sfx == SFX_AWESOME)
						sfx = SFX_GOOD1;
					else if (last_sfx == SFX_GOOD1)
						sfx = SFX_AWESOME2;
					else if (last_sfx == SFX_AWESOME2)
						sfx = SFX_GOOD2;
					else if (last_sfx == SFX_GOOD2)
						play = NO;
				}
				else if (sfx == SFX_EXCELLENT)
				{
					if (last_sfx == SFX_EXCELLENT)
						sfx = SFX_EXCELLENT2;
					else if (last_sfx == SFX_EXCELLENT2)
						sfx = SFX_EXCELLENT3;
					else if (last_sfx == SFX_EXCELLENT3)
						sfx = SFX_INCREDIBLE;
				}
				else if (sfx == SFX_IMPRESSIVE)
				{
					if (last_sfx == SFX_IMPRESSIVE)
						sfx = SFX_IMPRESSIVE2;
				}
	
				if (nokaut >= 4)
				{
					awesome_count = 0;
					play = YES;
				}
				nokaut = 0;
				
				
				last_sfx = sfx;
				
				if (play)
					SoundSystem::make_new_sound (sfx);	
				
			}
			else 
			{
				nokaut ++;
			}

//			else
//			{	
//				awesome_count --;
//				
//				if (awesome_count < 0)
//					awesome_count = 0;
//			}
			
			
			if (g_GameState.previous_kill >= 3 && num_of_marks >= 4)
			{	
				bonus = 200 * num_of_marks;
				if (g_GameState.previous_kill >= 4 && num_of_marks >= 5)
				{	
					bonus = 300 * num_of_marks;
				}
				
				if (g_GameState.previous_kill >= 5 && num_of_marks >= 6)
				{	
					bonus = 500 * num_of_marks;
				}
			}
			g_GameState.score += bonus * (float)((float)g_GameState.num_of_fruits/4.0);
			if (g_GameState.game_state == GAME_STATE_PLAY && g_GameState.next_state == GAME_STATE_PLAY)
			{
				g_GameState.time_left += bonus/3600.0 * (float)((float)g_GameState.num_of_fruits/4.0);	//only add time bonus if we are and will not be game over
			}
			CV3Log("Bonus: %i\n", bonus);

			CV3Log("time add: %f\n", time_add);
			CV3Log("Bonus time: %f\n",bonus/1200.0);
			CV3Log("sum t: %f\n", time_add + (bonus/1200.0));
			g_GameState.previous_kill = num_of_marks;
			g_GameState.total_killed += num_of_marks;
			
			if (g_GameState.game_mode == GAME_MODE_BB)
			{
				int sweep_bonus = (g_GameState.total_killed * g_GameState.total_killed) + (score*time_add);
				
				CV3Log("sweep bonus: %i\n", sweep_bonus);
				
				g_GameState.score += sweep_bonus * (float)((float)g_GameState.num_of_fruits/4.0);
			}
			
			CV3Log("removign %i from gamestate ...\n",num_of_marks);
			g_GameState.fruits_on_board -= num_of_marks;
			CV3Log("now left: %i\n", g_GameState.fruits_on_board);
		}

		printf("****************************** NUM OF MARKS: %i\n", num_of_marks);
		
		//g_GameState.previous_kill = num_of_marks;
		
		remove_chain ();

		//remove the markers
		remove_all_markers ();
		
		marked_color = -1;
		marker_index = 0;
		num_of_marks = 0;
	}

	void BB_GameLogicSystem::remove_all_markers()
	{
		for (int i = 0; i < BB_BOARD_NUM_MARKERS; i++)
		{
			Entity *e = markers[i];
			if (e)
			{
				markers[i] = NULL;
				
				if (g_ParticlesEnabled)
				{
					PEmitter *pe = _entityManager->getComponent <PEmitter> (e);

					//we have to make sure that the marker is a PE at this point!
					//user could have changed particles to on while the markers were bitmap markers
					if (pe->_renderable_type ==  RENDERABLETYPE_PARTICLE_EMITTER)
						[pe->pe->pe setDuration: 0.1];	//set duration to 0.1 so the pe can decay (def dur is -1 = infinite)
					else
						_entityManager->addComponent <MarkOfDeath> (e);		
				}
				else
				{
					_entityManager->addComponent <MarkOfDeath> (e);	
				}
			}
		}
		
		for (int row = 0; row < BB_BOARD_NUM_ROWS; row ++)
		{
			for (int col = 0; col < BB_BOARD_NUM_COLS; col ++)
			{
				Entity *e = _map[col][row];
				if (!e)
					continue;

				GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);
				AtlasSprite *spr = _entityManager->getComponent <AtlasSprite> (e);

				spr->alpha = 1.0;
				gbe->marked = false;
				gbe->mark_count = 0;
			}
		}	
	}
	
	bool BB_GameLogicSystem::moves_left ()
	{
		//vertical
		for (int row = 0; row < BB_BOARD_NUM_ROWS; row ++)
		{
			int currtype = -1;
			for (int col = 0; col < BB_BOARD_NUM_COLS; col ++)
			{
				Entity *e = _map[col][row];
				if (!e)
				{	
					currtype = -1;
					continue;
				}
				GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);

				//if there are any fruits in movement return true and do 
				//a real check only if they are all idle
				if (gbe->state != GBE_STATE_IDLE || gbe->moving_sideways)
					return true;
				
				if (currtype == -1)
				{
					currtype = gbe->type;
				}
				else
				{
					if (gbe->type == currtype)
						return true;
					else
						currtype = gbe->type;
				}
			}
		}

		//horizontal
		for (int col = 0; col < BB_BOARD_NUM_COLS; col ++)
		{
			int currtype = -1;
			for (int row = 0; row < BB_BOARD_NUM_ROWS; row ++)
			{
				Entity *e = _map[col][row];
				if (!e)
				{	
					currtype = -1;
					continue;
				}
				
				GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);
				if (gbe->state != GBE_STATE_IDLE || gbe->moving_sideways)
					return true;

				if (currtype == -1)
				{
					currtype = gbe->type;
				}
				else
				{
					if (gbe->type == currtype)
						return true;
					else
						currtype = gbe->type;
				}
			}
		}
		
		return false;
		
	}

	bool BB_GameLogicSystem::moves_left_2 ()
	{
		//vertical
		for (int row = 0; row < BB_BOARD_NUM_VISIBLE_ROWS; row ++)
		{
			int currtype = -1;
			for (int col = 0; col < BB_BOARD_NUM_COLS; col ++)
			{
				Entity *e = _map[col][row];
				if (!e)
				{	
					currtype = -1;
					continue;
				}
				GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);
				
				//if there are any fruits in movement return true and do 
				//a real check only if they are all idle
				if (gbe->state != GBE_STATE_IDLE)
					return true;
				
				if (currtype == -1)
				{
					currtype = gbe->type;
				}
				else
				{
					if (gbe->type == currtype)
						return true;
					else
						currtype = gbe->type;
				}
			}
		}
		
		//horizontal
		for (int col = 0; col < BB_BOARD_NUM_COLS; col ++)
		{
			int currtype = -1;
			for (int row = 0; row < BB_BOARD_NUM_VISIBLE_ROWS; row ++)
			{
				Entity *e = _map[col][row];
				if (!e)
				{	
					currtype = -1;
					continue;
				}
				
				GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);
				if (gbe->state != GBE_STATE_IDLE)
					return true;
				
				if (currtype == -1)
				{
					currtype = gbe->type;
				}
				else
				{
					if (gbe->type == currtype)
						return true;
					else
						currtype = gbe->type;
				}
			}
		}
		
		return false;
		
	}
	
	
	void BB_GameLogicSystem::update_map ()
	{
		memset(_map,0x00,BB_BOARD_NUM_COLS*BB_BOARD_NUM_ROWS*sizeof(Entity*));
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		Entity *_current_entity = NULL;
		GameBoardElement *_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			
			//if ((_current_gbe->state == GBE_STATE_IDLE))
			_map[_current_gbe->col][_current_gbe->row] = _current_entity;
		}
	}

	
	
#pragma mark -
#pragma mark THIS!
	bool BB_GameLogicSystem::mark_cells (int col, int row)
	{
		if (col < 0)
			return false;
		if (row < 0)
			return false;
		if (col >= BB_BOARD_NUM_COLS)
			return false;
		if (row >= BB_BOARD_NUM_VISIBLE_ROWS)
			return false;
		
		Entity *e = _map[col][row];
		if (!e)
			return false;

		GameBoardElement *current_gbe = NULL;

		current_gbe = _entityManager->getComponent <GameBoardElement> (e);
		if (!current_gbe)
			return false;
		
		if (marked_color == -1)
			marked_color = current_gbe->type;
		
		if (current_gbe->type != marked_color)
			return false;
		
		if (!current_gbe->marked)
		{
			num_of_marks ++;
			current_gbe->marked = true;
			current_gbe->mark_count = 1;

			AtlasSprite *spr = _entityManager->getComponent <AtlasSprite> (e);
			if (e)
			{
				spr->alpha = 0.5;
			}

		/*	if (marker_index < BB_BOARD_NUM_MARKERS)
			{
				if (g_ParticlesEnabled)
				{
					PE_Proxy *pe = get_free_marker();
					if (pe)
					{
						Entity *ent = ParticleSystem::createParticleEmitter (pe,
																			 -1.0,
																			 vector2D_make(col * BB_TILESIZE_X + BB_BOARD_X_OFFSET, row*BB_TILESIZE_Y+BB_BOARD_Y_OFFSET));
						pe->setDuration(-1.0);
						pe->reset();
						pe->start();
						markers[marker_index++] = ent;	
					}
					
				}
				else
				{
					Entity *pe = _entityManager->createNewEntity();
					Position *pos = _entityManager->addComponent <Position> (pe);
					pos->x = col * BB_TILESIZE_X + BB_BOARD_X_OFFSET+2;
					pos->y = row * BB_TILESIZE_Y + BB_BOARD_Y_OFFSET-4;
					
					Sprite *sp = _entityManager->addComponent <Sprite> (pe);
					sp->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("marker.png");
					sp->z = 8.0;
					
					markers[marker_index++] = pe;	
				}
			}*/

			mark_cells(col , row - 1);
			mark_cells(col + 1 , row);
			mark_cells(col , row + 1);
			mark_cells(col - 1, row );
			return false;
		}
		else
			return true;

		
	}
#pragma mark -
	
	bool BB_GameLogicSystem::mark_chain ()
	{
		vector2D v = InputDevice::sharedInstance()->touchLocation();
		if (v.y <= 57.0)
			return false;
		
		int col = (v.x - BB_BOARD_X_OFFSET + BB_TILESIZE_X/2) / BB_TILESIZE_X;
		int row = (v.y - BB_BOARD_Y_OFFSET + BB_TILESIZE_Y/2) / BB_TILESIZE_Y;

		//remove possible marked
		if (may_react)
		{
			may_react = false;
			Entity *e = _map[col][row];
			if (e)
			{
				GameBoardElement *el = _entityManager->getComponent<GameBoardElement>(e);
				if (el->mark_count == 0)
				{
					remove_all_markers();
					marked_color = -1;
					num_of_marks = 0;
				}
				if (el->mark_count == 1)
				{
					return true;
				}
			}
			//mark
			if (prev_col == -1 && prev_row == -1)
			{	
				mark_cells (col, row);
				prev_col = col;
				prev_row = row;
			}
			
			if (num_of_marks == 1)
			{
				remove_all_markers();
				marked_color = -1;
				num_of_marks = 0;
				
			}
			
		}
		
		
		return false;
	}
	
	int BB_GameLogicSystem::count_empty_cols ()
	{
		update_map ();
		int ret = 0;
		for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
		{
			int sum = 0;
			for (int row = 0; row < BB_BOARD_NUM_ROWS; row ++)
			{
				if (_map[col][row])
					sum ++;
			}
			if (sum <= 0)
				ret++;
		}
		
		return ret;
	}

	void BB_GameLogicSystem::update (float delta)
	{
		_delta = delta;
		g_GameState.killed_last_frame = 0;
		
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities, GameBoardElement::COMPONENT_ID, Position::COMPONENT_ID, ARGLIST_END );

		update_map();
		bool touch = InputDevice::sharedInstance()->isTouchActive();
		if (touch)
		{
			if (mark_chain())
			{	
				handle_chain();
			}
		}
		
		if (InputDevice::sharedInstance()->touchUpReceived())
		{
		//	mark_chain ();	//just in case fps is too low and the time between last mark and up was too long
							//to register all marks

//			marked_color = -1;
			head_row = -1;
			head_col = -1;
			prev_col = -1;
			prev_row = -1;
			may_react = true;
			
		//	handle_chain();
		}
		
		if (!touch)
		{
//				marked_color = -1;
				head_row = -1;
				head_col = -1;
				prev_col = -1;
				prev_row = -1;
			may_react = true;
		}
		
		if (g_GameState.game_mode == GAME_MODE_BB)
		{
			update_map();
			if (!moves_left())
			{
				int cols_removed = count_empty_cols();
				
				if (g_GameState.fruits_on_board > 0)
					g_GameState.next_state = GAME_STATE_GAMEOVER;
				else
					g_GameState.next_state = GAME_STATE_SOLVED;
				
				g_GameState.gameover_reason = GO_REASON_IRRELEVANT;
				
//				printf("OMFG %i FRUITS LEFT!\n", g_GameState.fruits_on_board);
				
				int bonus = ((BB_BOARD_NUM_COLS * BB_BOARD_NUM_ROWS) -  g_GameState.fruits_on_board) * 4;
				bonus *= (bonus * 1.5);
				
//				printf("bonus score = %i\n", bonus);
				
				int col_bonus = (cols_removed * 10) * (cols_removed * 10) * (cols_removed * 10);
				//col_bonus += (((float)col_bonus*0.2) * ((float)col_bonus*0.2));
				
//				printf("removed col bonus = %i = %i\n", cols_removed, col_bonus);
				
				if (g_GameState.fruits_on_board <= 0)
				{
					CV3Log("time played: %f\n", g_GameState.time_played);
					CV3Log("bonus: %i\n", bonus);

					bonus += 45321;
					float f = (1.5 - (g_GameState.time_played * 0.01));
					if (f <= 0.3)
						f = 0.3;
					bonus *= f;

					CV3Log("bonus time abzuch: %i\n", bonus);
				}

				
				g_GameState.score += bonus * (float)((float)g_GameState.num_of_fruits/4.0);
				g_GameState.score += col_bonus * (float)((float)g_GameState.num_of_fruits/4.0);
			}
		}
		else
		{
			//NSLog(@"left?");
			update_map();
			if (!moves_left_2())
			{
				g_GameState.next_state = GAME_STATE_GAMEOVER;
				g_GameState.gameover_reason = GO_REASON_NOMOVES;
				CV3Log("no moves left :[\n");
			}
		}
		
	}
}