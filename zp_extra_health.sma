#include <amxmodx>
#include <fun>
#include <zombieplague>

new const item_name[] = "Health kit"
new g_itemid_buyhp
new hpamount

public plugin_init() 
{
	register_plugin("[ZP] Buy Health Points", "1.0", "T[h]E Dis[as]teR")
	hpamount = register_cvar("zp_buyhp_amount", "100")
	g_itemid_buyhp = zp_register_extra_item(item_name, 5, ZP_TEAM_HUMAN & ZP_TEAM_ZOMBIE)
}
public zp_extra_item_selected(id,itemid)
{
	if(!is_user_alive(id))
	
	return PLUGIN_HANDLED;
	
	if(itemid==g_itemid_buyhp)
	{
        set_user_health(id,get_user_health(id)+get_pcvar_num(hpamount));
        client_print(id, print_chat,"[ZP] You Bought HP!");
	}
	return PLUGIN_CONTINUE;
}