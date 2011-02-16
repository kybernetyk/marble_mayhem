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
#include "NotificationSystem.h"

bool spawn_one = false;
bool spawn_player = false;

extern int g_ActiveGFX;

namespace game 
{
	
	std::string sounds[] =
	{
		"time_up.wav",
		"getready3.wav",
		"go1.wav",
		"game_over.wav",
		"blam1.wav",

		"c2.wav",
		"d2.wav",
		"e2.wav",
		"f2.wav",
		"g2.wav",

		"awesome2.wav",
		"incredible1.wav",
		"excellent3.wav",
		"blam2.wav",
		"solved2.wav",
		"impressive2.wav",
		"excellent1.wav",
		"excellent2.wav",
		"awesome1.wav",
		"impressive1.wav",
		"good1.wav",
		"good5.wav"
	};
	
	void GameScene::preload ()
	{

	}
	
	void GameScene::reset ()
	{
		g_GameState.game_state = 0;
		g_GameState.next_state = GAME_STATE_PREP;

//		_entityManager->removeAllEntities();
		_hudSystem->reset();
		_gameLogicSystem->reset();
		_gameBoardSystem->reset();
		
		_corpseRetrievalSystem->collectCorpses();
		
		
		go_played = false;
		
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
		_starSystem = new StarSystem (_entityManager);
		
		_gameLogicSystem = new GameLogicSystem (_entityManager);
		_hudSystem = new HUDSystem (_entityManager);
		_playerControlledSystem = new PlayerControlledSystem (_entityManager);
		_gameBoardSystem = new GameBoardSystem (_entityManager);
		
		
	//	_soundSystem->preloadSounds();
		for (int i = 0; i < NUM_SOUNDS; i++)
		{
			_soundSystem->registerSound (sounds[i], i);
		}
		
		
		preload();
		
		if (g_GameState.game_mode == GAME_MODE_TIMED || g_GameState.game_mode == GAME_MODE_ENDLESS)
		{
			std::string mfx[] = 
			{
//				"music1.wav",
				"music2.m4a",
				"music3.m4a"
			};
			
			int sz = sizeof (mfx) / sizeof (std::string);
			int r = rand()%sz;
			
			SoundSystem::play_background_music(mfx[r]);
			
		}
		else 
		{
			std::string mfx[] = 
			{
	
				"music4.mp3"
			};
			
			int sz = sizeof (mfx) / sizeof (std::string);
			int r = rand()%sz;

			SoundSystem::play_background_music(mfx[r]);
		}
		

		reset();
		
		/* create background */	
		Entity *bg = _entityManager->createNewEntity();
		Position *pos = _entityManager->addComponent <Position> (bg);
		Sprite *sprite = _entityManager->addComponent <Sprite> (bg);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("game_back.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -5.0;
		Name *name = _entityManager->addComponent <Name> (bg);
		name->name = "Game Background";
		
		/*create holzpanel*/
		bg = _entityManager->createNewEntity();
		pos = _entityManager->addComponent <Position> (bg);
		sprite = _entityManager->addComponent <Sprite> (bg);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("holzpanel.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -3.9;
		
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
				//SoundSystem::make_new_sound (SFX_COUNTDOWN);
				//_hudSystem->set_prep_text ("Get Ready ...");
				_hudSystem->change_prep_state (PREP_STATE_READY);
//				_hudSystem->show_prep_label();

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
				_hudSystem->change_prep_state (PREP_STATE_PLAY);
//				_hudSystem->hide_prep_label();	
			}
			
			if (g_GameState.game_state == GAME_STATE_GAMEOVER)
			{
				if (g_GameState.game_mode == GAME_MODE_TIMED)
					SoundSystem::make_new_sound (SFX_TIME_UP);
				else
					SoundSystem::make_new_sound (SFX_GAME_OVER);
				//_hudSystem->set_prep_text ("Game Over!");
				_hudSystem->change_prep_state (PREP_STATE_GAMEOVER);
//				_hudSystem->show_prep_label();
				
				saveHiScore();
				
				post_notification(kShowGameOverView);

			}

			if (g_GameState.game_state == GAME_STATE_SOLVED)
			{
				SoundSystem::make_new_sound (SFX_SOLVED);
				//_hudSystem->set_prep_text ("Game Over!");
				_hudSystem->change_prep_state (PREP_STATE_SOLVED);
//				_hudSystem->show_prep_label();
				
				saveHiScore();
				
				post_notification(kShowGameOverView);
				
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
		
		_animationSystem->update(delta);		
		_starSystem->update(delta);
		if (g_GameState.game_state == GAME_STATE_PLAY)
		{
			_gameLogicSystem->update(delta);
			_playerControlledSystem->update(delta);
			g_GameState.time_left -= (1.0 * delta);
			g_GameState.time_played += (1.0 * delta);
			if (g_GameState.time_left < 0.0 && g_GameState.game_mode == GAME_MODE_TIMED)
			{
				g_GameState.time_left = 0.0;
				g_GameState.next_state = GAME_STATE_GAMEOVER;
				g_GameState.gameover_reason = GO_REASON_NOTIME;
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
				//_hudSystem->set_prep_text (s);
				if ((int)prep_timer == 3)
					_hudSystem->change_prep_state (PREP_STATE_3);
				if ((int)prep_timer == 2)
					_hudSystem->change_prep_state (PREP_STATE_2);
				if ((int)prep_timer == 1)
					_hudSystem->change_prep_state (PREP_STATE_1);

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
				//_hudSystem->set_prep_text ("Go!");
				_hudSystem->change_prep_state (PREP_STATE_GO);
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
		
		
		//TODO: implement lateUpdate(dt) for systems that need to be updated after all other
		_particleSystem->update(delta);
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
		CV3Log("game scene dtor\n");
		delete _entityManager;
		delete _renderSystem;
		delete _movementSystem;
		delete _attachmentSystem;
		delete _actionSystem;
		delete _corpseRetrievalSystem;	
		delete _soundSystem;
		delete _animationSystem;
		delete _particleSystem;
		
		delete _hudSystem;
		delete _playerControlledSystem;
		delete _gameLogicSystem;
		delete _gameBoardSystem;
		delete _starSystem;
	}
	
	void GameScene::saveHiScore ()
	{
#ifdef USE_GAMECENTER
		NSString *strs[] = 
		{
			NULL,
			@"com.minyxgames.marblemayhem.timed",
			NULL,
			@"com.minyxgames.marblemayhemexpress.classic",
			@"com.minyxgames.marblemayhemexpress.classic",
			@"com.minyxgames.marblemayhemexpress.classic",
			@"com.minyxgames.marblemayhemexpress.classic",
			@"com.minyxgames.marblemayhemexpress.classic"
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