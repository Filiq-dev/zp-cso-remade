#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta_util>
#include <zombieplague>
#include <sqlx>

#include <zp_cso_custom>

#define PLUGIN "[CSO] BuyMenu System"
#define VERSION "7.4"
#define AUTHOR "Arwel"
#define KNIFES "hammer"

#define PRIMARY_WEAPON 0
#define SECONDARY_WEAPON 1
#define MAX_ITEMS 8
#define MAX_FLAGS 8                                                                                                  
#define pev_weaponkey pev_impulse
#define pev_level pev_iuser2
#define flag_get(%1,%2) (%1 & (1<<%2))
#define flag_set(%1,%2) (%1 |= (1<<%2))
#define flag_unset(%1,%2) (%1 &=~ (1<<%2))

enum _:
{
	ITEMS_PISTOLS,
	ITEMS_SHOTGUNS,
	ITEMS_AUTOMACHINES,
	ITEMS_RIFLES,
	ITEMS_MACHINEGUNS,
	ITEMS_HEXTRA,
	ITEMS_ZEXTRA,
	ITEMS_KNIFES
}

new const SETTINGS_NAMES[MAX_ITEMS][]=
{    
	"PISTOLS",
	"SHOTGUNS",
	"AUTOMACHINES",
	"RIFLES",
	"MACHINEGUNS",
	"H_EXTRAITEMS",
	"Z_EXTRAITEMS",
	"KNIFES"
}

#define FLAGS_ROUND 0
#define FLAGS_NEM 1
#define FLAGS_FIRST_ZOMBIE 2
#define FLAGS_ROUND_NEMESIS 3
#define FLAGS_ROUND_SURVIVOR 4
#define FLAGS_ROUND_SWARM 5
#define FLAGS_ROUND_PLAGUE 6
#define FLAGS_ON_ONE_MAP 7

new const Commands[][]=
{
	"galil", "defender", "ak47", "cv47", "scout",
	"sg552", "krieg552", "awp", "magnum", "g3sg1", "d3au1", "famas", "clarion",
	"m4a1", "aug", "bullpup", "krieg550", "glock", "9x19mm", "km45", "p228", "228compact",
	"nighthawk", "elites", "fn57", "fiveseven", "12gauge", "xm1014", "autoshotgun", "mac10", "tmp", "mp", "mp5", "smg", "ump45", "p90", "c90", "m249", "vest", "vesthelm", "flash",
	"hegren", "sgren", "nvgs", "shield", "cl_setautobuy",  "cl_autobuy", "cl_setrebuy", "cl_rebuy", "buyequip"
}

new g_Menus[MAX_ITEMS]
new Array:g_Items[MAX_ITEMS]
new Array:g_ItemsCosts[MAX_ITEMS]
new Array:g_ItemsFlags2[MAX_ITEMS]
new Array:g_ItemsLevels[MAX_ITEMS]
new Array:g_ItemsMinimumPlayers[MAX_ITEMS]
new Array:g_ItemsBuyingOnOneRound[MAX_ITEMS]

new Trie:g_TrieItems_Buyed[MAX_ITEMS]

new g_LockedItem[MAX_ITEMS]

new Array:g_WeaponKeys[2]

new g_Callback, g_CallbackFlags

new g_fwSpawn, g_BuyzoneEnt, Float:g_PlayerLastSpawnTime[33], g_PlayerSpentMoney[33]

new g_players_in_menu, g_players_choosed_knife

new pcvar_open_all_menu_for_zombie, pcvar_open_all_menu_for_human

new pcvar_off_menu_when_mode_start, pcvar_time_spawn_for_buy

const PRIMARY_WEAPONS_BIT_SUM = 
(1<<CSW_SCOUT)|(1<<CSW_XM1014)|(1<<CSW_MAC10)|(1<<CSW_AUG)|(1<<CSW_UMP45)|(1<<CSW_SG550)|(1<<CSW_GALIL)|(1<<CSW_FAMAS)|(1<<CSW_AWP)|(1<<
CSW_MP5NAVY)|(1<<CSW_M249)|(1<<CSW_M3)|(1<<CSW_M4A1)|(1<<CSW_TMP)|(1<<CSW_G3SG1)|(1<<CSW_SG552)|(1<<CSW_AK47)|(1<<CSW_P90)

