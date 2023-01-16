#include <amxmodx>
#include <zp_cso_custom>
#include <fakemeta>

#define PLUGIN "[CSO] Special Gameplays"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

#define SECOUNDS_TO_CHOOSE 10.0 // pana sa aleaga 

enum 
{
	infinite,
	level,
	money,
	xp
}

new 
	loadinData = 0,
	bool:bugFix = false,
	dataLoaded,
	syncMsg,
	votes[4],
	bool:hasVoted[33] = false    
public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
	register_logevent("logevent_round_end", 2, "1=Round_End")

	dataLoaded = CreateMultiForward("cso_data_loaded", ET_IGNORE)

	syncMsg = CreateHudSyncObj()

	
}

public client_putinserver(id)
{
	hasVoted[id] = false
}

public event_round_start()
{
	if(loadinData != -1) {
		loadinData++
		
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

public logevent_round_end()
{

}

public showChoiceMenu()
{
	new menu = menu_create("Vote gameplay for current map | Zombie-Plague \w[\rCSO\w]", "choiceMenuHandler")

	static num, players[32], str[50]
	get_players(players, num)
	
	formatex(str, charsmax(str), "Infinite ammo [%d Votes]", votes[infinite])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "No level in buy menu [%d Votes]", votes[level])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "x3 Money [%d Votes]", votes[money])
	menu_additem(menu, str)

	formatex(str, charsmax(str), "x10 XP [%d Votes]", votes[xp])
	menu_additem(menu, str)

	for(new i = 0; i < 33; i++)
	{
		if(is_user_connected(i) && !is_user_bot(i)) 
		{
			menu_destroy(menu)
			menu_display(i, menu)
		}
	}
}

public choiceMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		showChoiceMenu()
		return PLUGIN_HANDLED
	}

	if(hasVoted[id]) 
		return PLUGIN_HANDLED

	
	votes[item] ++
	hasVoted[id] = true

	client_print_color(0, id, "[CSO] %s want to play %s", getName(id), getChoiceName(item))
	showChoiceMenu()

	return PLUGIN_CONTINUE
}

public loadData()
{
	new result
	ExecuteForward(dataLoaded, result)

	bugFix = true
}

stock getChoiceName(item)
{
	new str[30]
	switch(item)
	{
		case infinite: str = "Infinite ammo"
		case level: str = "No level at buy"
		case money: str = "x3 Money"
		case xp: str = "x10 XP"
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