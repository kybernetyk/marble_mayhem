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
	
	
	void GameBoardSystem::move_down ()
	{
	}
	

	void GameBoardSystem::handle_state_idle ()
	{
		if (_current_gbe->prev_state == GBE_STATE_MOVING_FALL)
		{
			_current_gbe->prev_state = GBE_STATE_IDLE;
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
		_current_gbe->y_off += _delta * (40.0/_current_gbe->fall_duration);	
		
		if (_current_gbe->y_move_timer >= _current_gbe->fall_duration)
		{
			_current_gbe->state = GBE_STATE_IDLE;
			_current_gbe->y_off = 40.0;
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
				_current_position->y = _current_gbe->row * 40.0 + BOARD_Y_OFFSET;
			}

			if (_current_gbe->state == GBE_STATE_MOVING_FALL)
			{	
				handle_state_falling ();
				_current_position->y = _current_gbe->row * 40.0 + BOARD_Y_OFFSET + 40.0 - (_current_gbe->y_off);
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
			
			
			refill();
		}
		
		
		
	}
}
