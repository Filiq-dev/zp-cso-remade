#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <zombieplague>
#include <zp_cso_custom>

#define PLUGIN "[ZP] Level System"
#define VERSION "1.0"
#define AUTHOR "Arwel & Filiq_"

#define UPDATE_HUD_TIME 0.3
#define TASKID_SHOW 7773338201

new g_LevelsNum, g_PlayerExp[33], g_PlayerExpCurrent[33], g_PlayerLevel[33], Array:g_Levels
new pcvar_lvl_system,pcvar_xp_given, pcvar_xp_given_nem, pcvar_xp_given_surv
new pcvar_damage_for_xp, pcvar_xp_for_damage
new pcvar_lvl_for_zomb, pcvar_lvl_for_nem, pcvar_lvl_for_surv, pcvar_xp_given_infect, pcvar_xp_given_kill_lhuman
new pcvar_hud, Float:g_PlayerDamage[33], g_maxplayers

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_dictionary("buymenu.txt")

	pcvar_lvl_system = register_cvar("ms_lvl_system_active", "1")

	if(!get_pcvar_num(pcvar_lvl_system))
		return
	
	pcvar_lvl_for_zomb = register_cvar("ms_lvl_system_active_zombie", "1")
	pcvar_lvl_for_nem = register_cvar("ms_lvl_system_active_nem", "0")
	pcvar_lvl_for_surv = register_cvar("ms_lvl_system_active_surv", "0")

	pcvar_xp_given = register_cvar("ms_lvl_system_given_xp", "150")
	pcvar_xp_given_nem = register_cvar("ms_lvl_system_given_xp_nem", "10")
	pcvar_xp_given_surv = register_cvar("ms_lvl_system_given_xp_surv", "10")
	pcvar_xp_given_infect = register_cvar("ms_lvl_system_given_xp_infect", "3")    
	pcvar_xp_given_kill_lhuman = register_cvar("ms_lvl_system_given_xp_kill_lhuman", "5")    
	pcvar_damage_for_xp = register_cvar("ms_lvl_system_damage_for_xp", "1000")
	pcvar_xp_for_damage = register_cvar("ms_lvl_system_given_xp_damage", "2")

	pcvar_hud = register_cvar("ms_lvl_system_show_hud","1")

	g_maxplayers = get_maxplayers()    

	g_Levels=ArrayCreate(1)
	
	RegisterHam(Ham_Killed, "player", "fwKilled")
	
	if(get_pcvar_num(pcvar_damage_for_xp))
		RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage")

	if(get_pcvar_num(pcvar_hud))
		set_task(UPDATE_HUD_TIME, "ShowInfo", TASKID_SHOW, _, _, "b")  
}

public plugin_cfg()
{
	new confdir[64], path[128]

	get_configsdir(confdir, charsmax(confdir))
	formatex(path, charsmax(path), "%s/zp_buymenu.ini", confdir)

	new file = fopen(path, "rt")

	if (!file)
		return

	new linedata[512], section[64], level[9]

	fseek(file, 0 , SEEK_SET)
	
	while (!feof(file))
	{    
		fgets(file, linedata, charsmax(linedata))
		
		if(linedata[0]==';'||linedata[0]=='/')
			continue        

		replace(linedata, charsmax(linedata), "^n", "")
	
		if (linedata[0] == '[')
		{
			copyc(section, charsmax(section), linedata[1], ']')    

			if (equal(section, "LEVELS_EXP"))
				break
		}
	}

	while (!feof(file))
	{
		linedata=""

		fgets(file, linedata, charsmax(linedata))

		if(linedata[0] == '{'||linedata[0]==';'||linedata[0]=='/')
			continue        
		
		if(linedata[0] == '}')
			break

		replace(linedata, charsmax(linedata), "^n", "")
		replace(linedata, charsmax(linedata), ",", "")
		
		trim(linedata)
		
		if(!linedata[0])
			continue
			
		parse(linedata, level, charsmax(level))
		
		g_LevelsNum++
		
		ArrayPushCell(g_Levels, str_to_num(level))   
	}

}

public plugin_natives()
{
	register_native("zp_get_exp_current", "native_current", 1)
	register_native("zp_get_user_exp", "native_exp_get", 1)    
	register_native("zp_get_user_level", "native_level_get", 1)    
	register_native("zp_set_user_level", "native_level_set", 1)    
	register_native("zp_set_user_exp", "native_exp_set", 1)    
	register_native("zp_get_max_levels", "native_levels_max", 1)
}

