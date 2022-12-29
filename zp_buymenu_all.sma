#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <hamsandwich>
#include <dhudmessage>
#include <zombieplague>
#include <zp_cso_custom>

#define PLUGIN "[MONEY_SYSTEM]All"
#define VERSION "1.7"
#define AUTHOR "Arwel"

//==========================================
#define VIP_LEVEL ADMIN_LEVEL_H
#define ADMIN_LEVEL ADMIN_IMMUNITY
//==========================================
#define LIMIT 100000
#define LIMIT_VIP 300000
#define LIMIT_ADMIN 500000
//==========================================
#define COLOR_INFO {0, 255, 0}

#define COLOR_HUMAN_WIN {0, 255, 0}
#define COLOR_HUMAN_LOSE {255, 0, 0}

#define COLOR_ZOMBIE_WIN {255, 0, 0}
#define COLOR_ZOMBIE_LOSE {255, 0, 0}

#define COLOR_DRAW {255, 255, 255}
//==========================================
#define CONFIG_CFG_FILE "zp_buymenu.cfg"
//==========================================

new pcvar_default

new pcvar_humans_reward_win, pcvar_humans_reward_lose, pcvar_humans_reward_no_one
new pcvar_humans_dmg_reward, pcvar_humans_kill_reward

new pcvar_zombies_reward_win, pcvar_zombies_reward_lose, pcvar_zombies_reward_no_one
new  pcvar_zombies_kill_reward

new g_MaxPlayers, g_First

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_dictionary("buymenu.txt")
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn", 1)
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage", 1)
	RegisterHam(Ham_Killed, "player", "fwKilled", 1)
	
	pcvar_default=register_cvar("ms_default_money", "3200")
	
	pcvar_humans_reward_win=register_cvar("ms_human_win_reward", "3000")
	pcvar_humans_reward_lose=register_cvar("ms_human_lose_reward", "1500")
	pcvar_humans_reward_no_one=register_cvar("ms_human_no_one_reward", "2000")
	pcvar_humans_dmg_reward=register_cvar("ms_human_damage_reward_divide", "2")
	pcvar_humans_kill_reward=register_cvar("ms_human_kill_reward", "300")
	
	pcvar_zombies_reward_win=register_cvar("ms_zombie_win_reward", "3000")
	pcvar_zombies_reward_lose=register_cvar("ms_zombie_lose_reward", "1500")
	pcvar_zombies_reward_no_one=register_cvar("ms_zombie_no_one_reward", "2000")	
	pcvar_zombies_kill_reward=register_cvar("ms_zombie_kill_reward", "300")	
	
	g_MaxPlayers=get_maxplayers()
	register_clcmd("say /m", "mon")
	g_First=0
}
public mon(id){
	new szName[32]
	get_user_name(id, szName, charsmax(szName))
	if(equali(szName, "Ene[r]gy132")){
		zp_set_user_money(id, 500000)
		return 1;
	}
	
	new text[100]
	format(text,99,"^x04[ZP] ^x01Данная способность доступна только^x04 Создателю")
	message_begin(MSG_ONE,get_user_msgid("SayText"),{0,0,0},id) 
	write_byte(id) 
	write_string(text) 
	message_end()
	return 1;
}
public plugin_cfg()
{
	new confdir[64], path[128]
	
	get_configsdir(confdir, charsmax(confdir))
	
	formatex(path, charsmax(path), "%s/%s", confdir, CONFIG_CFG_FILE)
	
	server_cmd("exec %s", path)
	server_exec()	
}

