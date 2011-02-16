/*
 *  Fruit.h
 *  Fruitmunch
 *
 *  Created by jrk on 2/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#pragma once
namespace mx3 
{
	struct Entity;
}

namespace game
{
	mx3::Entity *make_fruit (int fruit_type, int col, int row);
	mx3::Entity *bb_make_fruit (int fruit_type, int col, int row);
}