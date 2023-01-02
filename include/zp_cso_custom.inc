native zp_get_user_level(id)
native zp_get_max_levels()
native zp_set_user_level(id, value)
native zp_set_user_exp(id, value)
native zp_get_user_exp(id)
native zp_get_exp_current(id)
native zp_set_user_money(id, money)
native zp_get_user_money(id)
native zp_alert_nomoney(id, num)
native show_hud_menu(id)
native zp_get_user_limit(id)
native zp_knife_menu(id)
native show_respawn_menu(id)
native zp_level_reset(id)
native zp_money_reset(id)
stock getName(id)
{
	new name[33]
	get_user_name(id, name, 32)
	return name
}
stock getIP(id)
{
	new name[64]
	get_user_ip(id, name, 63, 1)
	return name
}