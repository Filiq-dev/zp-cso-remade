// all shit things

// Prevent spectators' nightvision from being turned off when switching targets, etc.
public message_nvgtoggle()
{
	return PLUGIN_HANDLED;
}

// Set correct model on player corpses
public message_clcorpse()
{
	set_msg_arg_string(1, g_playermodel[get_msg_arg_int(12)])
}

// Prevent zombies from seeing any weapon pickup icon
public message_weappickup(msg_id, msg_dest, msg_entity)
{
	if (GetBit(g_zombie, msg_entity))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Prevent zombies from seeing any ammo pickup icon
public message_ammopickup(msg_id, msg_dest, msg_entity)
{
	if (GetBit(g_zombie, msg_entity))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block hostage HUD display
public message_scenario()
{
	if (get_msg_args() > 1)
	{
		static sprite[8]
		get_msg_arg_string(2, sprite, charsmax(sprite))
		
		if (equal(sprite, "hostage"))
			return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block hostages from appearing on radar
public message_hostagepos()
{
	return PLUGIN_HANDLED;
}

// Block some text messages
public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Game restarting, reset scores and call round end to balance the teams
	if (equal(textmsg, "#Game_will_restart_in"))
	{
		logevent_round_end()
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Game commencing, reset scores only (round end is automatically triggered)
	else if (equal(textmsg, "#Game_Commencing"))
	{
		g_gamecommencing = true
		g_scorehumans = 0
		g_scorezombies = 0
	}
	// Block round end related messages
	else if (equal(textmsg, "#Hostages_Not_Rescued") || equal(textmsg, "#Round_Draw") || equal(textmsg, "#Terrorists_Win") || equal(textmsg, "#CTs_Win"))
	{
		return PLUGIN_HANDLED;
	}
	
	return PLUGIN_CONTINUE;
}

// Block CS round win audio messages, since we're playing our own instead
public message_sendaudio()
{
	static audio[17]
	get_msg_arg_string(2, audio, charsmax(audio))
	
	if(equal(audio[7], "terwin") || equal(audio[7], "ctwin") || equal(audio[7], "rounddraw"))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Send actual team scores (T = zombies // CT = humans)
public message_teamscore()
{
	static team[2]
	get_msg_arg_string(1, team, charsmax(team))
	
	switch (team[0])
	{
		// CT
		case 'C': set_msg_arg_int(2, get_msg_argtype(2), g_scorehumans)
		// Terrorist
		case 'T': set_msg_arg_int(2, get_msg_argtype(2), g_scorezombies)
	}
}

// Fix for the HL engine bug when HP is multiples of 256
public message_health(msg_id, msg_dest, msg_entity)
{
	// Get player's health
	static health
	health = get_msg_arg_int(1)
	
	// Don't bother
	if (health < 256) return;
	
	// Check if we need to fix it
	if (health % 256 == 0)
		fm_set_user_health(msg_entity, pev(msg_entity, pev_health) + 1)
	
	// HUD can only show as much as 255 hp
	set_msg_arg_int(1, get_msg_argtype(1), 255)
}

// Block flashlight battery messages if custom flashlight is enabled instead
public message_flashbat()
{
	if (g_cached_customflash)
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Current Weapon info
public message_cur_weapon(msg_id, msg_dest, msg_entity)
{
	// Not alive or zombie
	if (!GetBit(g_isalive, msg_entity) || GetBit(g_zombie, msg_entity))
		return;
	
	// Not an active weapon
	if (get_msg_arg_int(1) != 1)
		return;
	
	// Unlimited clip disabled for class
	if (GetBit(g_survivor, msg_entity) ? get_pcvar_num(cvar_survinfammo) <= 1 : get_pcvar_num(cvar_infammo) <= 1)
		return;
	
	// Get weapon's id
	static weapon
	weapon = get_msg_arg_int(2)
	
	// Unlimited Clip Ammo for this weapon?
	if (MAXBPAMMO[weapon] > 2)
	{
		// Max out clip ammo
		static weapon_ent
		weapon_ent = fm_cs_get_current_weapon_ent(msg_entity)
		if (pev_valid(weapon_ent)) cs_set_weapon_ammo(weapon_ent, MAXCLIP[weapon])
		
		// HUD should show full clip all the time
		set_msg_arg_int(3, get_msg_argtype(3), MAXCLIP[weapon])
	}
}

// Flashbangs should only affect zombies
public message_screenfade(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(4) != 255 || get_msg_arg_int(5) != 255 || get_msg_arg_int(6) != 255 || get_msg_arg_int(7) < 200)
		return PLUGIN_CONTINUE;
	
	// Nemesis shouldn't be FBed
	if (GetBit(g_zombie, msg_entity) && !GetBit(g_nemesis, msg_entity))
	{
		// Set flash color to nighvision's
		set_msg_arg_int(4, get_msg_argtype(4), get_pcvar_num(cvar_nvgcolor[0]))
		set_msg_arg_int(5, get_msg_argtype(5), get_pcvar_num(cvar_nvgcolor[1]))
		set_msg_arg_int(6, get_msg_argtype(6), get_pcvar_num(cvar_nvgcolor[2]))
		return PLUGIN_CONTINUE;
	}
	
	return PLUGIN_HANDLED;
}

// Weapon Drop
public clcmd_drop(id)
{
	// Survivor should stick with its weapon
	if (GetBit(g_survivor, id))
		return PLUGIN_HANDLED;
	
	return PLUGIN_CONTINUE;
}

// Block Team Change
public clcmd_changeteam(id)
{
	static team
	team = fm_cs_get_user_team(id)
	
	// Unless it's a spectator joining the game
	if (team == FM_CS_TEAM_SPECTATOR || team == FM_CS_TEAM_UNASSIGNED)
		return PLUGIN_CONTINUE;
	
	// Pressing 'M' (chooseteam) ingame should show the main menu instead
	show_menu_game(id)
	return PLUGIN_HANDLED;
}

// Forward Get Game Description
public fw_GetGameDescription()
{
	// Return the mod name so it can be easily identified
	forward_return(FMV_STRING, "Zombie Plague [CSO]")
	
	return FMRES_SUPERCEDE;
}

// Forward Set ClientKey Value -prevent CS from changing player models-
public fw_SetClientKeyValue(id, const infobuffer[], const key[])
{
	// Block CS model changes
	if (key[0] == 'm' && key[1] == 'o' && key[2] == 'd' && key[3] == 'e' && key[4] == 'l')
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Client left
public fw_ClientDisconnect_Post()
{
	// Last Zombie Check
	fnCheckLastZombie()
}

// Client Kill Forward
public fw_ClientKill()
{
	// Prevent players from killing themselves?
	return FMRES_SUPERCEDE;
}

// WeaponMod bugfix
//forward wpn_gi_reset_weapon(id);
public wpn_gi_reset_weapon(id)
{
	// Replace knife model
	replace_weapon_models(id, CSW_KNIFE)
}

// Ham Use Pushable Forward
public fw_UsePushable()
{
	return HAM_SUPERCEDE;
}

// Ham Use Stationary Gun Forward
public fw_UseStationary(entity, caller, activator, use_type)
{
	// Prevent zombies from using stationary guns
	if (use_type == USE_USING && is_user_valid_connected(caller) && GetBit(g_zombie, caller))
		return HAM_SUPERCEDE;
	
	return HAM_IGNORED;
}

// Ham Use Stationary Gun Post Forward
public fw_UseStationary_Post(entity, caller, activator, use_type)
{
	// Someone stopped using a stationary gun
	if (use_type == USE_STOPPED && is_user_valid_connected(caller))
		replace_weapon_models(caller, g_currentweapon[caller]) // replace weapon models (bugfix)
}

// Ham Reset MaxSpeed Post Forward
public fw_ResetMaxSpeed_Post(id)
{
	// Freezetime active or player not alive
	if (g_freezetime || !GetBit(g_isalive, id))
		return;
	
	set_player_maxspeed(id)
}

// Sound Precache Forward
public fw_PrecacheSound(const sound[])
{
	// Block all those unneeeded hostage sounds
	if (equal(sound, "hostage", 7))
		return FMRES_SUPERCEDE;
	
	return FMRES_IGNORED;
}

// Entity Spawn Forward
public fw_Spawn(entity)
{
	// Invalid entity
	if (!pev_valid(entity)) return FMRES_IGNORED;
	
	// Get classname
	static 
		classname[32],
		objective[][] = {
			"func_bomb_target", 
			"info_bomb_target", 
			"info_vip_start", 
			"func_vip_safetyzone", 
			"func_escapezone", 
			"hostage_entity", 
			"monster_scientist", 
			"func_hostage_rescue", 
			"info_hostage_rescue", 
			"env_fog", 
			"env_rain", 
			"env_snow", 
			"item_longjump", 
			"func_vehicle"
		}

	pev(entity, pev_classname, classname, charsmax(classname))
	
	// Check whether it needs to be removed
	for (new i = 0; i < sizeof(objective); i++)
	{
		if (equal(classname, objective[i]))
		{
			engfunc(EngFunc_RemoveEntity, entity)
			return FMRES_SUPERCEDE;
		}
	}
	
	return FMRES_IGNORED;
}

// Register Ham Forwards for CZ bots
public register_ham_czbots(id)
{
	// Make sure it's a CZ bot and it's still connected
	if (g_hamczbots || !GetBit(g_isconnected, id) || !get_pcvar_num(cvar_botquota))
		return;
	
	RegisterHamFromEntity(Ham_Spawn, id, "fw_PlayerSpawn_Post", 1)
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled")
	RegisterHamFromEntity(Ham_Killed, id, "fw_PlayerKilled_Post", 1)
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage")
	RegisterHamFromEntity(Ham_TakeDamage, id, "fw_TakeDamage_Post", 1)
	RegisterHamFromEntity(Ham_TraceAttack, id, "fw_TraceAttack")
	RegisterHamFromEntity(Ham_Player_ResetMaxSpeed, id, "fw_ResetMaxSpeed_Post", 1)
	
	// Ham forwards for CZ bots succesfully registered
	g_hamczbots = true
	
	// If the bot has already spawned, call the forward manually for him
	if (is_user_alive(id)) fw_PlayerSpawn_Post(id)
}

// Disable minmodels task
public disable_minmodels(id)
{
	if (!GetBit(g_isconnected, id)) return;
	client_cmd(id, "cl_minmodels 0")
}

// Bots automatically buy extra items
public bot_buy_extras(taskid)
{
	// Nemesis or Survivor bots have nothing to buy by default
	if (!GetBit(g_isalive, ID_SPAWN) || GetBit(g_survivor, ID_SPAWN) || GetBit(g_nemesis, ID_SPAWN))
		return;
	
	if (!GetBit(g_zombie, ID_SPAWN)) // human bots
	{
		// Attempt to buy Night Vision
		buy_extra_item(ID_SPAWN, EXTRA_NVISION)
		
		// Attempt to buy a weapon
		buy_extra_item(ID_SPAWN, random_num(EXTRA_WEAPONS_STARTID, (EXTRA_WEAPONS_STARTID + ArraySize(g_extraweapon_names))-1))
	}
	else // zombie bots
	{
		// Attempt to buy an Antidote
		buy_extra_item(ID_SPAWN, EXTRA_ANTIDOTE)
	}
}

// Refill BP Ammo Task
public refill_bpammo(const args[], id)
{
	// Player died or turned into a zombie
	if (!GetBit(g_isalive, id) || GetBit(g_zombie, id))
		return;
	
	set_msg_block(g_msgAmmoPickup, BLOCK_ONCE)
	ExecuteHamB(Ham_GiveAmmo, id, MAXBPAMMO[args[0]], AMMOTYPE[args[0]], MAXBPAMMO[args[0]])
}

// Remove Stuff Task
public remove_stuff()
{
	static ent
	
	// Triggered lights
	if (!get_pcvar_num(cvar_triggered))
	{
		ent = -1
		while ((ent = engfunc(EngFunc_FindEntityByString, ent, "classname", "light")) != 0)
		{
			dllfunc(DLLFunc_Use, ent, 0); // turn off the light
			set_pev(ent, pev_targetname, 0) // prevent it from being triggered
		}
	}
}