const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE) 

new g_started, g_maxplayers, g_file

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_dictionary("cso.txt")
	
	register_clcmd("client_buy_open", "vgui_menu_hook")
	register_clcmd("buy_wpn", "main_menu_build")
	register_clcmd("buy", "main_menu_build")
	register_clcmd("say /buy", "main_menu_build")
	
	for(new i; i<=charsmax(Commands); i++)
		register_clcmd(Commands[i], "BlockAutobuy")    
		
	pcvar_open_all_menu_for_zombie=register_cvar("ms_zombie_open_all_menu", "1")
	pcvar_open_all_menu_for_human=register_cvar("ms_human_open_all_menu", "1")
	
	pcvar_off_menu_when_mode_start=register_cvar("ms_off_menu_when_mode_started", "1")
	pcvar_time_spawn_for_buy=register_cvar("ms_time_for_buy", "15.0")
	
	g_Callback=menu_makecallback("main_menu_callback")
	g_CallbackFlags=menu_makecallback("flags_callback") 
	
	RegisterHam(Ham_Spawn, "player", "fwSpawn", 1)
	RegisterHam(Ham_Touch, "weaponbox", "fwTouch")
	
	unregister_forward(FM_Spawn, g_fwSpawn)
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_SetModel, "fw_SetModelPre")
		
	register_event("HLTV", "EventRoundStart", "a", "1=0", "2=0")
	
	new temp[128]
	 
	for(new i; i<MAX_ITEMS; i++)
	{
		formatex(temp, 127, "%L", LANG_PLAYER, SETTINGS_NAMES[i])
		g_Menus[i]=menu_create(temp, "weapons_menus_handler", 1)
		
		formatex(temp, 127, "%L", LANG_PLAYER, "EXIT")
		menu_setprop(g_Menus[i], MPROP_EXITNAME, temp)
		
		formatex(temp, 127, "%L", LANG_PLAYER, "NEXT")
		menu_setprop(g_Menus[i],MPROP_NEXTNAME, temp)
		
		formatex(temp, 127, "%L", LANG_PLAYER, "BACK")
		menu_setprop(g_Menus[i],MPROP_BACKNAME, temp)
		
		g_Items[i]=ArrayCreate(128)
		g_ItemsCosts[i]=ArrayCreate(1)
		g_ItemsFlags2[i]=ArrayCreate(MAX_FLAGS+1)
		g_ItemsLevels[i]=ArrayCreate(1)
		g_ItemsMinimumPlayers[i]=ArrayCreate(1)
		g_ItemsBuyingOnOneRound[i]=ArrayCreate(1)
		
		g_TrieItems_Buyed[i]=TrieCreate()
	}
	
	g_WeaponKeys[0]=ArrayCreate(1)
	g_WeaponKeys[1]=ArrayCreate(1)

	g_maxplayers=get_maxplayers()    
}

public plugin_cfg()
{
	new confdir[64], path[128]

	get_configsdir(confdir, charsmax(confdir))
	formatex(path, charsmax(path), "%s/cso/zp_buymenu.ini", confdir)

	g_file = fopen(path, "rt")

	for(new i; i < MAX_ITEMS; i++)
	{   
		Load_Weapons(SETTINGS_NAMES[i], i)

		if(menu_items(g_Menus[i]) <= 0)
			g_LockedItem[i] = true
	}

	Load_Weapons("LEVELS_WEAPKEY", -1)

	fclose(g_file)
	
	formatex(path, charsmax(path), "%s/cso/zp_buymenu.cfg", confdir)
	
	server_cmd("exec %s", path)    
}

