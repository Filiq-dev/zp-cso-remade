#if defined notused
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zp_cso_custom>
#endif

// Andrei for score hud
// stats hud from zp4.0
// level hud from zpbuymenu

#define HUD_SPECT_X 0.6
#define HUD_SPECT_Y 0.8
#define HUD_STATS_X 0.02
#define HUD_STATS_Y 0.9

#define HUD_LEVEL_X -1.0
#define HUD_LEVEL_Y 0.9

static 
	bool:hudScore[33], bool:hudStats[33], bool:hudLevel[33],
	bool:hudMessages[33], bool:hudDamage[33], bool:hudcInfo[33],
	Array:g_Messages, syncMsg, messageExist, timer = 0

public hud_natives()
{
	register_native("hud_get_zinfo", "native_hud_get_zinfo", 1)
}

public hud_precache()
{
	g_Messages = ArrayCreate(512)
	syncMsg = CreateHudSyncObj()

	new confdir[64], path[128]

	get_configsdir(confdir, charsmax(confdir))
	formatex(path, charsmax(path), "%s/cso/hud_messages.ini", confdir)

	new a = fopen(path, "rt")
	if(a)
	{
		new Line[512]

		while (!feof(a))
		{
			fgets(a, Line, sizeof(Line) - 1);
			trim(Line);

			if (Line[0])
			{
				while(replace(Line, sizeof(Line)-1, "\n", "^n")){}

				ArrayPushString(g_Messages, Line);
			}
		}

		fclose(a);
	} 
	else 
		log_amx("Failed to open hud_messages.ini file!");

	messageExist = ArraySize(g_Messages)
}

public hud_init()
{
	register_event("Damage", "showDamage", "b", "2!0", "3=0", "4!0")	

	register_clcmd("say /hud", "hudMenu")
}

public show_hud_after_load()
{
	new num, players[32]
		
	get_players(players, num)
	for(new i = 0; i < num; i++)
	{
		if(is_user_bot(players[i]))
			continue
		
		set_task(1.0, "ShowHUD", players[i] , _, _, "b")
		
	}
}

public hud_putinserver(id)
{
	hudScore[id] = true
	hudStats[id] = true
	hudLevel[id] = true
	hudMessages[id] = true
	hudDamage[id] = false
	hudcInfo[id] = true
}

public hud_disconnected(id)
{
	remove_task(id)
}

public hudMenu(id)
{
	new string[50],
		menu = menu_create("Hud Menu | Zombie-Plague \w[\rCSO\w]", "hudMenuHandler")

	formatex(string, 30, "Score [%s\w]", hudScore[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	formatex(string, 30, "Stats [%s\w]", hudStats[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	formatex(string, 30, "Level [%s\w]", hudLevel[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	formatex(string, 30, "Messages [%s\w]", hudMessages[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	formatex(string, 30, "Damage [%s\w]", hudDamage[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	formatex(string, 30, "Ability [%s\w]", hudcInfo[id] ? "\rhide" : "\yshow")
	menu_additem(menu, string)

	menu_display (id, menu)

	return PLUGIN_HANDLED_MAIN;
}

public hudMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	switch(item)
	{
		case 0: hudScore[id] = !hudScore[id]
		case 1: hudStats[id] = !hudStats[id]
		case 2: hudLevel[id] = !hudLevel[id]
		case 3: hudMessages[id] = !hudMessages[id]
		case 4: hudDamage[id] = !hudDamage[id]
		case 5: hudcInfo[id] = !hudcInfo[id]
	}

	hudMenu(id)

	return true;
}

public ShowHUD(id)
{
	static idspec

	if (!is_user_alive(id))
	{
		idspec = pev(id, pev_iuser2)
		
		if(is_user_alive(idspec)) 
		{
			showStats(id, idspec)
			showLevel(id, idspec)
		}
	} 
	else 
	{
		showStats(id, id)
		showLevel(id, id)
	}


	if(g_modestarted) {
		showScore(id)
	}

	if(messageExist)
	{
		timer += 1
		if(timer == 60) 
		{
			timer = 0
			showMessages(id)
		}
	}
}

public showStats(id, spec)
{
	if(!hudStats[id])
		return

	set_dhudmessage(245, 255, 250, spec == id ? HUD_STATS_X : HUD_SPECT_X, spec == id ? HUD_STATS_Y : HUD_SPECT_Y, 0, 6.00, 1.10, 0.00, 0.00);
	show_dhudmessage(id, "[HP: %d] [Class: %s]", pev(spec == id ? id : spec, pev_health), getClass(spec == id ? id : spec))
}

public showLevel(id, spec)
{
	if(!hudLevel[id])
		return

	set_dhudmessage(0, 255, 0, HUD_LEVEL_X, HUD_LEVEL_Y, 0, 6.00, 1.10, 0.00, 0.00);
	show_dhudmessage(id, "[LVL: %d | EXP: %d/%d]", zp_get_user_level(spec == id ? id : spec), zp_get_user_exp(spec == id ? id : spec), zp_get_exp_current(spec == id ? id : spec))
}

public showScore(id)
{
	if(!hudScore[id]) 
		return
	
	set_dhudmessage(.red = 0, .green = 255, .blue = 0, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0); 
	show_dhudmessage(0, "Humans %d                        ", fnGetHumans());
	
	set_dhudmessage(.red = 100, .green = 100, .blue = 100, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0); 
	show_dhudmessage(0, "^n%d Wins %d", g_scorehumans,  g_scorezombies );
	
	set_dhudmessage(.red = 255, .green = 0, .blue = 0, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0); 
	show_dhudmessage(0, "                         %d Zombies", fnGetZombies());
}

public showMessages(id)
{
	if(!hudMessages[id])
		return 

	static msg[512]

	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.0777, random_num(0, 2), random_float(0.7, 0.9), 12.0, random_float(0.37, 0.4), random_float(0.37, 0.4), 4)
	ArrayGetString(g_Messages, random_num(0, ArraySize(g_Messages) - 1), msg, 511)
	ShowSyncHudMsg(id, syncMsg, msg)
}

public showDamage(id)
{ 
	static attacker; attacker = get_user_attacker(id)
	static damage; damage = read_data(2)

	if(id == attacker)
		return
	
	if(hudDamage[id])
	{
		set_hudmessage(255, 0, 0, 0.45, 0.50, 2, 0.1, 4.0, 0.1, 0.1, -1)
		ShowSyncHudMsg(id, syncMsg, "%d^n", damage)		
	}

	if(!is_user_connected(attacker) && !is_user_alive(attacker))
		return

	if(!hudDamage[attacker])
		return

	set_hudmessage(0, 100, 200, -1.0, 0.55, 2, 0.1, 4.0, 0.02, 0.02, -1)
	ShowSyncHudMsg(attacker, syncMsg, "%d^n", damage)	
}

public getClass(id)
{
	static class[32]
	
	if (GetBit(g_zombie, id)) // zombies
	{
		if (GetBit(g_nemesis, id))
			formatex(class, charsmax(class), "Boss")
		else {
            return g_zombie_classname[id]
		}
	}
	else // humans
	{
		if (GetBit(g_survivor, id))
			formatex(class, charsmax(class), "Survivor")
		else
			formatex(class, charsmax(class), "Human")
	}

	return class
}

public native_hud_get_zinfo(id)
{
	return hudcInfo[id]
}