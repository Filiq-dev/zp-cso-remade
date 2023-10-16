#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <hamsandwich>
#include <zombieplague>
new gmsgSayText,
	Count[33]

public plugin_init()
{
	register_plugin("Some util plugins in one", "1.0", "Filiq_")
	
	RegisterHam(Ham_TakeDamage, "player", "fwTakeDamage", 1)


	register_clcmd("say", "cmdSay")
	register_clcmd("say_team", "cmdSay")

	register_forward(FM_ClientUserInfoChanged,"ClientUserInfoChanged");
}

public client_disconnected(id)
{
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
		client_print_color(id, 0, "^4[CSO]^1 Stop !4[%d/2]",Count[id])
		
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
		if(get_user_armor(id) > 0 && zp_get_human_count() != 1) client_print(attacker, print_center, "Armor: %d", get_user_armor(id))
		else client_print(attacker, print_center, "Health: %d", get_user_health(id))
	}
}