public plugin_precache()
{
	g_BuyzoneEnt=engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "func_buyzone"))
	
	dllfunc(DLLFunc_Spawn, g_BuyzoneEnt)
	set_pev(g_BuyzoneEnt, pev_solid, SOLID_NOT)    
	
	g_fwSpawn=register_forward(FM_Spawn, "fw_Spawn")
}

public client_authorized(id)
{    
	set_user_info(id, "_vgui_menus", "0")
	
	// client_cmd(id, "setinfo _vgui_menus 0")
	client_cmd(id, "unbind b")
	client_cmd(id, "bind b buy")
}

public BlockAutobuy(id) {
	return PLUGIN_HANDLED
}

public vgui_menu_hook(id)
{
	if(!is_user_alive(id))
		return PLUGIN_CONTINUE
	
	message_begin(MSG_ONE, get_user_msgid("BuyClose"), _, id)
	message_end()
	
	main_menu_build(id)
	
	return PLUGIN_HANDLED
}

public EventRoundStart(id)
{
	// client_cmd(0, "setinfo _vgui_menus 0")
	arrayset(g_PlayerSpentMoney, 0, 32)
	
	g_players_choosed_knife = 0    
	
	new item, sz_buying[32]
		
	for(new type; type < MAX_ITEMS; type++)
	{
		for(item=0; item < ArraySize(g_Items[type]); item++)
		{    
			if(ArrayGetCell(g_ItemsBuyingOnOneRound[type], item) == 0)
				continue
	
			if(flag_get(ArrayGetCell(g_ItemsFlags2[type], item), FLAGS_ON_ONE_MAP))
				continue    
	
			for(new id=1; id <= g_maxplayers; id++)
			{
				formatex(sz_buying, 31, "%i;%i",  item, id) 
				
				if(!TrieKeyExists(g_TrieItems_Buyed[type],sz_buying))
					continue
				else
					TrieDeleteKey(g_TrieItems_Buyed[type], sz_buying)
			}
		}
	}
	
	for(new i=1; i <= g_maxplayers; i++)
	{
		if(is_user_alive(i))
		{
			if(zp_get_user_zombie(i)||zp_get_user_survivor(i)) //get_user_zombie work with nemesis
			{
				zp_set_user_money(i, zp_get_user_money(i) + g_PlayerSpentMoney[i])
			}
			
			if(flag_get(g_players_in_menu, i-1))
				client_cmd(i, "slot10")
		}
	}    
	
	g_started=false
}

public zp_round_started(gamemode, id)
{    
	for(new i=1; i<=g_maxplayers; i++)
	{
		if(is_user_alive(i))
		{
			if(zp_get_user_zombie(i) || zp_get_user_survivor(i)) //get_user_zombie work with nemesis
			{
				zp_set_user_money(i, zp_get_user_money(i) + g_PlayerSpentMoney[i])
			}
			
			if(flag_get(g_players_in_menu, i-1))
				client_cmd(i, "slot10")
		}
	}    

	g_started = true
}

public fw_Spawn(ent)
{
	if(!pev_valid(ent))
		return FMRES_IGNORED
	
	new classname[32]
	pev(ent, pev_classname, classname, charsmax(classname))
	
	if(equal(classname, "func_buyzone"))
	{
		engfunc(EngFunc_RemoveEntity, ent)
		
		return FMRES_SUPERCEDE
	}
	
	return FMRES_IGNORED
}

public fwSpawn(id) {
	g_PlayerLastSpawnTime[id] = get_gametime()
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return

	dllfunc(DLLFunc_Touch, g_BuyzoneEnt, id)
}

