#include <amxmodx>
#include <cstrike>
#include <zp_cso_custom>
#include <colorchat>
#include <zombieplague>

#define PLUGIN "[CSO] Respawn Menu"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

new human_cost, zombie_cost

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	human_cost = register_cvar("zp_respawn_human", "5000")
	zombie_cost = register_cvar("zp_respawn_zombie", "3000")
	
	register_clcmd("say /respawn", "showRespawnMenu")
}	

public plugin_natives()
{
	register_native("show_respawn_menu", "showRespawnMenu")
}

public showRespawnMenu(id)
{
	if(verification(id) != PLUGIN_CONTINUE)
		return PLUGIN_HANDLED

	new 
		string[40],
		menu = menu_create("Respawn Menu | Zombie-Plague \w[\rCSO\w]", "respawnMenuHandler")

	formatex(string, charsmax(string), "Respawn as \yZombie \r%d$", get_pcvar_num(zombie_cost))
	menu_additem(menu, string)

	formatex(string, charsmax(string), "Respawn as \yHuman \r%d$", get_pcvar_num(human_cost))
	menu_additem(menu, string)
	
	menu_display (id, menu)

	return PLUGIN_CONTINUE
}

public respawnMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	if(verification(id) != PLUGIN_CONTINUE)
		return PLUGIN_HANDLED

	ColorChat(id, RED, "[^4CSO^3] ^4%s ^3has just respawned at ^4%s^3.", getName(id), item ? "Human" : "Zombie")

	if(cs_get_user_team(id) == CS_TEAM_SPECTATOR) 
		cs_set_user_team(id, CS_TEAM_CT)

	zp_respawn_user(id, item ? ZP_TEAM_HUMAN : ZP_TEAM_ZOMBIE)
	zp_set_user_money(id, zp_get_user_money(id) - item ? 3000 : 6000)

	return PLUGIN_CONTINUE
}

public verification(id)
{
	if(is_user_alive(id))
	{
		ColorChat(id, RED, "[^4CSO^3] Only ^4Dead people ^3can purchase respawn")
		return PLUGIN_HANDLED
	}

	if(zp_is_survivor_round() && !is_user_alive(id))
	{
		ColorChat(id, RED, "[^4CSO^3] Only ^4zombie ^3can respawn")
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}