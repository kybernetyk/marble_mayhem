/*
 *  Game.h
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */
#pragma once
#include "TexturedQuad.h"
#include "EntityManager.h"
#include "RenderSystem.h"
#include "MovementSystem.h"
#include "ParticleSystem.h"
#include "PlayerControlledSystem.h"
#include "AttachmentSystem.h"
#include "ActionSystem.h"
#include "BB_GameLogicSystem.h"
#include "CorpseRetrievalSystem.h"
#include "HUDSystem.h"
#include "SoundSystem.h"
#include "AnimationSystem.h"
#include "BB_GameBoardSystem.h"
#include "StarSystem.h"
#include "Scene.h"

using namespace mx3;

namespace game 
{
	class BB_GameScene : public mx3::Scene
	{
	public:
		void preload ();
		void init ();
		void end ();
		
		void update (float delta);
		void render ();
		
		void frameDone ();
		
		~BB_GameScene ();
		
		void saveHiScore ();
		
		void reset ();
		
		int scene_type ()
		{
			return SCENE_TYPE_GAME;
		}
		
	protected:
		EntityManager *_entityManager;
		RenderSystem *_renderSystem;
		MovementSystem *_movementSystem;
		AttachmentSystem *_attachmentSystem;
		ActionSystem *_actionSystem;
		CorpseRetrievalSystem *_corpseRetrievalSystem;	
		SoundSystem *_soundSystem;
		AnimationSystem *_animationSystem;
		ParticleSystem *_particleSystem;

		HUDSystem *_hudSystem;
		PlayerControlledSystem *_playerControlledSystem;
		BB_GameLogicSystem *_gameLogicSystem;
		BB_GameBoardSystem *_gameBoardSystem;
		StarSystem *_starSystem;
		
		Button replay_button;
		Button menu_button;

		
		float prep_timer;
		bool go_played;
		int preptmp;
	};

}