public fw_SetModelPre(ent, model[])
{
	if(!zp_get_max_levels())
		return FMRES_IGNORED
		
	if(!pev_valid(ent))
		return FMRES_IGNORED
				
	static classname[33]
	
	pev(ent, pev_classname, classname, charsmax(classname))
		
	if(!equal(classname, "weaponbox"))
		return FMRES_IGNORED
	
	if(pev(ent, pev_level))
		return FMRES_IGNORED
	
	new weap
	
	for(new i; i < ArraySize(g_WeaponKeys[0]); i++)
	{
		weap = fm_find_ent_by_integer(-1, pev_weaponkey, ArrayGetCell(g_WeaponKeys[0], i))
	
		if(pev(weap, pev_owner) == ent)
		{    
			set_pev(ent, pev_level, ArrayGetCell(g_WeaponKeys[1], i))
			
			return FMRES_IGNORED //exit
		}
	}
		
	return FMRES_IGNORED
}

public fwTouch(ent, id)
{
	if(!is_user_alive(id))
		return HAM_IGNORED
		
	if(zp_get_user_zombie(id))
		return HAM_IGNORED

	if(!zp_get_max_levels())
		return HAM_IGNORED
	
	if(pev(ent, pev_level) > zp_get_user_level(id))
		return HAM_SUPERCEDE

	return HAM_IGNORED
}

public main_menu_build(id)
{    
	if(!is_user_alive(id)||zp_get_user_survivor(id))
		return PLUGIN_HANDLED

	new zomb=zp_get_user_zombie(id)    
	
	if(zomb&&!get_pcvar_num(pcvar_open_all_menu_for_zombie))
	{
		menu_display(id, g_Menus[ITEMS_ZEXTRA])
		
		return PLUGIN_HANDLED
	}
		
	if(get_gametime()-g_PlayerLastSpawnTime[id]>get_pcvar_float(pcvar_time_spawn_for_buy)&&
	!get_pcvar_num(pcvar_open_all_menu_for_human)&&g_started)
	{
		menu_display(id, g_Menus[ITEMS_HEXTRA+zomb])
		
		return PLUGIN_HANDLED
	}        
		
	new temp[128], temp2[10]

	formatex(temp, 127, "%L", id, "MAIN_MENU")
	formatex(temp2, 9, "%i", ITEMS_HEXTRA+zomb)

	new menu=menu_create(temp, "main_menu_handler")

	formatex(temp, 127, "%L", id, "PISTOLS")
	menu_additem(menu, temp, "1", 0, g_Callback)
	
	formatex(temp, 127, "%L", id, "SHOTGUNS")
	menu_additem(menu, temp, "2", 0, g_Callback)
	
	formatex(temp, 127, "%L", id, "AUTOMACHINES")
	menu_additem(menu, temp, "3", 0, g_Callback)
	
	formatex(temp, 127, "%L", id, "RIFLES")
	menu_additem(menu, temp, "4", 0, g_Callback)
	
	formatex(temp, 127, "%L^n", id, "MACHINEGUNS")
	menu_additem(menu, temp, "5", 0, g_Callback)
	
	formatex(temp, 127, "%L^n", id, (zomb)?"Z_EXTRAITEMS":"H_EXTRAITEMS")
	menu_additem(menu, temp, temp2, 0, g_Callback)
	
	formatex(temp, 127, "%L", id, "KNIFES")
	menu_additem(menu, temp, "7", 0)    
	
	formatex(temp, 127, "%L", id, "EXIT")
	menu_setprop(menu, MPROP_EXITNAME, temp )
	
	formatex(temp, 127, "%l", id, "NEXT")
	menu_setprop(menu,MPROP_NEXTNAME, temp)
	
	formatex(temp, 127, "%l", id, "BACK")
	menu_setprop(menu,MPROP_BACKNAME, temp)    
	
	flag_set(g_players_in_menu, id-1)
	
	menu_display(id, menu)

	return PLUGIN_HANDLED
}

