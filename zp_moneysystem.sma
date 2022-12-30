#include <amxmodx>
#include <amxmisc>
#include <dhudmessage>
#include <hamsandwich>
#include <zombieplague>
#include <zp_cso_custom>

#define PLUGIN "[CSO] Money System"
#define VERSION "1.0"
#define AUTHOR "Arwel & Filiq_"

new g_PlayerMoney[33], g_PlayerMoneyLimit[33],
	g_msgMoney, g_msgMoneyBlink,
	pcvar_humans_reward_win, pcvar_humans_reward_lose, pcvar_humans_reward_no_one,
	pcvar_humans_dmg_reward, pcvar_humans_kill_reward,
	pcvar_zombies_reward_win, pcvar_zombies_reward_lose, pcvar_zombies_reward_no_one,
	pcvar_zombies_kill_reward, g_MaxPlayers, g_First = 0

enum _:iNums
{
	iFlag,
	iLimit
}

new g_iFlags[10][iNums],
	g_iCount = -1

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("buymenu.txt")

	g_msgMoney=get_user_msgid("Money")
	g_msgMoneyBlink=get_user_msgid("BlinkAcct")
	
	register_message(g_msgMoney, "Msg_Money")
	register_message(get_user_msgid("StatusIcon"), "Msg_StatusIcon")

	RegisterHam(Ham_Spawn, "player", "fwSpawn", 1)
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage", 1)
	RegisterHam(Ham_Killed, "player", "fwKilled", 1)
	
	register_cvar("ms_default_money", "3200")
	
	pcvar_humans_reward_win = register_cvar("ms_human_win_reward", "3000")
	pcvar_humans_reward_lose = register_cvar("ms_human_lose_reward", "1500")
	pcvar_humans_reward_no_one = register_cvar("ms_human_no_one_reward", "2000")
	pcvar_humans_dmg_reward = register_cvar("ms_human_damage_reward_divide", "2")
	pcvar_humans_kill_reward = register_cvar("ms_human_kill_reward", "300")
	
	pcvar_zombies_reward_win = register_cvar("ms_zombie_win_reward", "3000")
	pcvar_zombies_reward_lose = register_cvar("ms_zombie_lose_reward", "1500")
	pcvar_zombies_reward_no_one = register_cvar("ms_zombie_no_one_reward", "2000")	
	pcvar_zombies_kill_reward = register_cvar("ms_zombie_kill_reward", "300")	

	register_cvar("ms_money_allow_donate", "1")
	
	g_MaxPlayers=get_maxplayers()
}

public plugin_cfg()
{
	new confdir[64], path[128]
	
	get_configsdir(confdir, charsmax(confdir))
	formatex(path, charsmax(path), "%s/zp_buymenu.cfg", confdir)
	server_cmd("exec %s", path)

	formatex(path, charsmax(path), "%s/zp_buymenu.ini", confdir)
	new file = fopen(path, "rt")

	new szLine[64],section[32], szLeft[5], szRight[10]
	
	fseek(file, 0 , SEEK_SET)
	
	while (!feof(file))
	{    
		fgets(file, szLine, charsmax(szLine))
		
		replace(szLine, charsmax(szLine), "^n", "")
	
		if(szLine[0] == '[')
		{
			copyc(section, charsmax(section), szLine[1], ']')        

			if (equal(section, "LIMITS"))
				break
		}
	}    
	
	while(!feof(file))
	{
		fgets(file,szLine,charsmax(szLine))
		
		trim(szLine)
		
		if(szLine[0] == '{'||szLine[0]==';'||szLine[0]=='/')
			continue
		
		if(szLine[0] == '}')
			break            
		
		g_iCount++
		
		parse(szLine, szLeft, charsmax(szLeft), szRight, charsmax(szRight))    
		
		g_iFlags[g_iCount][iFlag] = read_flags(szLeft)
		g_iFlags[g_iCount][iLimit] = str_to_num(szRight)

	}

	set_cvar_num("zp_remove_money", 0)
}

public plugin_natives()
{
	register_native("zp_set_user_money", "set_user_money", 1)
	register_native("zp_get_user_money", "get_user_money", 1)
	register_native("zp_get_user_limit", "get_user_limit", 1)  
	register_native("zp_alert_nomoney", "make_blink", 1)  
}

