#include <amxmodx>
#include <zp_cso_custom>

#define PLUGIN "[CSO] Transfer Menu"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

new 
    sendMoney[33] = -1

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	if(get_cvar_num("ms_money_allow_donate")) {
		register_clcmd("say /transfer", "showTransferMenu")
	
		register_clcmd("say", "cmdSay")
	}
}	

public client_putinserver(id) {
    sendMoney[id] = -1
}

public cmdSay(id) {
	new szArgs[192]
	read_args(szArgs, charsmax(szArgs))
	remove_quotes(szArgs)

	if(sendMoney[id] == -1)
		return PLUGIN_CONTINUE

	if(containi(szArgs, "cancel") != -1)
	{
		sendMoney[id] = -1
		
		client_print_color(id, 0, "[^4CSO^3] ^3Now you can use the chat back.")

		return PLUGIN_HANDLED_MAIN;
	}

	if(!isNumeric(szArgs))
	{
		client_print_color(id, 0, "[^4CSO^3] ^3Please type how much you want to send to ^4%s^3. If you want to cancel, type ^4cancel", getName(sendMoney[id]))

		return PLUGIN_HANDLED_MAIN
	}

	new money = str_to_num(szArgs)

	if((zp_get_user_money(id) - money) < 1)
	{
		client_print_color(id, 0, "[^4CSO^3] ^3You don't have enough ^4money^3.")

		return PLUGIN_HANDLED_MAIN
	}

	// if((zp_get_user_money(sendMoney[id]) + money) > zp_get_user_limit(id))
	// {
	// 	client_print_color(id, 0, "[^4CSO^3] ^3He can't have more money. Buy ^4VIP ^3to can handle more money.")

	// 	return PLUGIN_HANDLED_MAIN
	// }	

	zp_set_user_money(id, zp_get_user_money(id) - money)
	zp_set_user_money(sendMoney[id], zp_get_user_money(sendMoney[id]) + money)

	client_print_color(0, 0, "[^4CSO^3] ^4%s ^3send ^4%d^3$ to ^4%s^3. Use [^4/transfer^3] if you want to transfer ^4money ^3to a friend.", getName(id), money, getName(sendMoney[id]))

	sendMoney[id] = -1

	return PLUGIN_HANDLED_MAIN
}

public showTransferMenu(id)
{
	if(!get_cvar_num("ms_money_allow_donate"))
		client_print_color(id, 0, "[^4CSO^3] This command is ^4disabled ^3from the server")

	new num, players[32], sid[10]
	get_players(players, num)

	if(num == 0)
	{
		client_print_color(id, 0, "[^4CSO^3] Is only you on ^4server^3.")

		return true
	}
	
	new menu = menu_create("Transfer Menu | Zombie-Plague \w[\rCSO\w]", "transferMenuHandler")

	for (new i = 0; i < num; i++)
	{
		if(id == players[i] || is_user_bot(players[i]))
			continue

		num_to_str(players[i], sid, 9)
		menu_additem(menu, getName(players[i]), sid)
	}
	
	menu_display (id, menu)

	return true
}

public transferMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new iData[6], iAccess, iCallback, iName[64];
        
	menu_item_getinfo(menu, item, iAccess, iData, charsmax (iData), iName, charsmax (iName), iCallback)
	new Key = str_to_num(iData)

	client_print_color(id, 0, "[^4CSO^3] ^3To be able to send money to ^4%s ^3type in ^4chat ^3desired ^4amount", getName(Key))
	client_print_color(id, 0, "[^4CSO^3] ^3In chat please type only ^4numbers^3. If you want to cancel, type ^3cancel")

	sendMoney[id] = Key

	return true
}

stock isNumeric(string[])
{
	for(new i = 0; i < strlen(string); i++)
		if(!isdigit(string[i]))
			return false

	return true
}