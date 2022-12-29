#include <amxmodx>
#include <engine>

new gmsgSayText

public plugin_init()
{
	register_plugin("Some util plugins in one", "1.0", "Filiq_")
	register_message((gmsgSayText = get_user_msgid("SayText")), "Message_SayText")

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

public client_infochanged(id)
{
	if(is_user_connected(id))
	{
		new 
			newname[32],
			oldname[32]

		get_user_info(id, "name", newname, 31)
		get_user_name(id, oldname, 31)

		if(!equal(oldname, newname))
		{
			ChatColor(id, "!y[!gCSO!y] You can't change your name.");
			set_user_info(id, "name", oldname);
		}
	}
	return false;
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