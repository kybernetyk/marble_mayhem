/*
 *  Game.cpp
 *  SpaceHike
 *
 *  Created by jrk on 6/11/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "BB_GameScene.h"
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
#include "Game.h"
#import "Fruit.h"


#include "NotificationSystem.h"

extern int g_ActiveGFX;

bool point_in_entity (mx3::vector2D vec, Entity *e)
{
	if (!e)
		return false;

	mx3::Position *pos = mx3::Entity::entityManager->getComponent <mx3::Position> (e);
	if (!pos)
		return false;
	
	mx3::Renderable *ren =  mx3::Entity::entityManager->getComponent <mx3::Renderable> (e);
	if (!ren)
		return false;

	float x = pos->x;
	float y = pos->y;
	float w;
	float h;
	
	TexturedQuad *tq = 0;
	switch (ren->_renderable_type) 
	{
		case RENDERABLETYPE_SPRITE:
			tq = (TexturedQuad*)g_RenderableManager.getResource <TexturedQuad> (&ren->res_handle);
			w = tq->w * fabs(pos->scale_x);
			h = tq->h * fabs(pos->scale_y);
			x -= w * (1.0 - ren->anchorPoint.x);
			y -= h * (1.0 - ren->anchorPoint.y);
			break;
		default:
			NSLog(@"not implemented yet!")
			return false;
			break;
	};
	//printf("is %f,%f in (%f,%f <-> %f,%f)?\n",vec.x,vec.y, x,y,x+w,x+h);
	if (vec.x >= x && vec.x <= x + w &&
		vec.y >= y && vec.y <= y + h)
		return true;
	
	return false;
}

namespace game 
{
	extern std::string sounds[];
	void BB_GameScene::preload ()
	{

	}
	
	void BB_GameScene::reset ()
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
	
	void BB_GameScene::init ()
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
		
		_gameLogicSystem = new BB_GameLogicSystem (_entityManager);
		_hudSystem = new HUDSystem (_entityManager);
		_playerControlledSystem = new PlayerControlledSystem (_entityManager);
		_gameBoardSystem = new BB_GameBoardSystem (_entityManager);
		
		
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
				"music4.mp3",
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
				"music4.mp3",
				"music2.m4a",
				"music3.m4a"
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
		
		/*create pause*/
		Entity *ps = _entityManager->createNewEntity();
		pos = _entityManager->addComponent <Position> (ps);
		pos->x = SCREEN_W - 12.0;
		pos->y = 0 + 12;
		
		sprite = _entityManager->addComponent <Sprite> (ps);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("pause.png");
		sprite->anchorPoint = vector2D_make(1.0, 0.0);
		sprite->z = -3.0;
		
		
	}
	
	

	void BB_GameScene::end ()
	{
		_entityManager->removeAllEntities();
	}

	
	void BB_GameScene::update (float delta)
	{

		//tex->updateTextureWithBufferData();
		InputDevice::sharedInstance()->update();
		if (mx3::InputDevice::sharedInstance()->touchUpReceived())
		{
			int xc = mx3::InputDevice::sharedInstance()->touchLocation().x;
			int yc = mx3::InputDevice::sharedInstance()->touchLocation().y;
			vector2D vec = vector2D_make(xc, yc);
			//printf("x: %i, y: %i\n", xc,yc);
			//pause button
			if (xc >= 282+320 && xc < 301+320 &&
				yc >= 18 && yc < 36)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_pGame->returnToMainMenu();
			}
			
			if (g_GameState.game_state == GAME_STATE_GAMEOVER ||
				g_GameState.game_state == GAME_STATE_SOLVED)
			{
				//ret to main menu
				/*if (xc >= 165+160+10 && xc < 305+160+10 &&
					yc >= 160 && yc < 195)*/
				if (point_in_entity ( vec,menu_button.btn_sprite))
				{
					mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
					g_pGame->returnToMainMenu();
					
				}
				
				//play again
//				if (xc >= 12+160-10 && xc < 155+160-10 &&
//					yc >= 160 && yc < 195)
				if (point_in_entity ( vec,replay_button.btn_sprite))
				{
					mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
					_entityManager->removeEntity(replay_button.btn_sprite->_guid);
					_entityManager->removeEntity(replay_button.btn_caption->_guid);
					
					_entityManager->removeEntity(menu_button.btn_sprite->_guid);
					_entityManager->removeEntity(menu_button.btn_caption->_guid);
					
					
					g_GameState.reset();
					game::g_pGame->resetCurrentScene ();
				}
			}
			
		}
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
				replay_button = create_button(vector2D_make(65+160-10,175), "again");
				
				menu_button = create_button(vector2D_make(255+160+10, 175), "menu", "button_right.png");
				
			}

			if (g_GameState.game_state == GAME_STATE_SOLVED)
			{
				SoundSystem::make_new_sound (SFX_SOLVED);
				//_hudSystem->set_prep_text ("Game Over!");
				_hudSystem->change_prep_state (PREP_STATE_SOLVED);
//				_hudSystem->show_prep_label();
				
				saveHiScore();
				
				post_notification(kShowGameOverView);
				replay_button = create_button(vector2D_make(65+160-10,175), "again");				
				menu_button = create_button(vector2D_make(255+160+10, 175), "menu", "button_right.png");

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
		
		
		//TODO: implement lateUpdate(dt) for systems that need to be updated after all other
		_particleSystem->update(delta);
	}

	void BB_GameScene::render ()
	{
		
		_renderSystem->render();

	}

	void BB_GameScene::frameDone ()
	{
		_entityManager->setIsDirty (false);
	}
	
	BB_GameScene::~BB_GameScene()
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
	
	void BB_GameScene::saveHiScore ()
	{
#ifdef USE_GAMECENTER
		NSString *strs[] = 
		{
			NULL,
			@"com.minyxgames.marblemayhem.timed",
			NULL,
			@"com.minyxgames.marblemayhem.puzzle",
			NULL
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