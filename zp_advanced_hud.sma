// Andrei for score hud
// stats hud from zp4.0
// level hud from zpbuymenu

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dhudmessage>
#include <zombieplague>
#include <zp_cso_custom>

#define PLUGIN "[ZP] Advanced HUD"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

#define HUD_SPECT_X 0.6
#define HUD_SPECT_Y 0.8
#define HUD_STATS_X 0.02
#define HUD_STATS_Y 0.9

#define HUD_LEVEL_X -1.0
#define HUD_LEVEL_Y 0.9

enum _: eTeamData
{
	WIN_NO_ONE = 0,
	WIN_ZOMBIES,
	WIN_HUMANS	

}

new 
	g_iWin[eTeamData], bool:roundStarted = false,
	bool:hudScore[33], bool:hudStats[33], bool:hudLevel[33],
	bool:hudMessages[33],
	Array:g_Messages, syncMsg, messageExist, timer = 0

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_message(get_user_msgid("TextMsg"), "Message_TextMsg")

	register_clcmd("say /hud", "hudMenu")
}

public plugin_precache()
{
	g_Messages = ArrayCreate(512)
	syncMsg = CreateHudSyncObj()

	new confdir[64], path[128]

	get_configsdir(confdir, charsmax(confdir))
	formatex(path, charsmax(path), "%s/hud_messages.ini", confdir)

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

public plugin_natives()
{
	register_native("show_hud_menu", "hudMenu", 1)
}

public Message_TextMsg() 
{
	static szMessages[32];
	get_msg_arg_string(2, szMessages, charsmax(szMessages))
	
	if(equal(szMessages, "#Game_will_restart_in"))
	{
		g_iWin[ WIN_HUMANS ] = 0
		g_iWin[ WIN_ZOMBIES ] = 0
		g_iWin[ WIN_NO_ONE ] = 0
	} 
}

public client_putinserver(id)
{
	hudScore[id] = true
	hudStats[id] = true
	hudLevel[id] = true
	hudMessages[id] = true

	if(!is_user_bot(id)) 
		set_task(1.0, "ShowHUD", id , _, _, "b")
}

public client_disconnect(id)
{
	remove_task(id)
}

public zp_round_started() {
	roundStarted = true
}

public zp_round_ended(iWinTeam)
{
	switch(iWinTeam)
	{
		case WIN_HUMANS: g_iWin[WIN_HUMANS]++;
		case WIN_ZOMBIES: g_iWin[WIN_ZOMBIES]++;
		default: g_iWin[WIN_NO_ONE]++;
	}

	roundStarted = false
}

public hudMenu(id)
{
	new string[50],
		menu = menu_create("Hud Menu | Zombie-Plague \w[\rCSO\w]", "hudMenuHandler")

	formatex(string, 30, "Score [\y%s\w]", hudScore[id] ? "hide" : "show")
	menu_additem(menu, string)

	formatex(string, 30, "Stats [\y%s\w]", hudStats[id] ? "hide" : "show")
	menu_additem(menu, string)

	formatex(string, 30, "Level [\y%s\w]", hudLevel[id] ? "hide" : "show")
	menu_additem(menu, string)

	formatex(string, 30, "Messages [\y%s\w]", hudMessages[id] ? "hide" : "show")
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


	if(roundStarted == true) {
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

	set_dhudmessage(245, 255, 250, spec == id ? HUD_STATS_X : HUD_SPECT_X, spec == id ? HUD_STATS_Y : HUD_SPECT_Y, 0, 6.00, 1.10, 0.00, 0.00, false);
	show_dhudmessage(id, "[HP: %d] [Class: %s]", pev(spec == id ? id : spec, pev_health), getClass(spec == id ? id : spec))
}

public showLevel(id, spec)
{
	if(!hudLevel[id])
		return

	set_dhudmessage(0, 255, 0, HUD_LEVEL_X, HUD_LEVEL_Y, 0, 6.00, 1.10, 0.00, 0.00, false);
	show_dhudmessage(id, "[LVL: %d | EXP: %d/%d]", zp_get_user_level(spec == id ? id : spec), zp_get_user_exp(spec == id ? id : spec), zp_get_exp_current(spec == id ? id : spec))
}

public showScore(id)
{
	if(!hudScore[id]) 
		return
	
	set_dhudmessage(.red = 0, .green = 255, .blue = 0, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0, .reliable = false ); 
	show_dhudmessage(0, "Humans %d                        ", zp_get_human_count() );
	
	set_dhudmessage(.red = 100, .green = 100, .blue = 100, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0, .reliable = false ); 
	show_dhudmessage(0, "[ %d ]^n%d Wins %d", ( g_iWin[ WIN_HUMANS ] +  g_iWin[ WIN_ZOMBIES ] + g_iWin[ WIN_NO_ONE ] ), g_iWin[ WIN_HUMANS ],  g_iWin[ WIN_ZOMBIES ] );
	
	set_dhudmessage(.red = 255, .green = 0, .blue = 0, .x = -1.0, .y = 0.02, .effects = 0, .fxtime = 6.0, .holdtime = 2.0, .fadeintime = 1.0, .fadeouttime = 1.0, .reliable = false ); 
	show_dhudmessage(0, "                         %d Zombies", zp_get_zombie_count());
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

public getClass(id)
{
	static class[32]
	
	if (zp_get_user_zombie(id)) // zombies
	{
		if (zp_get_user_nemesis(id))
			formatex(class, charsmax(class), "Boss")
		else {
			zp_get_class_name(id, class , charsmax(class))
		}
	}
	else // humans
	{
		if (zp_get_user_survivor(id))
			formatex(class, charsmax(class), "Survivor")
		else
			formatex(class, charsmax(class), "Human")
	}

	return class
}