/*
 *  GameBoardSystem.cpp
 *  Donnerfaust
 *
 *  Created by jrk on 17/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "BB_GameBoardSystem.h"
#include "GameComponents.h"
#include "Fruit.h"
#include "SoundSystem.h"
#include "ParticleSystem.h"

namespace game 
{
	extern mx3::PE_Proxy *g_pSparksCache[BB_BOARD_NUM_MARKERS];

	extern PE_Proxy *get_free_spark ();

	BB_GameBoardSystem::BB_GameBoardSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		reset();
	}
	
	void BB_GameBoardSystem::reset ()
	{
		memset(_map,0x00,BB_BOARD_NUM_COLS*BB_BOARD_NUM_ROWS*sizeof(Entity*));
		refill_pause_time_between_rows = 0.0;
		refill_pause_timer = 0.0;
		fruit_alternator = 0;
		
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities,  GameBoardElement::COMPONENT_ID, ARGLIST_END );
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			
			//_entityManager->removeEntity(_current_entity->_guid);
			_entityManager->addComponent <MarkOfDeath> (_current_entity);
		}
	}
	
	void BB_GameBoardSystem::update_map ()
	{
		memset(_map,0x00,BB_BOARD_NUM_COLS*BB_BOARD_NUM_ROWS*sizeof(Entity*));
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			
			//if ((_current_gbe->state == GBE_STATE_IDLE))
			//if there should be another entity with our coordinates: remove it to prevent
			//2 fruits occupying one spot
//			if (_map[_current_gbe->col][_current_gbe->row])
//			{
//				_entityManager->addComponent <MarkOfDeath> (_current_entity);
//			}
//			else
			{
				_map[_current_gbe->col][_current_gbe->row] = _current_entity;
			}
		}
	}
	
	
	
	void BB_GameBoardSystem::update_map_with_prevs ()
	{
		memset(_map,0x00,BB_BOARD_NUM_COLS*BB_BOARD_NUM_ROWS*sizeof(Entity*));
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		_current_entity = NULL;
		_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
			
			//if ((_current_gbe->state == GBE_STATE_IDLE))
			//if there should be another entity with our coordinates: remove it to prevent
			//2 fruits occupying one spot
			//			if (_map[_current_gbe->col][_current_gbe->row])
			//			{
			//				_entityManager->addComponent <MarkOfDeath> (_current_entity);
			//			}
			//			else
			{
				_map[_current_gbe->col][_current_gbe->prev_row] = _current_entity;
				_map[_current_gbe->col][_current_gbe->row] = _current_entity;
			}
		}
	}
	
	bool BB_GameBoardSystem::can_move_down ()
	{
		if (_current_gbe->row - 1 < 0)
			return false;
		
		int row = _current_gbe->row - 1;
		int col = _current_gbe->col;
		
		if (_map[col][row])
			return false;
		
//		
//		std::vector<Entity*>::const_iterator it = _entities.begin();
//		Entity *current_entity = NULL;
//		GameBoardElement *current_gbe = NULL;
//		Position *pos = NULL;
//		while (it != _entities.end())
//		{
//			current_entity = *it;
//			++it;
//			current_gbe = _entityManager->getComponent<GameBoardElement>(current_entity);
//			pos = _entityManager->getComponent<Position>(current_entity);
//
//			if (current_entity != _current_entity)
//			{
//				if (current_gbe->row == row && current_gbe->col == col)
//					return false;
//			}
//		}
		
		return true;
	}
	
	
	void BB_GameBoardSystem::handle_state_idle ()
	{
		if (_current_gbe->prev_state == GBE_STATE_MOVING_FALL)
		{
			_current_gbe->prev_state = GBE_STATE_IDLE;
			
			if (!can_move_down())
			{	
				_current_gbe->vy = 1.0;
				_current_gbe->nograv = false;

				//_map[_current_gbe->col][_current_gbe->row] = _current_entity;
				
				if (_current_gbe->row < BB_BOARD_NUM_VISIBLE_ROWS)
				{				
					SoundSystem::make_new_sound (SFX_FRUIT_LAND);

					// penis
					if (_current_gbe->row < spark_rows[_current_gbe->col])
					{
						spark_rows[_current_gbe->col] = _current_gbe->row;
					}
				}
			}
		}
		
		if (can_move_down())
		{
			_current_gbe->state = GBE_STATE_MOVING_FALL;
			
			
			for (int row = _current_gbe->row; row < BB_BOARD_NUM_ROWS; row++)
			{
				Entity *e = _map[_current_gbe->col][row];
				if (!e)
					continue;
				
				GameBoardElement *g = _entityManager->getComponent <GameBoardElement> (e);
				if (g->state == GBE_STATE_MOVING_FALL)
					g->vy = _current_gbe->vy;
			}
			
			_map[_current_gbe->col][_current_gbe->row] = 0;
		}
		else
		{
			_current_gbe->landed = true;
			
		}
	}

	void BB_GameBoardSystem::handle_state_falling ()
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
		
		//in prep simply fall without accel
		
		if (g_GameState.game_state == GAME_STATE_PREP)
		{
			_current_gbe->y_off += _delta * (BB_TILESIZE_Y/_current_gbe->fall_duration);	
			if (_current_gbe->y_move_timer >= _current_gbe->fall_duration)
			{
				_current_gbe->state = GBE_STATE_IDLE;
				_current_gbe->y_off = BB_TILESIZE_Y;
			}
		}
		else
		{
			_current_gbe->vy += _delta * BB_TILESIZE_Y;
			if (_current_gbe->vy > 18.0)
				_current_gbe->vy = 18.0;
			_current_gbe->y_off += (_current_gbe->vy * _current_gbe->vy) * _delta;
			
			if (_current_gbe->y_off >= BB_TILESIZE_Y)
			{
				_current_gbe->state = GBE_STATE_IDLE;
				_current_gbe->y_off = BB_TILESIZE_Y;
				
			}
		}

		//if (_current_gbe->vy > TILESIZE_Y/_current_gbe->fall_duration)
		//	_current_gbe->vy = TILESIZE_Y/_current_gbe->fall_duration;

		
		
	}

	
	void BB_GameBoardSystem::handle_state_move_sideways ()
	{
		_current_gbe->x_move_timer += _delta;
		_current_gbe->x_off += _delta * (BB_TILESIZE_X/_current_gbe->fall_duration);	
		
		if (_current_gbe->x_move_timer >= _current_gbe->fall_duration)
		{
			_current_gbe->moving_sideways = false;
			_current_gbe->x_off = BB_TILESIZE_X;
			
		}
		
	}
	
	
	static bool sortie (Entity *e1, Entity *e2)
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

	void BB_GameBoardSystem::refill ()
	{

		//in prep fill only visible field
		
		int check_index = BB_BOARD_NUM_ROWS-2;
		int spawn_index = BB_BOARD_NUM_ROWS-1;
		
		if (g_GameState.game_mode == GAME_MODE_BB)
		{	
			check_index = BB_BOARD_NUM_VISIBLE_ROWS-1;
			spawn_index = BB_BOARD_NUM_VISIBLE_ROWS;
		}
		
		if (g_GameState.game_state == GAME_STATE_PREP)
		{
			update_map ();
			for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
			{
				if (!_map[col][check_index])
				{
					bb_make_fruit(fruit_alternator + rand()%g_GameState.num_of_fruits, col, spawn_index);
					g_GameState.fruits_on_board ++;
				}
			}
		}
		else
		{
			update_map_with_prevs ();
			for (int row = BB_BOARD_NUM_VISIBLE_ROWS; row < BB_BOARD_NUM_ROWS-1; row ++)
			{	
				for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
				{
					if (!_map[col][row])
					{
						Entity *f = bb_make_fruit(fruit_alternator + rand()%g_GameState.num_of_fruits, col, row);
						g_GameState.fruits_on_board ++;
						_map[col][row] = f;

					}
				}
			}
		}
	}
	
	void BB_GameBoardSystem::refill_horizontal ()
	{	
		update_map();

		bool move = false;
		for (int col = BB_BOARD_NUM_COLS-1; col >= 0; col--)
		{
			if (!move)
			{
				int sum = 0;
				for (int row = 0; row < BB_BOARD_NUM_ROWS; row++)
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
				for (int row = 0; row < BB_BOARD_NUM_ROWS; row++)
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
	
	
	void BB_GameBoardSystem::update (float delta)
	{
		_delta = delta;
		/* create collision map */	
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities,  GameBoardElement::COMPONENT_ID, ARGLIST_END );
		std::sort (_entities.begin(), _entities.end(), sortie);
		//falldown
		
		for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
			spark_rows[col] = BB_BOARD_NUM_ROWS;
		

