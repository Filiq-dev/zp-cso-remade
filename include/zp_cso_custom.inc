#pragma compress 1

#define host "188.212.103.196"
#define user "u2545_bU3OodJK9O"
#define pass "=4MGhi917Qv=hoC=3cu4zKjQ"
#define db "s2545_csoeasy"

enum 
{
	ginfinite,
	glevel,
	gmoney,
	gxp
}

native zp_get_user_level(id)
native zp_get_max_levels()
native zp_set_user_level(id, value)
native zp_set_user_exp(id, value)
native zp_get_user_exp(id)
native zp_get_exp_current(id)
native zp_set_user_money(id, money)
native zp_get_user_money(id)
native zp_alert_nomoney(id, num)
native zp_get_user_limit(id)
native zp_knife_menu(id)
native show_respawn_menu(id)
native zp_level_reset(id)
native zp_money_reset(id)
native hud_get_zinfo(id)
native is_user_loaded(id)
native cso_gameplay_active()
// native cso_gameplay_name()

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