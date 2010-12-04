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
	
	void GameLogicSystem::remove_chain ()
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
					
					ParticleSystem::createParticleEmitter ("marker2.pex", 0.25 , 
														   vector2D_make(current_gbe->col * 40 + BOARD_X_OFFSET, current_gbe->row*40+BOARD_Y_OFFSET));
				}
				current_gbe->marked = false;
			}
		}
	}
	
	
	void GameLogicSystem::handle_chain ()
	{
		//score if the chain had 2 or more entries
		if (num_of_marks >= 2)
		{
			int score = (num_of_marks * 15) * num_of_marks;
			float num = num_of_marks;
			float time_add = ((float)(num*0.25*num*0.25));		//0.25
			
			//only add time for chain if we're playinh (not game over)
			if (g_GameState.game_state == GAME_STATE_PLAY && g_GameState.next_state == GAME_STATE_PLAY)
			{
				g_GameState.time_left += time_add;
			}
			g_GameState.score += score;
//			
//			printf("%i combo:\n", num_of_marks);
//			printf("\t+score = %i. (%.2f score per fruit)\n", score, (float)((float)score/(float)num_of_marks) );
//			printf("\t+time = %.4f. (%.4f time per fruit)\n\n", time_add, (time_add/num_of_marks) );
		}
		
		
		//remove the markers
		for (int i = 0; i < MAX_MARKERS; i++)
		{
			Entity *e = markers[i];
			if (e)
			{
				markers[i] = NULL;
				PEmitter *pe = _entityManager->getComponent <PEmitter> (e);
				[pe->pe->pe setDuration: 0.1];
			}
		}		
		
		remove_chain ();
		
		marker_index = 0;
		num_of_marks = 0;
	}
	
	void GameLogicSystem::mark_chain ()
	{
		vector2D v = InputDevice::sharedInstance()->touchLocation();
		int col = (v.x - BOARD_X_OFFSET + 20) / 40.0;
		int row = (v.y - BOARD_Y_OFFSET + 20) / 40.0;
		
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
	}

	void GameLogicSystem::update (float delta)
	{
		_delta = delta;
		
		bool touch = InputDevice::sharedInstance()->isTouchActive();
		if (touch)
		{
			mark_chain();
		}
		else 
		{
			marked_color = -1;
			head_row = -1;
			head_col = -1;
		}
		
		if (InputDevice::sharedInstance()->touchUpReceived())
		{
			handle_chain();
		}
	}
}