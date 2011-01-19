/*
 *  MenuScene.mm
 *  Fruitmunch
 *
 *  Created by jrk on 3/12/10.
 *  Copyright 2010 flux forge. All rights reserved.
 *
 */

#include "MenuScene.h"
#import "SimpleAudioEngine.h"
#import "SoundSystem.h"
#include "InputDevice.h"
#include "Game.h"

namespace game
{
	
	void MenuScene::preload ()
	{
		
	}
	
	mx3::Entity *MenuScene::create_button (vector2D pos, const char *text)
	{
		Entity *ent = _entityManager->createNewEntity();

		Position *posi = _entityManager->addComponent <Position> (ent);
		posi->x = pos.x;
		posi->y = pos.y;

		Sprite *sprite = _entityManager->addComponent <Sprite> (ent);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("buy_button.png");
		sprite->anchorPoint = vector2D_make(0.5, 0.5);
		sprite->z = 4.0;


		Entity *capt = _entityManager->createNewEntity();
		
		Position *position = _entityManager->addComponent <Position> (capt);
		position->x = pos.x;
		position->y = pos.y;
		//position->scale_x = position->scale_y = 0.5;
		
		TextLabel *label = _entityManager->addComponent<TextLabel> (capt);
		label->res_handle = g_RenderableManager.acquireResource <OGLFont>("impact20.fnt");
		label->anchorPoint =  vector2D_make(0.5, 0.2);
		label->text = text;
		label->z = 6.0;
		
		
		return ent;
	}
	
	void MenuScene::init ()
	{
		mx3::SoundSystem::play_background_music("menu.m4a");

		_entityManager = new EntityManager;
		_renderSystem = new RenderSystem (_entityManager);
		_starSystem = new StarSystem (_entityManager);
		
		/* create background */	
		Entity *bg = _entityManager->createNewEntity();
		Position *pos = _entityManager->addComponent <Position> (bg);
		Sprite *sprite = _entityManager->addComponent <Sprite> (bg);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("menu_back_2.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -5.0;

		Entity *logo = _entityManager->createNewEntity();
		pos = _entityManager->addComponent <Position> (logo);
		pos->x = SCREEN_W/2;
		pos->y = SCREEN_H-10;
		
		sprite = _entityManager->addComponent <Sprite> (logo);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("logo.png");
		sprite->anchorPoint = vector2D_make(0.5, 1.0);
		sprite->z = 3.0;
		
		int i = 1;
		create_button (vector2D_make(SCREEN_W/2, SCREEN_H-80 - i * 60), "Timed");

		i = 2;
		create_button (vector2D_make(SCREEN_W/2, SCREEN_H-80 - i * 60), "Endless");

		i = 3;
		create_button (vector2D_make(SCREEN_W/2, SCREEN_H-80 - i * 60), "Puzzle");

		i = 5;
		create_button (vector2D_make(SCREEN_W/2, SCREEN_H-100 - i * 50), "Sound");
		i = 6;
		create_button (vector2D_make(SCREEN_W/2, SCREEN_H-100 - i * 50), "Music");
	
	}
	
	void MenuScene::end ()
	{
		_entityManager->removeAllEntities();
	}
	
	void MenuScene::update (float delta)
	{
		mx3::InputDevice::sharedInstance()->update();
		
		if (mx3::InputDevice::sharedInstance()->touchUpReceived())
		{
			 int xc = mx3::InputDevice::sharedInstance()->touchLocation().x;
			 int yc = mx3::InputDevice::sharedInstance()->touchLocation().y;

			printf("%i, %i\n",xc,yc);
			
			if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 325 && yc <= 358)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_TIMED;
				g_pGame->startNewGame();
			}
			if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 267 && yc <= 298)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_ENDLESS;
				g_pGame->startNewGame();
			}
		
			if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 200 && yc <= 235)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_SWEEP;
				g_pGame->startNewGame();
			}

			//sfx
			if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 115 && yc <= 148)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
	
				if (SoundSystem::sfx_vol <= 0.0)
					mx3::SoundSystem::set_sfx_volume (0.9);	
				else
					mx3::SoundSystem::set_sfx_volume (0.0);	
				
				NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
				[defs setFloat: (SoundSystem::sfx_vol) forKey: @"sfx_volume"];
				[defs synchronize];
			}
			
			//mfx
			if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 61 && yc <= 97)
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);

				if (SoundSystem::music_vol <= 0.0)
					mx3::SoundSystem::set_music_volume (0.5);	
				else
					mx3::SoundSystem::set_music_volume (0.0);	
				
				NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
				[defs setFloat: (SoundSystem::music_vol) forKey: @"music_volume"];
				[defs synchronize];
			}
			
		 
		}
				
		
		_starSystem->update(delta);
	}
	
	void MenuScene::render ()
	{
		_renderSystem->render();
	}
	
	void MenuScene::frameDone ()
	{
		_entityManager->setIsDirty (false);
	}
	void MenuScene::reset ()
	{
		
	}
	MenuScene::~MenuScene()
	{
		delete _starSystem;
		delete _renderSystem;
		
		delete _entityManager;
	}
}