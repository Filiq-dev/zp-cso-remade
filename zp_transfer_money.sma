#include <amxmodx>
#include <zp_cso_custom>
#include <colorchat>

new 
    sendMoney[33] = false

public plugin_init()
{
    if(get_cvar_num("ms_money_allow_donate"))
        register_clcmd("say /transfer", "showTransferMenu")
}	

public client_disconnect(id) {
    sendMoney[id] = false
}

public showTransferMenu(id, args)
{
	if(!get_cvar_num("ms_money_allow_donate"))
		ColorChat(id, RED, "[^4ZP^3] This command is ^4disabled ^3from the server")

	new num, players[32], tid, sid [10]
	get_players(players, num)
	
	new menu = menu_create("Transfer Menu | Zombie-Plague \w[\rCSO\w]", "transferMenuHandler")

	for (new i = 0; i < num; i++)
	{
		tid = players [ i ]

		num_to_str (tid, sid, 9)
		menu_additem (menu, getName(tid), sid)
	}
	
	menu_display (id, menu)
}

public transferMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new data[6], name[64]
	new access, callback

	menu_item_getinfo (menu, item, access, data, 5, name, 63, callback)
	new tempid = str_to_num (data)

	ColorChat(id, RED, "[^4ZP^1] ^3To be able to send money to ^4%s ^3type in ^4chat ^3desired ^4amount", getName(tempid))
	ColorChat(id, RED, "[^4ZP^1] ^3In chat please type only ^4numbers^3. If you want to cancel, type ^3cancel")

    sendMoney[id] = true

	return true;
}