public main_menu_handler(id, menu, item)
{
	if (item == MENU_EXIT)
	{
		menu_destroy(menu)
		
		flag_unset(g_players_in_menu, id)
		
		return PLUGIN_HANDLED
	}
	
	if(zp_get_user_zombie(id)&&item==ITEMS_HEXTRA)
	{
		menu_display(id, g_Menus[ITEMS_ZEXTRA])
		
		menu_destroy(menu)
		
		return PLUGIN_HANDLED
	}
	
	if(item>=ITEMS_ZEXTRA)
		item++
	
	
	if(item == ITEMS_KNIFES)
	{
		// zp_knife_menu(id)

		return PLUGIN_HANDLED
	}


	new name[64]
	
	formatex(name, 63, "%L", id, SETTINGS_NAMES[item]) 
	menu_setprop(g_Menus[item], MPROP_TITLE, name)
	
	formatex(name, 63, "%L", id, "EXIT") 
	menu_setprop(g_Menus[item], MPROP_EXITNAME, name)

	formatex(name, 63, "%L", id, "BACK") 
	menu_setprop(g_Menus[item], MPROP_BACKNAME, name)    

	formatex(name, 63, "%L", id, "NEXT") 
	menu_setprop(g_Menus[item], MPROP_NEXTNAME, name)    
	
	menu_display(id, g_Menus[item])
	
	menu_destroy(menu)
	
	return PLUGIN_CONTINUE
	
}

public main_menu_callback(id, menu, item)
{
	if(item>=ITEMS_ZEXTRA)
		item++
	
	if(g_LockedItem[item])
		return ITEM_DISABLED
	
	if(zp_get_user_zombie(id) && item != ITEMS_HEXTRA)
		return ITEM_DISABLED    
		
	// if(item+1 == ITEMS_KNIFES && flag_get(g_players_choosed_knife, id-1))
	// 	return ITEM_DISABLED
	
	if(item != ITEMS_HEXTRA && g_started)
	{
		if(get_gametime() - g_PlayerLastSpawnTime[id] > get_pcvar_float(pcvar_time_spawn_for_buy) && get_pcvar_num(pcvar_off_menu_when_mode_start))
			return ITEM_DISABLED
	}
		
	return ITEM_IGNORE
}

public flags_callback(id, menu, item)
{
	static index, i
	
	for(i=0; i<MAX_ITEMS; i++)
	{
		if(g_Menus[i]==menu)
			index=i    
	}

	if(ArrayGetCell(g_ItemsCosts[index], item) > zp_get_user_money(id))
		return ITEM_DISABLED    
	
	if(get_cvar_num("ms_lvl_system_active") && ArrayGetCell(g_ItemsLevels[index], item) > zp_get_user_level(id))
		return ITEM_DISABLED    
	
	if(get_playersnum() < ArrayGetCell(g_ItemsMinimumPlayers[index], item))
		return ITEM_DISABLED    
	
	if(ArraySize(g_ItemsFlags2[index]))
	{
		static flag
	
		flag=ArrayGetCell(g_ItemsFlags2[index], item)
		
		if(flag_get(flag, FLAGS_ROUND)&&!g_started)
			return ITEM_DISABLED
		
		if(!flag_get(flag, FLAGS_NEM)&&zp_get_user_nemesis(id))
			return ITEM_DISABLED    
		
		if(flag_get(flag, FLAGS_FIRST_ZOMBIE)&&zp_get_user_first_zombie(id))
			return ITEM_DISABLED    
			
		if(flag_get(flag, FLAGS_ROUND_NEMESIS)&&zp_is_nemesis_round())
			return ITEM_DISABLED        
			
		if(flag_get(flag, FLAGS_ROUND_SURVIVOR)&&zp_is_survivor_round())
			return ITEM_DISABLED        
		
		if(flag_get(flag, FLAGS_ROUND_SWARM)&&zp_is_swarm_round())
			return ITEM_DISABLED        
		
		if(flag_get(flag, FLAGS_ROUND_PLAGUE)&&zp_is_plague_round())
			return ITEM_DISABLED    
	}
	
	return ITEM_IGNORE
}