public client_connect(id)
{
	for(new i; i <= g_iCount; i++)
	{
		if(get_user_flags(id) & g_iFlags[i][iFlag])
		{
			g_PlayerMoneyLimit[id] = g_iFlags[i][iLimit]
			
			break
		}
	}    
}

public zp_round_ended(winteam)
{
	if(g_First > 2)
	{
		switch(winteam)
		{
			case WIN_NO_ONE: give_team_money(get_pcvar_num(pcvar_humans_reward_no_one), get_pcvar_num(pcvar_zombies_reward_no_one))
				
			case WIN_ZOMBIES: give_team_money(get_pcvar_num(pcvar_humans_reward_lose), get_pcvar_num(pcvar_zombies_reward_win))	
	
			case WIN_HUMANS: give_team_money(get_pcvar_num(pcvar_humans_reward_win), get_pcvar_num(pcvar_zombies_reward_lose))	
		}
	}
	
	g_First++
}

public zp_user_infected_pre(id, infector)
{
	if(is_user_alive(infector)) {
		set_user_money(infector, get_user_money(infector) + get_pcvar_num(pcvar_zombies_kill_reward))
	}
}

public fwSpawn(id)
{
	if(!is_user_alive(id) || g_First < 3 || zp_get_user_zombie(id))
		return
	
	set_task(0.3, "TaskMessage", id)
}

public fwTakeDamage(id, weapon, attacker, Float:damage)
{	
	if(!is_user_alive(attacker))
		return
		
	if(zp_get_user_zombie(attacker))
		return	
		
	damage /= get_pcvar_num(pcvar_humans_dmg_reward)
	
	set_user_money(attacker, get_user_money(attacker) + floatround(damage))
}

public fwKilled(id, killer)
{
	if(!is_user_alive(killer))
		return
	
	set_user_money(killer, get_user_money(killer) + get_pcvar_num(zp_get_user_zombie(killer) ? pcvar_zombies_kill_reward : pcvar_humans_kill_reward))
}

public TaskMessage(id) // de luat asta de aici
{
	if(!is_user_alive(id))
		return

	set_dhudmessage(0, 255, 0, -1.0, 0.8 , 0)
	show_dhudmessage(id, "Press ^"B^" to buy weapons!")
}

public give_team_money(money_hum, money_zb)
{
	for(new i = 1; i <= g_MaxPlayers; i++)
	{
		if(!is_user_connected(i) || get_user_team(i) == 4 || get_user_team(i) == 0)
			continue
		
		if(zp_get_user_zombie(i))
			set_user_money(i, get_user_money(i) + money_zb)
		else
			set_user_money(i, get_user_money(i) + money_hum)			
	}	
}

public Msg_Money(msg_id, msg_dest, msg_entity)
{
	if(get_msg_arg_int(2)) 
		return PLUGIN_HANDLED
	
	set_msg_arg_int(1, ARG_LONG, g_PlayerMoney[msg_entity])    
	
	return PLUGIN_CONTINUE
}

public Msg_StatusIcon(msg_id, msg_dest, msg_entity)
{
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1)!= 1)
		return
	
	static sprite[10]
	
	get_msg_arg_string(2, sprite, charsmax(sprite))
	
	if (!equal(sprite, "buyzone"))
		return
	
	set_msg_arg_int(3, get_msg_argtype(1), 0)
	set_msg_arg_int(4, get_msg_argtype(1), 0)
	set_msg_arg_int(5, get_msg_argtype(1), 0)
}

public get_user_limit(id) {
	return g_PlayerMoneyLimit[id]
}

public get_user_money(id) {
	return g_PlayerMoney[id]
}

public set_user_money(id, value)
{
	new money = clamp(value, 0, g_PlayerMoneyLimit[id])

	g_PlayerMoney[id] = value
		
	if(is_user_alive(id))
		sent_money(id, value)
}

public sent_money(id, num)
{    
	message_begin(MSG_ONE, g_msgMoney, _, id)
	write_long(num)
	write_byte(1)
	message_end()
}

public make_blink(id, num)
{
	message_begin(MSG_ONE, g_msgMoneyBlink, _, id)
	write_byte(num)
	message_end()    
}