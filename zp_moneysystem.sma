#include <amxmodx>
#include <amxmisc>


new g_PlayerMoney[33]
new g_msgMoney, g_msgMoneyBlink


public plugin_init()
{

	g_msgMoney=get_user_msgid("Money")
	g_msgMoneyBlink=get_user_msgid("BlinkAcct")
	
	register_message(g_msgMoney, "Msg_Money")
	register_message(get_user_msgid("StatusIcon"), "Msg_StatusIcon")

}

public plugin_cfg()
{
	set_cvar_num("zp_remove_money", 0)
}

public plugin_natives()
{
	register_native("zp_set_user_money", "set_user_money", 1)
	register_native("zp_get_user_money", "get_user_money", 1)
	// register_native("zp_get_user_limit", "get_user_limit", 1)  
	register_native("zp_alert_nomoney", "make_blink", 1)  
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

// public get_user_limit(id) {
// 	return g_PlayerMoneyLimit[id]
// }

public get_user_money(id) {
	return g_PlayerMoney[id]
}

public set_user_money(id, value)
{
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