public weapons_menus_handler(id, menu, item)
{
	
	flag_unset(g_players_in_menu, id)
	
	if (item==MENU_EXIT||zp_get_user_survivor(id))
		return PLUGIN_HANDLED    

	if(zp_get_user_zombie(id)&&menu!=g_Menus[ITEMS_ZEXTRA])
		return PLUGIN_HANDLED
		
	new data[6], iName[64]
	new Access, callback
	
	menu_item_getinfo(menu, item, Access, data,5, iName, 63, callback)

	new PistolRealName[128], cost

	new index

	for(new i; i<MAX_ITEMS; i++)
	{
		if(g_Menus[i]==menu)
			index=i    
	}
	
	ArrayGetString(g_Items[index], item, PistolRealName, charsmax(PistolRealName))
	cost=ArrayGetCell(g_ItemsCosts[index], item)
		
	if(zp_get_user_money(id) < cost)
	{
		zp_alert_nomoney(id, 5)
		
		client_print(id, print_center, "%L", id, "NO_MONEY")
		
		return PLUGIN_CONTINUE
	}
	
	new buying=ArrayGetCell(g_ItemsBuyingOnOneRound[index], item)
	
	if(buying>0)
	{
		new sz_buying[32], value
		
		formatex(sz_buying, 31, "%i;%i",  item, id)//format key 
		
		if(TrieKeyExists(g_TrieItems_Buyed[index],sz_buying))// if has buyed
		{
			TrieGetCell(g_TrieItems_Buyed[index], sz_buying, value)//load num 
			
			if(value>=buying)//if limit is reached
			{
				client_print(id, print_center, "%L", id, flag_get(ArrayGetCell(g_ItemsFlags2[index], item), FLAGS_ON_ONE_MAP)?"INFO_CHAT_LIMIT_STOP_MAP":"INFO_CHAT_LIMIT_STOP_ROUND")
				
				return PLUGIN_CONTINUE
			}
			else
			{
				value++//add
				
				TrieSetCell(g_TrieItems_Buyed[index], sz_buying, value)//save
			}
		}
		else
		{
			value=1
			
			TrieSetCell(g_TrieItems_Buyed[index], sz_buying, value)//if hasn't buyed - save
		}
	
	
		if(buying-value>0)
		{
			new sz_name[64]
			
			ArrayGetString(g_Items[index], item, sz_name, 63)
		
			client_print(id, print_center, "%L", id, flag_get(ArrayGetCell(g_ItemsFlags2[index], item), FLAGS_ON_ONE_MAP)?"INFO_CHAT_LIMIT_MAP":"INFO_CHAT_LIMIT_ROUND", sz_name, buying-value)
		}
	
	}

	
	if(equal(PistolRealName, "weapon_fashbang")) 
	{
		fm_give_item(id, "weapon_fashbang")

		zp_set_user_money(id, zp_get_user_money(id) - cost)
		g_PlayerSpentMoney[id] += cost

		return PLUGIN_CONTINUE
	}
	if(equal(PistolRealName, "weapon_smokegrenade")) 
	{
		fm_give_item(id, "weapon_smokegrenade")

		zp_set_user_money(id, zp_get_user_money(id) - cost)
		g_PlayerSpentMoney[id] += cost

		return PLUGIN_CONTINUE
	}

	new itemid=zp_get_extra_item_id(PistolRealName)
	if(itemid == -1)
	{
		log_amx("Item not found: %s", PistolRealName)
		
		return PLUGIN_CONTINUE
	}

	switch(index)
	{
		case ITEMS_PISTOLS: drop_weapons(id, 2)
	
		case ITEMS_SHOTGUNS..ITEMS_MACHINEGUNS: drop_weapons(id, 1)
		
		case ITEMS_KNIFES: flag_set(g_players_choosed_knife, id-1) 
	}
	
	zp_set_user_money(id, zp_get_user_money(id) - cost)
	g_PlayerSpentMoney[id] += cost
	
	zp_force_buy_extra_item(id, itemid, 1)

	return PLUGIN_CONTINUE
}

