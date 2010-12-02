/*
 *  PlayerControlledSystem.cpp
 *  ComponentV3
 *
 *  Created by jrk on 8/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "Util.h"
#include "PlayerControlledSystem.h"
#include "InputDevice.h"
#include "ParticleSystem.h"

namespace game 
{
	

	PlayerControlledSystem::PlayerControlledSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		memset(_map,0x00,BOARD_NUM_COLS*BOARD_NUM_ROWS*sizeof(Entity*));

	}

	//create collision map
	void PlayerControlledSystem::update_map ()
	{
		memset(_map,0x00,BOARD_NUM_COLS*BOARD_NUM_ROWS*sizeof(Entity*));
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		Entity *_current_entity = NULL;
		GameBoardElement *_current_gbe = NULL;
		while (it != _entities.end())
		{
			_current_entity = *it;
			++it;
			_current_gbe = _entityManager->getComponent<GameBoardElement>(_current_entity);

			if ((_current_gbe->state == GBE_STATE_IDLE))
				_map[_current_gbe->col][_current_gbe->row] = _current_entity;
		}
	}
	
	
	//TODO: rename right blob and left blob to: left blob -> center blob, right blob -> rotating blob
	void PlayerControlledSystem::update (float delta)
	{
		bool move_left = false;
		bool move_right = false;
		bool rotate = false;
		
		
		move_left = InputDevice::sharedInstance()->getLeftActive();
		move_right = InputDevice::sharedInstance()->getRightActive();
		rotate = InputDevice::sharedInstance()->getUpActive();
		
		
		
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents (_entities, GameBoardElement::COMPONENT_ID, ARGLIST_END);
		update_map();
	
	}

}