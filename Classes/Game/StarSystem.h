/*
 *  StarSystem.h
 *  Fruitmunch
 *
 *  Created by jrk on 9/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once
#include <vector>
#include "EntityManager.h"
#include "globals.h"
using namespace mx3;

namespace game
{

#define MAX_STARS 12
	
	class StarSystem
	{
	public:
		StarSystem (EntityManager *entityManager);
		void update (float delta);	
		
		void reset ();
	protected:
		std::vector<Entity*> _entities;

		//TODO: rename right blob and left blob to: left blob -> center blob, right blob -> rotating blob		
		EntityManager *_entityManager;
		float _delta;
	};
	
}