//		update_map();
//		
//		for (int row = 0; row < BOARD_NUM_ROWS; row++)
//		{
//			for (int col = 0; col < BOARD_NUM_COLS; col++)
//			{
//				//				_current_entity = *it;
//				_current_entity = _map[col][row];
//				if (!_current_entity)
//					continue;
//				
//				
//				_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
//				_current_position = _entityManager->getComponent<Position>(_current_entity);
//				
//				if ((_current_gbe->state == GBE_STATE_IDLE))
//				{	
//					handle_state_idle();
//					_current_position->y = _current_gbe->row * TILESIZE_Y + BOARD_Y_OFFSET;
//				}
//			}
//			
//		}		
//		
				update_map();
		
//		for (int row = 0; row < BOARD_NUM_ROWS; row ++)
//		{
//			for (int col = 0; col < BOARD_NUM_COLS; col++)
//			{
//				if (!_map[col][row])
//				{
//					for (int j = row; j < BOARD_NUM_ROWS; j++)
//					{
//						_map[col][j] = NULL;
//					}
//				}
//			}
//		}
		
//		std::vector<Entity*>::const_iterator it = _entities.begin();
//		_current_entity = NULL;
//		_current_gbe = NULL;
//		while (it != _entities.end())
//		{

		for (int row = 0; row < BB_BOARD_NUM_ROWS; row++)
		{
			for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
			{
//				_current_entity = *it;
				_current_entity = _map[col][row];
				if (!_current_entity)
					continue;
				
				//++it;
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
					_current_position->y = _current_gbe->row * BB_TILESIZE_Y + BB_BOARD_Y_OFFSET;
				}
				
				if (_current_gbe->state == GBE_STATE_MOVING_FALL)
				{	
					handle_state_falling ();
					_current_position->y = _current_gbe->row * BB_TILESIZE_Y + BB_BOARD_Y_OFFSET + BB_TILESIZE_Y - (_current_gbe->y_off);
				}
				
				if (_current_gbe->moving_sideways)
				{
					handle_state_move_sideways ();
					_current_position->x = _current_gbe->col * BB_TILESIZE_X + BB_BOARD_X_OFFSET - BB_TILESIZE_X + (_current_gbe->x_off);

				}

			}			
		}
		

		
