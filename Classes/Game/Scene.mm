/*
 *  Game.cpp
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "Scene.h"
#include "InputDevice.h"
#include "Entity.h"

#include "EntityManager.h"
#include "Component.h"

#include "RenderSystem.h"
#include "MovementSystem.h"
#include "HUDSystem.h"
#include "globals.h"

#include "RenderDevice.h"

#import "ParticleEmitter.h"
#include "GameComponents.h"

#import "Fruit.h"

bool spawn_one = false;
bool spawn_player = false;

extern int g_ActiveGFX;

namespace game 
{
	void Scene::preload ()
	{

	}
	
	void Scene::init ()
	{
		srand(time(0));

	
		_entityManager = new EntityManager;
		_renderSystem = new RenderSystem (_entityManager);
		_movementSystem = new MovementSystem (_entityManager);
		_attachmentSystem = new AttachmentSystem (_entityManager);
		_actionSystem = new ActionSystem (_entityManager);
		_particleSystem = new ParticleSystem (_entityManager);
		_corpseRetrievalSystem = new CorpseRetrievalSystem (_entityManager);
		_soundSystem = new SoundSystem (_entityManager);
		_animationSystem = new AnimationSystem (_entityManager);

		
		_gameLogicSystem = new GameLogicSystem (_entityManager);
		_hudSystem = new HUDSystem (_entityManager);
		_playerControlledSystem = new PlayerControlledSystem (_entityManager);
		_gameBoardSystem = new GameBoardSystem (_entityManager);
		
		
		
		
		
		preload();
		
		
		_soundSystem->playMusic(MUSIC_GAME);

		/* create background */	
		Entity *bg = _entityManager->createNewEntity();
		Position *pos = _entityManager->addComponent <Position> (bg);
		Sprite *sprite = _entityManager->addComponent <Sprite> (bg);
		sprite->quad = g_RenderableManager.accquireTexturedQuad ("back.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -5.0;
		Name *name = _entityManager->addComponent <Name> (bg);
		name->name = "Game Background";
		
		for (int row = 0; row < BOARD_NUM_ROWS-1; row ++)
		{
			for (int col = 0; col < BOARD_NUM_COLS; col ++)
			{
				make_fruit(rand()%NUM_OF_FRUITS, col, row);		
			}
		}
		
	}

	void Scene::end ()
	{

	}

	
	void Scene::update (float delta)
	{

		//tex->updateTextureWithBufferData();
		InputDevice::sharedInstance()->update();

/*		if (InputDevice::sharedInstance()->touchUpReceived())
		{
			unsigned char *buf = tq->alpha_mask;
			
			
			int xc = InputDevice::sharedInstance()->touchLocation().x;
			int yc = InputDevice::sharedInstance()->touchLocation().y;
			
			yc = SCREEN_H - yc;
						
			tq->alpha_draw_circle_fill( xc, yc, 24, 0x00);
			
			
			tq->apply_alpha_mask();
		}
*/
		
		//we must collect the corpses from the last frame
		//as the entity-manager's isDirty property is reset each frame
		//so if we did corpse collection at the end of update
		//the systems wouldn't know that the manager is dirty 
		//and a shitstorm of dangling references would rain down on them
		_corpseRetrievalSystem->collectCorpses();
		
		
		//wegen block removal und marking mit MOD
		//im normalspiel wohl wayne
		//kann also runterbewegt werden		
		_gameLogicSystem->update(delta);

		
		
		_playerControlledSystem->update(delta);
		_actionSystem->update(delta);
		_movementSystem->update(delta);
		_attachmentSystem->update(delta);
		_gameBoardSystem->update(delta);
		




		_hudSystem->update(delta);
		_soundSystem->update(delta);
		
		_particleSystem->update(delta);
		


		_animationSystem->update(delta);		
		if (spawn_one)
		{
			spawn_one = false;
		}
		
		if (spawn_player)
		{
			spawn_player = false;
		}
		
		
	}

	void Scene::render (float interpolation)
	{
		_renderSystem->render();

	}

	void Scene::frameDone ()
	{
		_entityManager->setIsDirty (false);
	}

}