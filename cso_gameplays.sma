#include <amxmodx>
#include <zp_cso_custom>
#include <fakemeta>

#define PLUGIN "[CSO] Special Gameplays"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

#define SECOUNDS_TO_CHOOSE 20.0 // pana sa aleaga 

new 
	loadinData = 0,
	bool:bugFix = false,
	dataLoaded,
	syncMsg,
	votes[4],
	bool:hasVoted[33] = false,
	menu,
	gameplay

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

	dataLoaded = CreateMultiForward("cso_data_loaded", ET_IGNORE)

	syncMsg = CreateHudSyncObj()
}

public plugin_natives()
{
	register_native("cso_gameplay_active", "native_cso_gameplay_active")
}

public client_putinserver(id)
{
	hasVoted[id] = false
}

public event_round_start()
{
	if(loadinData != -1) {
		loadinData++
		gameplay = -1
		
		set_task(SECOUNDS_TO_CHOOSE, "loadData")
		make_ScreenFade(0, SECOUNDS_TO_CHOOSE, 0, 0, 0, 255);

		showChoiceMenu()

		if(loadinData == 1)
			loadinData = -1
	}

	if(bugFix)
	{
		new result
		ExecuteForward(dataLoaded, result)
	}
}

public showChoiceMenu()
{
	static num, players[32], str[50]
	get_players(players, num)

	menu = menu_create("Vote gameplay for current map | Zombie-Plague \w[\rCSO\w]", "choiceMenuHandler")

	formatex(str, charsmax(str), "Infinite ammo [\r%d Votes\w]", votes[ginfinite])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "No level in buy menu [\r%d Votes\w]", votes[glevel])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "x3 Money [\r%d Votes\w]", votes[gmoney])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "x10 XP [\r%d Votes\w]", votes[gxp])
	menu_additem(menu, str)

	menu_addtext(menu, "^n^n^nPlease select what gameplay do you want to play on server.")
	menu_addtext2(menu, "Be aware, your decision affects the entire game")

	for(new i = 0; i < num; i++)
	{
		if(is_user_connected(players[i]) && !is_user_bot(players[i])) 
		{
			menu_display(players[i], menu)
		}
	}
}

public choiceMenuHandler(id, menu2, item)
{
	if(item == MENU_EXIT || hasVoted[id])
	{
		menu_destroy(menu2)
		return PLUGIN_HANDLED
	}
	
	votes[item] ++
	hasVoted[id] = true

	client_print_color(0, id, "^4[CSO] %s ^1has voted ^4%s^1.", getName(id), getChoiceName(item))
	showChoiceMenu()

	return PLUGIN_CONTINUE
}

public loadData()
{
	new result
	ExecuteForward(dataLoaded, result)

	for(new i = 0; i < sizeof(votes); i++)
		for(new j = 0; j < sizeof(votes); j++)
			if(votes[i] > votes[j])
				gameplay = i

	client_print_color(0, 0, "^4[CSO] ^1This map we will playing ^4%s^1.", getChoiceName(gameplay))
	
	menu_destroy(menu)

	bugFix = true
}

public native_cso_gameplay_active()
{
	return gameplay
}

stock getChoiceName(item)
{
	new str[30]
	switch(item)
	{
		case ginfinite: str = "with Infinite ammo"
		case glevel: str = "No level at buy"
		case gmoney: str = "x3 Money"
		case gxp: str = "x10 XP"
	}

	return str
}

// https://forums.alliedmods.net/showpost.php?p=640772&postcount=2
public make_ScreenFade(id, Float:fDuration, red, green, blue, alpha)
{
	new i = id ? id : get_player();
	if(!i)
	{
		return false
	}

	set_hudmessage(random_num(0, 255), random_num(0, 255), random_num(0, 255), -1.0, 0.50, random_num(0, 2), random_float(0.7, 0.9), 12.0, random_float(0.37, 0.4), random_float(0.37, 0.4), 4)
	ShowSyncHudMsg(id, syncMsg, "             Your data is loading!^nPlease select what gameplay do you want to play this map")
	
	message_begin(id ? MSG_ONE : MSG_ALL, get_user_msgid("ScreenFade"), {0, 0, 0}, id)
	write_short(floatround(4096.0 * fDuration, floatround_round))
	write_short(floatround(4096.0 * fDuration, floatround_round))
	write_short(4096)
	write_byte(red)
	write_byte(green)
	write_byte(blue)
	write_byte(alpha)
	message_end()
	
	return true
}

public get_player()
{
	new num, players[32]
		
	get_players(players, num)
	for(new i = 0; i < num; i++)
	{
		if(!is_user_connected(players[i]))
			continue
		
		return players[i]
		
	}
	
	return 0
}