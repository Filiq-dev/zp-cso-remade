native zp_get_user_level(id)
native zp_get_max_levels()
native zp_set_user_level(id, value)
native zp_set_user_exp(id, value)
native zp_get_user_exp(id)

native zp_set_user_money(id, money)
native zp_get_user_money(id)
native zp_alert_nomoney(id, num)

stock getName(id)
{
	new name[33]
	get_user_name(id, name, 32)
	return name
}
stock getIP(id)
{
	new name[64]
	// get_user_ip(id, name, 63, 1)
	format(name, 63, "1.2.3.4")
	return name
}