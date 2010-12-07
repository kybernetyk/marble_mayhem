/*
 *  Game.cpp
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "GameScene.h"
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

#import "GameCenterManager.h"

bool spawn_one = false;
bool spawn_player = false;

extern int g_ActiveGFX;

namespace game 
{
	
	std::string sounds[] =
	{
		"Time_Up.mp3",
		"Get_ready.mp3",
		"Go.mp3",
		"Game_Over.mp3",
		"gemongem2.mp3",
		"combo32.mp3",
		"combo42.mp3",
		"combo52.mp3",
		"combo62.mp3",
		"combo72.mp3",
//		"combo1.m4a",
//		"combo2.m4a",
//		"combo3.m4a",
//		"combo4.m4a",
//		"combo5.m4a",
//		"fuck1.mp3",
//		"fuck2.mp3",
//		"fuck3.mp3",
//		"fuck4.mp3",
//		"fuck5.mp3",
		
		"excellent1.mp3",
		"Incredible.mp3",
		"Good.mp3",
		"gotset2.mp3"
	};
	
	
	void GameScene::preload ()
	{

	}
	
	void GameScene::init ()
	{
		srand(time(0));
		
		g_GameState.reset();
		
		g_GameState.game_state = 0;
		g_GameState.next_state = GAME_STATE_PREP;
		
		
	
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
		
		
		for (int i = 0; i < NUM_SOUNDS; i++)
		{
			_soundSystem->registerSound (sounds[i], i);
		}
		
		_soundSystem->preloadSounds();
		
		
		preload();
		
		if (g_GameState.game_mode == GAME_MODE_TIMED)
		{
			SoundSystem::play_background_music("timed.mp3");
		}
		else 
		{
			SoundSystem::play_background_music("endless.mp3");	
		}

		
		
		/* create background */	
		Entity *bg = _entityManager->createNewEntity();
		Position *pos = _entityManager->addComponent <Position> (bg);
		Sprite *sprite = _entityManager->addComponent <Sprite> (bg);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("back.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -5.0;
		Name *name = _entityManager->addComponent <Name> (bg);
		name->name = "Game Background";
		
		go_played = false;
		
	}

	void GameScene::end ()
	{
		_entityManager->removeAllEntities();
	}

	
	void GameScene::update (float delta)
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
		
		if (g_GameState.game_state != g_GameState.next_state)
		{
			g_GameState.game_state = g_GameState.next_state;
			
			if (g_GameState.game_state == GAME_STATE_PREP)
			{
				go_played = false;
				prep_timer = 5.0;
				preptmp = (int)prep_timer;
				g_GameState.reset();

				SoundSystem::make_new_sound (SFX_GET_READY);
				_hudSystem->set_prep_text ("Get Ready ...");
				_hudSystem->show_prep_label();

//				for (int row = 0; row < BOARD_NUM_ROWS-1; row ++)
//				{
//					for (int col = 0; col < BOARD_NUM_COLS; col ++)
//					{
//						make_fruit(rand()%NUM_OF_FRUITS, col, row);		
//					}
//				}
				
			
			}
			
			if (g_GameState.game_state == GAME_STATE_PLAY)
			{
				_hudSystem->hide_prep_label();	
			}
			
			if (g_GameState.game_state == GAME_STATE_GAMEOVER)
			{
				SoundSystem::make_new_sound (SFX_GAME_OVER);
				_hudSystem->set_prep_text ("Game Over!");
				_hudSystem->show_prep_label();
				
				saveHiScore();

			}
			
		}
		
		//we must collect the corpses from the last frame
		//as the entity-manager's isDirty property is reset each frame
		//so if we did corpse collection at the end of update
		//the systems wouldn't know that the manager is dirty 
		//and a shitstorm of dangling references would rain down on them
		_corpseRetrievalSystem->collectCorpses();
		
		
		//wegen block removal und marking mit MOD
		//im normalspiel wohl wayne
		//kann also runterbewegt werden		

		
		_actionSystem->update(delta);
		_movementSystem->update(delta);
		_attachmentSystem->update(delta);
		_gameBoardSystem->update(delta);		
		_hudSystem->update(delta);
		_soundSystem->update(delta);
		_particleSystem->update(delta);
		_animationSystem->update(delta);		
		
		if (g_GameState.game_state == GAME_STATE_PLAY)
		{
			_gameLogicSystem->update(delta);
			_playerControlledSystem->update(delta);
			g_GameState.time_left -= (1.0 * delta);
			if (g_GameState.time_left < 0.0 && g_GameState.game_mode == GAME_MODE_TIMED)
			{
				g_GameState.time_left = 0.0;
				g_GameState.next_state = GAME_STATE_GAMEOVER;
				_gameLogicSystem->handle_chain();
			}

		}

		if (g_GameState.game_state == GAME_STATE_PREP)
		{
			prep_timer -= delta;
			char s[255];
			sprintf(s,"Go in %.2f ...", prep_timer);
			
			if ((int)prep_timer >= 1 && (int)prep_timer < 4)
			{
				sprintf(s, "%i", (int)prep_timer);
				_hudSystem->set_prep_text (s);
			}

			if (preptmp != (int)prep_timer)
			{
				preptmp = (int)prep_timer;
				if (prep_timer > 1 && prep_timer < 4)
					SoundSystem::make_new_sound (SFX_COUNTDOWN);
			}
			
			
			if ((int)prep_timer < 1)
			{
				if (!go_played)
				{	
					SoundSystem::make_new_sound (SFX_GO);
					go_played = true;
				}
				_hudSystem->set_prep_text ("Go!");
			}
				
			
			if (prep_timer <= 0.0)
			{
				g_GameState.next_state = GAME_STATE_PLAY;
			}
		}
		
		if (spawn_one)
		{
			spawn_one = false;
		}
		
		if (spawn_player)
		{
			spawn_player = false;
		}
		
		
		
		
	}

	void GameScene::render ()
	{
		_renderSystem->render();

	}

	void GameScene::frameDone ()
	{
		_entityManager->setIsDirty (false);
	}
	
	GameScene::~GameScene()
	{
		
	}
	
	void GameScene::saveHiScore ()
	{
#ifdef USE_GAMECENTER
		NSString *strs[] = 
		{
			NULL,
			@"com.minyxgames.fruitmunch.timed",
			NULL,
			@"com.minyxgames.fruitmunch.testlol"
		};
		
		NSString *cat = strs[g_GameState.game_mode];
		
		if (cat)
		{	
			[g_pGameCenterManger reportScore: g_GameState.score 
								 forCategory: cat];
		}
		
#endif
	}

}