#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <zombieplague>

new const g_Names[][]= // from csoutstanding
{
	"CSO-Zombie.RO",
	"Discord: Filique#8205",
	"Zombie CSO Romania",
	"CSO-Zombie.RO - Panel"
}

new gmsgSayText,
	g_Bot[33], g_BotsCount, Count[33]

public plugin_init()
{
	register_plugin("Some util plugins in one", "1.0", "Filiq_")
	register_message((gmsgSayText = get_user_msgid("SayText")), "Message_SayText")
	
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage", 1)

	set_task(15.0, "TaskManageBots", _, _, _, "b");

	register_clcmd("say", "cmdSay")
	register_clcmd("say_team", "cmdSay")

	register_forward(FM_ClientUserInfoChanged,"ClientUserInfoChanged");
}

public client_disconnect(id)
{
	if(g_Bot[id] ) {
		g_Bot[id] = 0
		g_BotsCount --
	}
	Count[id] = 0
}

public cmdSay(id) {
	new szArgs[192]
	read_args(szArgs, charsmax(szArgs))
			
	if((containi(szArgs, "+") != -1) || (containi(szArgs, "#") != -1) || (containi(szArgs, "%") != -1))
	{
		Count[id]++
		if(Count[id] == 2)
		{
			server_cmd("kick #%i ^"Stop.[2/2]^"",get_user_userid(id))
			Count[id] = 0

			return PLUGIN_HANDLED_MAIN
		}
		ChatColor(id,"!g[CSO] !yStop !g[%d/2]",Count[id])
		
		return PLUGIN_HANDLED_MAIN
	}

	return PLUGIN_CONTINUE
}

public ClientUserInfoChanged(id)
{
	static const name[] = "name" 
	static szOldName[32], szNewName[32] 

	pev(id,pev_netname,szOldName,charsmax(szOldName)) 

	if(szOldName[0])
	{ 
		get_user_info(id, name, szNewName, charsmax(szNewName))
		set_user_info(id, name, szOldName)

		return FMRES_HANDLED
	}

	return FMRES_IGNORED
}

// https://forums.alliedmods.net/showpost.php?p=1088050&postcount=5
public Message_SayText(iMsgId, MSG_DEST, id)
{
	if(!id)
		return PLUGIN_CONTINUE

	static szChannel[24]
	get_msg_arg_string(2, szChannel, charsmax(szChannel))
	if(szChannel[0] != '#' || szChannel[1] != 'C' || szChannel[8] != '_' || szChannel[9] != 'C')
		return PLUGIN_CONTINUE

	if(id == get_msg_arg_int(1))
	{
		static szString[192]
		get_msg_arg_string(4, szString, charsmax(szString))
		message_begin(MSG_BROADCAST, gmsgSayText)
		write_byte(id)
		write_string(szChannel)
		write_string("")
		write_string(szString)
		message_end()
	}

	return PLUGIN_HANDLED
} 

// https://www.extreamcs.com/forum/post1967255.html#p1967255
public client_PreThink(id)
{
	if(!is_user_alive(id)) 
		return

	new Float:fallspeed = 100.0 * -1.0

	new button = get_user_button(id)
	if(button & IN_USE) 
	{
		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		if (velocity[2] < 0.0) 
		{
			entity_set_int(id, EV_INT_sequence, 3)
			entity_set_int(id, EV_INT_gaitsequence, 1)
			entity_set_float(id, EV_FL_frame, 1.0)
			entity_set_float(id, EV_FL_framerate, 1.0)

			velocity[2] = (velocity[2] + 40.0 < fallspeed) ? velocity[2] + 40.0 : fallspeed
			entity_set_vector(id, EV_VEC_velocity, velocity)
		}
	}
}

public fwTakeDamage(id, weapon, attacker, Float:damage)
{
	if(!is_user_alive(id) || !is_user_alive(attacker))
		return
	
	if(zp_get_user_zombie(id)) client_print(attacker, print_center, "HP: %d", get_user_health(id))
	else 
	{
		if(get_user_armor(id) > 0) client_print(attacker, print_center, "Armor: %d", get_user_armor(id))
		else client_print(attacker, print_center, "Health: %d", get_user_health(id))
	}
}

public TaskManageBots()
{
	static PlayersNum; PlayersNum  = get_playersnum(1);
	if(PlayersNum < get_maxplayers() - 1 && g_BotsCount < 3) {
		CreateBot();
	} 
	else if(PlayersNum > get_maxplayers() - 1 && g_BotsCount) {
		RemoveBot();
	}
}

public RemoveBot()
{
	static i;
	for(i = 1; i <= get_maxplayers(); i++) 
	{
		if(!g_Bot[i])
			continue

		server_cmd("kick #%d", get_user_userid(i))
		break
	}
}

public CreateBot()
{
	static Bot, str[255]

	formatex(str, 255, !random_num(0,1) ? "%s (%c%c)" : "%s - %c%c", g_Names[random_num(0, sizeof(g_Names) - 1)], random_num('A', 'Z'), random_num('A', 'Z'))
	Bot = engfunc(EngFunc_CreateFakeClient, str)
	
	if(Bot > 0 && pev_valid(Bot)) 
	{
		dllfunc(MetaFunc_CallGameEntity,"player",Bot)

		set_pev(Bot,pev_flags, FL_FAKECLIENT)
		set_pev(Bot, pev_model, "")
		set_pev(Bot, pev_viewmodel2, "")
		set_pev(Bot, pev_modelindex, 0)
		set_pev(Bot, pev_renderfx, kRenderFxNone)
		set_pev(Bot, pev_rendermode, kRenderTransAlpha)
		set_pev(Bot, pev_renderamt, 0.0)

		set_pdata_int(Bot,114,0)
		message_begin(MSG_ALL,get_user_msgid("TeamInfo"))
		write_byte(Bot)
		write_string("UNASSIGNED")
		message_end()

		g_Bot[Bot] = 1
		g_BotsCount++
	}
}

stock ChatColor(const id, const input[], any:...) 
{ 
	new count = 1, players[32] 
	static msg[191] 
	vformat(msg, 190, input, 3) 

	replace_all(msg, 190, "!g", "^4") 
	replace_all(msg, 190, "!y", "^1") 
	replace_all(msg, 190, "!t", "^3") 

	if (id) players[0] = id; else get_players(players, count, "ch") 
	{ 
		for (new i = 0; i < count; i++) 
		{ 
			if (is_user_connected(players[i])) 
			{ 
				message_begin(MSG_ONE_UNRELIABLE, get_user_msgid("SayText"), _, players[i]); 
				write_byte(players[i]); 
				write_string(msg); 
				message_end(); 
			} 
		} 
	} 
}