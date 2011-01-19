/*
 *  StarSystem.mm
 *  Fruitmunch
 *
 *  Created by jrk on 9/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "StarSystem.h"
#include "GameComponents.h"

namespace game 
{
#define NUM_OF_STARTYPES 9
	
	std::string star_names[] = 
	{
		"star1.png",
		"star2.png",
		"star3.png",
		"star4.png",
		"star5.png",
		"star6.png",
		"star7.png",
		"star8.png",
		"star9.png"
	};
	
	Entity *make_star (int type, int x, int y, float fall_speed)
	{
		EntityManager *em = Entity::entityManager;
		
		Entity *ret = em->createNewEntity();
		
		Position *pos = em->addComponent <Position> (ret);
		pos->x = x;
		pos->y = y;
		
		std::string fname = star_names[type];
		
		Sprite *spr = em->addComponent <Sprite> (ret);
		spr->z = -4.0;
		spr->alpha = 0.5;
		spr->res_handle = g_RenderableManager.acquireResource <TexturedQuad> (fname);
		
		Star *star = em->addComponent <Star> (ret);
		star->fall_speed = fall_speed;
		
		return ret;
	}
	
	StarSystem::StarSystem (EntityManager *entityManager)
	{
		_entityManager = entityManager;
		reset();
	}
	
	void StarSystem::reset ()
	{
		
	}
	
	
	//TODO: rename right blob and left blob to: left blob -> center blob, right blob -> rotating blob
	void StarSystem::update (float delta)
	{
		_delta = delta;
		_entities.clear();
		_entityManager->getEntitiesPossessingComponents(_entities, Star::COMPONENT_ID, Position::COMPONENT_ID, ARGLIST_END );

		int diff = MAX_STARS - _entities.size();
		
		if (diff > 0)
		{	
			for (int i = 0; i < diff; i++)
			{
				int x = rand()%(int)(SCREEN_W-32);
				int y = rand()%(int)SCREEN_H + 80;
				int type = rand()%NUM_OF_STARTYPES;
				float fall_speed = 32.0 + rand()%196;
				
				make_star(type, x, y, fall_speed);
			}
			
			_entities.clear();
			_entityManager->getEntitiesPossessingComponents(_entities, Star::COMPONENT_ID, Position::COMPONENT_ID, ARGLIST_END );
		}
		
		
		std::vector<Entity*>::const_iterator it = _entities.begin();
		
		Entity *current_entity = NULL;
		Star *current_star = NULL;
		Sprite *current_sprite = NULL;
		Position *current_position = NULL;
		while (it != _entities.end())
		{
			current_entity = *it;
			++it;
			
			current_star = _entityManager->getComponent <Star> (current_entity);
			current_position = _entityManager->getComponent <Position> (current_entity);
			current_sprite = _entityManager->getComponent <Sprite> (current_entity);
			
			
			current_position->y -= current_star->fall_speed * _delta;
			current_position->rot += current_star->fall_speed*0.5 * _delta;
			
			if (current_position->y <= -80.0)
			{	
				current_position->x = rand()%(int)SCREEN_W;
				current_position->y = SCREEN_H + 80.0;
				current_star->fall_speed = 32.0 + rand()%128;
				int type = rand()%NUM_OF_STARTYPES;
				
				int r = rand()%128;
				float a = 0.5 + (float)r/255.0;
				
				current_sprite->alpha = a;
				
				g_RenderableManager.release (&current_sprite->res_handle);

				std::string fname = star_names[type];
				current_sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> (fname);
			}
		}
	}
	
}