public register_item(weapon_name_lang[], weapon_name_real[], cost, flags[], type, level, min_players, buy_in_round)
{
	new MenuName[128]

	if(weapon_name_lang[0]||weapon_name_real[0])
	{
		
		if(level)
			formatex(MenuName, charsmax(MenuName), "%s %L %L", weapon_name_lang, LANG_SERVER, "LANG_LVL", level, LANG_SERVER, "LANG_COST", cost)
		else
			formatex(MenuName, charsmax(MenuName), "%s %L", weapon_name_lang, LANG_SERVER, "LANG_COST", cost)
		
		if(min_players)
			formatex(MenuName, charsmax(MenuName), "%s %L", MenuName, LANG_SERVER, "LANG_PLAYERS", min_players)
		
		menu_additem(g_Menus[type], MenuName, "1", 0, g_CallbackFlags)
	}
	
	ArrayPushCell(g_ItemsFlags2[type], read_flags(flags))
	
	ArrayPushString(g_Items[type], weapon_name_real)
	ArrayPushCell(g_ItemsCosts[type], cost)
	ArrayPushCell(g_ItemsLevels[type], level)
	ArrayPushCell(g_ItemsMinimumPlayers[type], min_players)
	ArrayPushCell(g_ItemsBuyingOnOneRound[type], buy_in_round)
}

public Load_Weapons(setting_section[], type)
{
	if (!g_file)
		return -1

	new linedata[512], section[64]    
	
	new weapon_name_lang[256], weapon_name_real[128], cost[10] 
	new flags[MAX_FLAGS+1], level[9], min_players[9], buy_in_round[9]

	fseek(g_file, 0 , SEEK_SET)
	
	while (!feof(g_file))
	{    
		fgets(g_file, linedata, charsmax(linedata))
		
		if(linedata[0]==';'||linedata[0]=='/')
			continue        

		replace(linedata, charsmax(linedata), "^n", "")
	
		if (linedata[0] == '[')
		{
			copyc(section, charsmax(section), linedata[1], ']')        

			if (equal(section, setting_section))
				break
		}
	}

	while (!feof(g_file))
	{
		linedata=""

		fgets(g_file, linedata, charsmax(linedata))

		if(linedata[0] == '{'||linedata[0]==';'||linedata[0]=='/')
			continue        
		
		if(linedata[0] == '}')
			break

		replace(linedata, charsmax(linedata), "^n", "")
		replace(linedata, charsmax(linedata), ",", "")
		
		trim(linedata)
		
		if(!linedata[0])
			continue
			
		if(type == -1)
		{
			parse(linedata, weapon_name_lang, charsmax(weapon_name_lang), weapon_name_real, charsmax(weapon_name_real))
			
			ArrayPushCell(g_WeaponKeys[0], str_to_num(weapon_name_lang))
			ArrayPushCell(g_WeaponKeys[1], str_to_num(weapon_name_real))
		}
		else
		{
			parse(linedata, weapon_name_lang, charsmax(weapon_name_lang), weapon_name_real, charsmax(weapon_name_real), cost, charsmax(cost), flags, sizeof(flags), level, 8, min_players, 8, buy_in_round, 8)    
			register_item(weapon_name_lang, weapon_name_real, str_to_num(cost), flags, type, str_to_num(level), str_to_num(min_players), str_to_num(buy_in_round))
		
			weapon_name_lang=""
			weapon_name_real=""
			flags=""
			level=""
			min_players=""
			buy_in_round=""
		}
	}
	
	return PLUGIN_CONTINUE
}

stock drop_weapons(id, dropwhat)
{
	static weapons[32], num, i
	static wname[32]
	
	num=0
	
	get_user_weapons(id, weapons, num)
	
	for(i=0; i<num; i++)
	{        
		if((dropwhat==1&&((1<<weapons[i])&PRIMARY_WEAPONS_BIT_SUM))
		||(dropwhat==2&&((1<<weapons[i])&SECONDARY_WEAPONS_BIT_SUM)))
		{
			get_weaponname(weapons[i], wname, 31)
 
			engclient_cmd(id, "drop", wname)
		}
	}
}