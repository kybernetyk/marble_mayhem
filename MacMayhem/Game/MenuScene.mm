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

extern bool point_in_entity (mx3::vector2D vec, Entity *e);

namespace game
{
	
	void MenuScene::preload ()
	{
		
	}
	
	mx3::Entity *MenuScene::create_button (vector2D pos, const char *text, const char *btn_graphic)
	{
		Entity *ent = _entityManager->createNewEntity();

		Position *posi = _entityManager->addComponent <Position> (ent);
		posi->x = pos.x;
		posi->y = pos.y;

		Sprite *sprite = _entityManager->addComponent <Sprite> (ent);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> (btn_graphic);
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
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("game_back.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = -5.0;

		/* logo */
		Entity *logo = _entityManager->createNewEntity();
		pos = _entityManager->addComponent <Position> (logo);
		pos->x = 20;
		pos->y = SCREEN_H-10;
		
		sprite = _entityManager->addComponent <Sprite> (logo);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("logo.png");
		sprite->anchorPoint = vector2D_make(0.0, 1.0);
		sprite->z = 3.0;
		
		/* menu */
		int i = 1;
		int stride = 70;
		int ypos = SCREEN_H-80;
		int xpos = SCREEN_W - 220;
		
		btn_classic = create_button (vector2D_make(xpos+40, ypos - i * stride), "Classic");
		i = 2;
		btn_timed = create_button (vector2D_make(xpos+60, ypos - i * stride), "Timed");
		i = 3;
		btn_endless = create_button (vector2D_make(xpos+80, ypos - i * stride), "Endless");
		i = 4;
		btn_sound = create_button (vector2D_make(xpos+60, ypos - i * stride), "Sound");
		i = 5;
		btn_music = create_button (vector2D_make(xpos+40, ypos - i * stride), "Music");
		
		/* minyx fert */
		/* logo */
		Entity *minyx = _entityManager->createNewEntity();
		pos = _entityManager->addComponent <Position> (minyx);
		pos->x = 200;
		pos->y = 0;
		pos->scale_x = -1.0;
		
		sprite = _entityManager->addComponent <Sprite> (minyx);
		sprite->res_handle = g_RenderableManager.acquireResource <TexturedQuad> ("minyx_bw.png");
		sprite->anchorPoint = vector2D_make(0.0, 0.0);
		sprite->z = 3.0;
		
	
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
			vector2D vec = vector2D_make(xc,yc);
			printf("%i, %i\n",xc,yc);
			
			/*if (xc >= 88+160 && xc <= 230+160 &&
				yc >= 325 && yc <= 358)*/
			if (point_in_entity(vec, btn_timed))
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_TIMED;
				g_pGame->startNewGame();
			}
//			if (xc >= 88+160 && xc <= 230+160 &&
			//				yc >= 267 && yc <= 298)
			if (point_in_entity(vec, btn_endless))
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_ENDLESS;
				g_pGame->startNewGame();
			}
		
//			if (xc >= 88+160 && xc <= 230+160 &&
//				yc >= 200 && yc <= 235)
			if (point_in_entity(vec, btn_classic))
			{
				mx3::SoundSystem::play_sound (MENU_ITEM_SFX);
				g_GameState.game_mode = GAME_MODE_BB;
				g_pGame->startNewGame();
			}

			//sfx
//			if (xc >= 88+160 && xc <= 230+160 &&
//				yc >= 115 && yc <= 148)
			if (point_in_entity(vec, btn_sound))
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
//			if (xc >= 88+160 && xc <= 230+160 &&
//				yc >= 61 && yc <= 97)
			if (point_in_entity(vec, btn_music))
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