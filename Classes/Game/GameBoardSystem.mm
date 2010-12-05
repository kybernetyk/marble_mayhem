/*
 *  GameBoardSystem.cpp
 *  Donnerfaust
 *
 *  Created by jrk on 17/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "GameBoardSystem.h"
#include "GameComponents.h"
#include "Fruit.h"
#include "SoundSystem.h"

namespace game 
{
	GameBoardSystem::GameBoardSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		memset(_map,0x00,BOARD_NUM_COLS*BOARD_NUM_ROWS*sizeof(Entity*));
		refill_pause_time_between_rows = 0.0;
		refill_pause_timer = 0.0;
	}
	
	void GameBoardSystem::update_map ()
	{
		memset(_map,0x00,BOARD_NUM_COLS*BOARD_NUM_ROWS*sizeof(Entity*));
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			
			//if ((_current_gbe->state == GBE_STATE_IDLE))
				_map[_current_gbe->col][_current_gbe->row] = _current_entity;
		}
	}
	
	
	bool GameBoardSystem::can_move_down ()
	{
		if (_current_gbe->row - 1 < 0)
			return false;
		
		int row = _current_gbe->row - 1;
		int col = _current_gbe->col;
		
		if (_map[col][row])
			return false;
		
		return true;
	}

	void GameBoardSystem::handle_state_idle ()
	{
		if (_current_gbe->prev_state == GBE_STATE_MOVING_FALL)
		{
			_current_gbe->prev_state = GBE_STATE_IDLE;
			
			if (!can_move_down())
				SoundSystem::make_new_sound (SFX_FRUIT_LAND);
		}
		
		if (can_move_down())
		{
			_current_gbe->state = GBE_STATE_MOVING_FALL;
		}
		else
		{
			_current_gbe->landed = true;
		}
	}

	void GameBoardSystem::handle_state_falling ()
	{
		if (_current_gbe->prev_state == GBE_STATE_IDLE)
		{
			_current_gbe->prev_row = _current_gbe->row;
			_current_gbe->y_move_timer = 0.0;
			_current_gbe->row --;
			_current_gbe->prev_state = GBE_STATE_MOVING_FALL;
			_current_gbe->landed = false;
			
			_current_gbe->y_off = 0.0;
			_current_gbe->y_move_timer = 0.0;
		}
		
		_current_gbe->y_move_timer += _delta;
		_current_gbe->y_off += _delta * (TILESIZE_Y/_current_gbe->fall_duration);	
		
		if (_current_gbe->y_move_timer >= _current_gbe->fall_duration)
		{
			_current_gbe->state = GBE_STATE_IDLE;
			_current_gbe->y_off = TILESIZE_Y;

		}
		
	}

	
	void GameBoardSystem::handle_state_move_sideways ()
	{
		_current_gbe->x_move_timer += _delta;
		_current_gbe->x_off += _delta * (TILESIZE_X/_current_gbe->fall_duration);	
		
		if (_current_gbe->x_move_timer >= _current_gbe->fall_duration)
		{
			_current_gbe->moving_sideways = false;
			_current_gbe->x_off = TILESIZE_X;
			
		}
		
	}
	
	
	bool sortie (Entity *e1, Entity *e2)
	{
		EntityManager *em = Entity::entityManager;
		GameBoardElement *gbe1 = em->getComponent<GameBoardElement>(e1);
		GameBoardElement *gbe2 = em->getComponent<GameBoardElement>(e2);
		
		if (gbe1->row == gbe2->row)
		{
			if (gbe1->col == gbe2->col)
			{
				return (e1 < e2);
			}
			return (gbe1->col < gbe2->col);
		}
		return (gbe1->row < gbe2->row);
	}

	void GameBoardSystem::refill ()
	{
		update_map();
		
		for (int col = 0; col < BOARD_NUM_COLS; col++)
		{
			if (!_map[col][BOARD_NUM_ROWS-2])
			{
				make_fruit(rand()%NUM_OF_FRUITS, col, BOARD_NUM_ROWS-1);
			}
		}
	}
	
	void GameBoardSystem::refill_horizontal ()
	{	
		update_map();

		bool move = false;
		for (int col = BOARD_NUM_COLS-1; col >= 0; col--)
		{
			if (!move)
			{
				int sum = 0;
				for (int row = 0; row < BOARD_NUM_ROWS; row++)
				{
					if (_map[col][row])
					{
						sum ++;
					}
				}
				if (sum <= 0)
					move = true;
			}
			else
			{
				for (int row = 0; row < BOARD_NUM_ROWS; row++)
				{
					if (_map[col][row])
					{
						Entity *e = _map[col][row];
						GameBoardElement *gbe = _entityManager->getComponent <GameBoardElement> (e);
						if (!gbe->moving_sideways)
						{
							gbe->prev_col = gbe->col;
							gbe->col ++;
							gbe->x_move_timer = 0.0;
							gbe->x_off = 0.0;
							
							gbe->moving_sideways = true;
						}
					}
				}
			}
		}
		
	}
	
	
	void GameBoardSystem::update (float delta)
	{
		_delta = delta;
		/* create collision map */	
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities,  GameBoardElement::COMPONENT_ID, ARGLIST_END );
		std::sort (_entities.begin(), _entities.end(), sortie);
		//falldown
		update_map();
		
		for (int row = 0; row < BOARD_NUM_ROWS; row ++)
		{
			for (int col = 0; col < BOARD_NUM_COLS; col++)
			{
				if (!_map[col][row])
				{
					for (int j = row; j < BOARD_NUM_ROWS; j++)
					{
						_map[col][j] = NULL;
					}
				}
			}
		}
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			_current_position = _entityManager->getComponent<Position>(_current_entity);

			//reset fall speed to normal
			if (g_GameState.game_state == GAME_STATE_PREP)
				_current_gbe->fall_duration = 0.05;
			else
				_current_gbe->fall_duration = 0.20;
			
			if ((_current_gbe->state == GBE_STATE_IDLE))
			{	
				handle_state_idle();
				_current_position->y = _current_gbe->row * TILESIZE_Y + BOARD_Y_OFFSET;
			}

			if (_current_gbe->state == GBE_STATE_MOVING_FALL)
			{	
				handle_state_falling ();
				_current_position->y = _current_gbe->row * TILESIZE_Y + BOARD_Y_OFFSET + TILESIZE_Y - (_current_gbe->y_off);
			}
			
			if (_current_gbe->moving_sideways)
			{
				handle_state_move_sideways ();
				_current_position->x = _current_gbe->col * TILESIZE_X + BOARD_X_OFFSET - TILESIZE_X + (_current_gbe->x_off);

			}
			
		}
		
		refill_pause_timer += _delta;
		
		if (refill_pause_timer >= refill_pause_time_between_rows)
		{
			refill_pause_timer = 0.0;

			if (g_GameState.game_state == GAME_STATE_PREP)
				refill_pause_time_between_rows = 0.5;
			else
				refill_pause_time_between_rows = 0.0;
			
			if (g_GameState.game_mode == GAME_MODE_SWEEP)
			{
				//don't horizontal fill during prep
				if (g_GameState.game_state == GAME_STATE_PREP)
					refill();
				else
					refill_horizontal();

			}
			else
			{
				refill();
			}
			
		}
		
		
		
	}
}
