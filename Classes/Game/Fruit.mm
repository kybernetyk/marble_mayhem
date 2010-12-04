/*
 *  Fruit.cpp
 *  Fruitmunch
 *
 *  Created by jrk on 2/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "Fruit.h"
#include "ComponentV3.h"
#include "globals.h"
#include "GameComponents.h"

using namespace mx3;
namespace game 
{
	std::string fruit_filenames[] = {
		"orange40.png",
		"strawberry.png",
		"banana40.png",
		"grapes40.png"
	};
	
	
	
	Entity *make_fruit (int fruit_type, int col, int row)
	{
		EntityManager *em = Entity::entityManager;
		Entity *e = em->createNewEntity();

		std::string fruit_filename = fruit_filenames[fruit_type];
		
		Sprite *sprite = em->addComponent <Sprite> (e);
		sprite->quad = g_RenderableManager.accquireTexturedQuad(fruit_filename);
		//sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = 1.0;
		
		Position *pos = em->addComponent <Position> (e);
		pos->x = BOARD_X_OFFSET + col * TILESIZE_X;
		pos->y = BOARD_Y_OFFSET + row * TILESIZE_Y;
		
		GameBoardElement *gbe = em->addComponent <GameBoardElement> (e);
		gbe->type = fruit_type;
		gbe->prev_col = gbe->col = col;
		gbe->prev_row = gbe->row = row;
		gbe->state = GBE_STATE_IDLE;
		
		return e;
	}
}
