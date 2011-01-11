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
#include "globals.h"
#include "TexturedQuad.h"
#include "EntityManager.h"
#include "RenderSystem.h"
#include "MovementSystem.h"
#include "ParticleSystem.h"
#include "PlayerControlledSystem.h"
#include "AttachmentSystem.h"
#include "ActionSystem.h"
#include "GameLogicSystem.h"
#include "CorpseRetrievalSystem.h"
#include "HUDSystem.h"
#include "SoundSystem.h"
#include "AnimationSystem.h"
#include "GameBoardSystem.h"
#include "StarSystem.h"
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
		void reset ();
		
		int scene_type ()
		{
			return SCENE_TYPE_MAIN_MENU;
		}
		
		mx3::Entity *create_button (vector2D pos, const char *text);
		
		~MenuScene();
	protected:
		mx3::EntityManager *_entityManager;
		mx3::RenderSystem *_renderSystem;
		game::StarSystem *_starSystem;
	};
}
