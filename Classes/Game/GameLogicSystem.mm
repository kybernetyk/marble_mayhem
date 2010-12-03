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

#include "GameLogicSystem.h"
#include "Texture2D.h"
#include "SoundSystem.h"
#include "globals.h"

#include "Component.h"
#include "GameComponents.h"

namespace game 
{


	GameLogicSystem::GameLogicSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		marked_color = -1;
		head_row = -1;
		head_col = -1;
		num_of_marks = 0;
		
		memset (markers, 0x00, MAX_MARKERS * sizeof(Entity*));
		marker_index = 0;
		
	}



	void GameLogicSystem::update (float delta)
	{
		_delta = delta;

		vector2D v = InputDevice::sharedInstance()->touchLocation();
		
		bool touch = InputDevice::sharedInstance()->isTouchActive();
		
		int col = (v.x - BOARD_X_OFFSET + 20) / 40.0;
		int row = (v.y - BOARD_Y_OFFSET + 20) / 40.0;
		
		if (touch)
		{
			printf("touch: %f,%f\n",v.x,v.y);
			printf("col: %i, row: %i\n",col,row);
		}
		else 
		{
			marked_color = -1;
			head_row = -1;
			head_col = -1;
		}

		
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
			
			
			if (touch) //mark
			{
				if (!current_gbe->marked)
				{
					if ((current_gbe->col == col) && (current_gbe->row == row))
					{	
						if (marked_color == -1)
							marked_color = current_gbe->type;
						if (head_col == -1 || head_row == -1)
						{
							head_row = current_gbe->row;
							head_col = current_gbe->col;
						}
						
						if (current_gbe->type == marked_color)
						{	
							int diff = 0;
							
							diff = ( abs (current_gbe->row - head_row) + 
									abs (current_gbe->col - head_col));
						
							
							if (diff <= 1)
							{	
								num_of_marks ++;
								current_gbe->marked = true;
								head_col = current_gbe->col;
								head_row = current_gbe->row;
								
								if (marker_index < MAX_MARKERS)
								{
									Entity *pe = ParticleSystem::createParticleEmitter ("marker.pex", -1.0 , vector2D_make(col * 40 + BOARD_X_OFFSET, row*40+BOARD_Y_OFFSET));
									
									markers[marker_index++] = pe;
								}
							}
						}
						
					}
				}
			}
			else		//kill all touched
			{
				if (current_gbe->marked)
				{
					if (num_of_marks >= 2)
					{
						_entityManager->addComponent <MarkOfDeath> (current_entity);
						
						Entity *pe = ParticleSystem::createParticleEmitter ("marker2.pex", 0.25 , vector2D_make(current_gbe->col * 40 + BOARD_X_OFFSET, current_gbe->row*40+BOARD_Y_OFFSET));

					}
					
					
					current_gbe->marked = false;
				}
			}
			
		}
		
		if (!touch)
		{
			num_of_marks = 0;
		}
		
		if (InputDevice::sharedInstance()->touchUpReceived())
		{
			for (int i = 0; i < MAX_MARKERS; i++)
			{
				Entity *e = markers[i];
				if (e)
				{
					markers[i] = NULL;
					//_entityManager->addComponent <MarkOfDeath> (e);
					PEmitter *pe = _entityManager->getComponent <PEmitter> (e);
					[pe->pe->pe setDuration: 0.1];
				}
			}
			marker_index = 0;
		}
	}
}