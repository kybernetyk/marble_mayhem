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
	
	Entity *make_fruit (int fruit_type, int col, int row)
	{
		EntityManager *em = Entity::entityManager;
		Entity *e = em->createNewEntity();

		std::string filename = "fruits.png";
		
		AtlasSprite *as = em->addComponent<AtlasSprite>(e);
		as->res_handle = g_RenderableManager.acquireResource <TexturedAtlasQuad> (filename);
		as->src = rect_make(fruit_type*53, 0, 53, 53);
		as->z = 3;
		
		
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