public fwKilled(id, killer)
{
	menu_cancel(id)
	
	if(!is_user_alive(killer))
		return
	
	if(zp_get_user_zombie(killer) && !get_pcvar_num(pcvar_lvl_for_zomb))
		return
	
	if(zp_get_user_survivor(killer) && !get_pcvar_num(pcvar_lvl_for_surv))
		return
		
	if(zp_get_user_nemesis(killer) && !get_pcvar_num(pcvar_lvl_for_nem))
		return
	
	if(g_PlayerLevel[killer] >= g_LevelsNum)
		return    
	
	if(zp_get_user_nemesis(id))
		ExpUp(killer, get_pcvar_num(pcvar_xp_given_nem))
		
	else
		if(zp_get_user_survivor(id))
			ExpUp(killer, get_pcvar_num(pcvar_xp_given_surv))
		
		else
			if(zp_get_user_last_human(id))
				ExpUp(killer, get_pcvar_num(pcvar_xp_given_kill_lhuman))
			else    
				ExpUp(killer, get_pcvar_num(pcvar_xp_given))
			
	if(g_PlayerExp[killer] >= g_PlayerExpCurrent[killer])
		LevelUp(killer)
		
}

public fwTakeDamage(id, inflictor, attacker, Float:damage)
{
	if(!is_user_alive(attacker))
		return
	
	if(zp_get_user_zombie(attacker) && !get_pcvar_num(pcvar_lvl_for_zomb))
		return
	
	if(zp_get_user_survivor(attacker) && !get_pcvar_num(pcvar_lvl_for_surv))
		return
		
	if(zp_get_user_nemesis(attacker) && !get_pcvar_num(pcvar_lvl_for_nem))
		return        
	
	if(g_PlayerLevel[attacker] >= g_LevelsNum)
		return
	
	g_PlayerDamage[attacker] += damage
		
	if(g_PlayerDamage[attacker] >= get_pcvar_float(pcvar_damage_for_xp))
	{    
		ExpUp(attacker, get_pcvar_num(pcvar_xp_for_damage))
		
		g_PlayerDamage[attacker] -= get_pcvar_float(pcvar_damage_for_xp)
	}
	
	if(g_PlayerExp[attacker] >= g_PlayerExpCurrent[attacker])
		LevelUp(attacker)
}

public LevelUp(id)
{    
	if(!g_LevelsNum||g_PlayerLevel[id]>=g_LevelsNum)
		return
		
	g_PlayerLevel[id]++
	
	if(g_PlayerLevel[id] >= g_LevelsNum)
	{
		g_PlayerExp[id] = g_PlayerExpCurrent[id]
	}
	else
	{
		g_PlayerExp[id] -= g_PlayerExpCurrent[id]
		g_PlayerExpCurrent[id] = ArrayGetCell(g_Levels, g_PlayerLevel[id])
	}
	
}

public ExpUp(id, xp)
{
	if(!g_LevelsNum || g_PlayerLevel[id] >= g_LevelsNum)
		return
	
	g_PlayerExp[id] += xp
}

public ShowInfo(TASKID)
{
	for(new i=1; i<=g_maxplayers; i++)
	{
		if(!is_user_alive(i))
			continue
		
		set_hudmessage(0, 255, 0, -1.0, 0.9, 0, 0.0, UPDATE_HUD_TIME+0.1, 0.0, 0.0)
		show_hudmessage(i, "%L", i, "HUD_MESSAGE_DOWN", g_PlayerLevel[i], g_PlayerExp[i], g_PlayerExpCurrent[i])
	}
}

public zp_user_infected_pre(id, infector)
{
	if(!is_user_alive(infector))
		return
	
	if(!get_pcvar_num(pcvar_lvl_system)||!get_pcvar_num(pcvar_lvl_for_zomb))
		return
		
	if(g_PlayerLevel[infector]>=g_LevelsNum)
		return        
		
	ExpUp(infector, get_pcvar_num(pcvar_xp_given_infect))    
	
	if(g_PlayerExp[infector] >= g_PlayerExpCurrent[infector])
		LevelUp(infector)
}

public native_level_get(id) {
	return g_PlayerLevel[id]
}

public native_exp_get(id) {
	return g_PlayerExp[id]
}

public native_level_set(id, value)
{
	g_PlayerLevel[id] = value
	g_PlayerExpCurrent[id] = ArrayGetCell(g_Levels, g_PlayerLevel[id])
}

public native_levels_max() {
	return g_LevelsNum
}

public native_exp_set(id, value) {
	return g_PlayerExp[id]=value
}
	
public native_current(id) {
	return g_PlayerExpCurrent[id] = ArrayGetCell(g_Levels, g_PlayerLevel[id])
}