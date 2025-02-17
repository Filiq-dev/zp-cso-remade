#pragma compress 1

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
native save_data_remote(id)

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

stock ExplodeString( p_szOutput[][], p_nMax, p_nSize, p_szInput[], p_szDelimiter ) // xeroblood
{ 
    new nIdx = 0, l = strlen(p_szInput) 
    new nLen = (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput, p_szDelimiter )) 
    while( (nLen < l) && (++nIdx < p_nMax) ) 
        nLen += (1 + copyc( p_szOutput[nIdx], p_nSize, p_szInput[nLen], p_szDelimiter )) 
    return nIdx
}