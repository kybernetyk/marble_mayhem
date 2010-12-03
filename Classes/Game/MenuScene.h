/*
 *  MenuScene.h
 *  Fruitmunch
 *
 *  Created by jrk on 3/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once
#include "Scene.h"


namespace game 
{
	class MenuScene : public mx3::Scene
	{
	public:
		void preload ();
		void init ();
		void end ();
		
		void update (float delta);
		void render ();
		
		void frameDone ();
		
		~MenuScene();
	};
}