//		for (int row = 0; row < BOARD_NUM_ROWS; row ++)
//		{
//			for (int col = 0; col < BOARD_NUM_COLS; col++)
//			{
//				if (!_map[col][row])
//				{
//					for (int j = row; j < BOARD_NUM_ROWS; j++)
//					{
//						_map[col][j] = NULL;
//					}
//				}
//			}
//		}
//		
		
//		it = _entities.begin();
//		while (it != _entities.end())
//		{
//			_current_entity = *it;
//			++it;

		
		
		update_map();
//
//		//urgs hack so puzzle mode will not go gameover before all stone in movement are accounted
//		it = _entities.begin();
//		while (it != _entities.end())
//		{
//			_current_entity = *it;
//			++it;
		for (int row = 0; row < BB_BOARD_NUM_ROWS; row++)
		{
			for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
			{
				//				_current_entity = *it;
				_current_entity = _map[col][row];
				if (!_current_entity)
					continue;
				_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);
				_current_position = _entityManager->getComponent<Position>(_current_entity);

				if ((_current_gbe->state == GBE_STATE_IDLE))
				{	
					handle_state_idle();
					_current_position->y = _current_gbe->row * BB_TILESIZE_Y + BB_BOARD_Y_OFFSET;
				}
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
			
			if (g_GameState.game_mode == GAME_MODE_BB)
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
		
		
		if (g_ParticlesEnabled)
		{
			for (int col = 0; col < BB_BOARD_NUM_COLS; col++)
			{
				if (spark_rows[col] < BB_BOARD_NUM_ROWS)
				{
					int row = spark_rows[col];
					
					PE_Proxy *pe = get_free_spark();
					if (pe)
					{
						ParticleSystem::createParticleEmitter (pe,
															   0.25,
															   vector2D_make(col * BB_TILESIZE_X + BB_BOARD_X_OFFSET, row*BB_TILESIZE_Y+BB_BOARD_Y_OFFSET-BB_TILESIZE_Y+10));
						pe->setDuration(0.25);
						pe->reset();
						pe->start();
					}
				}
			}
		}		
	}
}