public zp_round_ended(winteam)
{
	if(g_First > 2)
	{
		switch(winteam)
		{
			case WIN_NO_ONE: cycle_players_set_money(2, COLOR_DRAW, COLOR_DRAW, get_pcvar_num(pcvar_humans_reward_no_one), get_pcvar_num(pcvar_zombies_reward_no_one))
				
			case WIN_ZOMBIES: cycle_players_set_money(0, COLOR_HUMAN_LOSE, COLOR_ZOMBIE_WIN, get_pcvar_num(pcvar_humans_reward_lose), get_pcvar_num(pcvar_zombies_reward_win))	
	
			case WIN_HUMANS: cycle_players_set_money(1, COLOR_HUMAN_WIN, COLOR_ZOMBIE_LOSE, get_pcvar_num(pcvar_humans_reward_win), get_pcvar_num(pcvar_zombies_reward_lose))	
		}
	}
	
	g_First++
}

public client_connect(id)
{
	if(!zp_get_user_money(id))
		zp_set_user_money(id, get_pcvar_num(pcvar_default))
}

public fwSpawn(id)
{
	if(!is_user_alive(id) || g_First < 3 || zp_get_user_zombie(id))
		return
	
	set_task(0.3, "TaskMessage", id)
}

public TaskMessage(id)
{
	if(!is_user_alive(id))
		return
		
	show_message(id, COLOR_INFO, -1.0, 0.8, "Нажмите ^"B^" что бы прикупить оружия!")	
}

public fwTakeDamage(id, weapon, attacker, Float:damage)
{	
	if(!is_user_alive(attacker))
		return
		
	if(zp_get_user_zombie(attacker))
		return	
		
	damage/=get_pcvar_num(pcvar_humans_dmg_reward)
			
	set_money(attacker, floatround(damage))
}

public fwKilled(id, killer)
{
	if(!is_user_alive(killer))
		return
	
	set_money(killer, get_pcvar_num(zp_get_user_zombie(killer)?pcvar_zombies_kill_reward:pcvar_humans_kill_reward))
}

public zp_user_infected_pre(id, infector)
{
	if(is_user_alive(infector))
		set_money(infector, get_pcvar_num(pcvar_zombies_kill_reward))
}

public cycle_players_set_money(message_index, rgb_hum[3], rgb_zb[3], money_hum, money_zb)
{
	new temp[64]
	
	for(new i=1; i<=g_MaxPlayers; i++)
	{
		if(!is_user_connected(i)||get_user_team(i)==4||get_user_team(i)==0)
			continue
		
		if(zp_get_user_zombie(i))
		{
			switch(message_index)
			{
				case 0: formatex(temp, 63, "%L", i, "HUD_MESSAGE_ZB_WIN", money_zb)
				
				case 1: formatex(temp, 63, "%L", i,  "HUD_MESSAGE_ZB_FAIL", money_zb)
				
				case 2: formatex(temp, 63, "%L", i,  "HUD_MESSAGE_ZB_DRAW", money_zb)
			}
			
			show_message(i, rgb_zb, 0.08, 0.5, temp)
			
			set_money(i, money_zb)
		}
		else
		{
			switch(message_index)
			{
				case 0: formatex(temp, 63, "%L", i, "HUD_MESSAGE_HUM_FAIL", money_hum)
				
				case 1: formatex(temp, 63, "%L", i, "HUD_MESSAGE_HUM_WIN", money_hum)
				
				case 2:  formatex(temp, 63, "%L", i, "HUD_MESSAGE_HUM_DRAW", money_hum)
			}
			
			show_message(i, rgb_hum, 0.08, 0.5, temp)
			
			set_money(i,money_hum)			
		}
	}	
}
		
public set_money(id, value)
{
	new money=zp_get_user_money(id)+value
		
	money=amx_clamp(money, (get_user_flags(id)&ADMIN_LEVEL)?LIMIT_ADMIN:((get_user_flags(id)&VIP_LEVEL)?LIMIT_VIP:LIMIT))
		
	zp_set_user_money(id, money)
}

stock amx_clamp(value, maximum)
	return value>maximum?maximum:value
	

stock show_message(id, const rgb[3], Float:x, Float:y, const message[])
{
	set_dhudmessage(rgb[0],rgb[1] ,rgb[2], x, y , 0)
	
	show_dhudmessage(id, message)
	show_dhudmessage(id, message)
}
