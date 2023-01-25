#include <amxmodx>
#include <amxmisc>
#include <celltrie>
#include <cstrike>
#include <sqlx>
#include <zp_cso_custom>

#define VERSION "4.0 SQL"
#define FLAG_LOAD ADMIN_CFG
#define MAX_PREFIXES 33
#define MAX_BAD_PREFIXES 100

new g_bad_prefix, g_listen, g_listen_flag, g_custom, g_custom_flag, g_say_characters, g_prefix_characters;
new i, temp_cvar[2];
new col_prefix, col_key;
new g_saytxt, g_maxplayers, CsTeams:g_team;
new g_typed[192], g_message[192], g_name[32];
new Trie:pre_flags_collect, Trie:bad_prefixes_collect, Trie:client_prefix;
new str_id[16], temp_key[35], temp_prefix[32], temp_flag_key[2], temp_value, id;

new bool:mysql_connected = false, bool:data_ready = false, bool:data_badp_ready = false;
new Handle:g_sqltuple;
new query[512];

new bool:wantLevel[33], bool:wantTag[33];

new const say_team_info[2][CsTeams][] =
{
	{"*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* "},
	{"", "", "", ""}
}

new const sayteam_team_info[2][CsTeams][] =
{
	{"(Spectator) ", "*DEAD*(Terrorist) ", "*DEAD*(Counter-Terrorist) ", "(Spectator) "},
	{"(Spectator) ", "(Terrorist) ", "(Counter-Terrorist) ", "(Spectator) "}
}

new const forbidden_say_symbols[] = {
	"/",
	"!",
	"%",
	"$"
}

new const forbidden_prefixes_symbols[] = {
	"/",
	"\",
	"%",
	"$",
	".",
	":",
	"?",
	"!",
	"@",
	"#",
	"%"
}

new const separator[] = "************************************************"
new const in_prefix[] = "[AdminPrefixes]"

public plugin_init()
{
	register_plugin("[CSO] Admin Prefixes", VERSION, "m0skVi4a ;] & Filiq_")

	g_bad_prefix = register_cvar("ap_bad_prefixes", "1")
	g_listen = register_cvar("ap_listen", "1")
	g_listen_flag = register_cvar("ap_listen_flag", "a")
	g_custom = register_cvar("ap_custom_current", "1")
	g_custom_flag = register_cvar("ap_custom_current_flag", "b")
	g_say_characters = register_cvar("ap_say_characters", "1")
	g_prefix_characters = register_cvar("ap_prefix_characters", "1")

	g_saytxt = get_user_msgid ("SayText")
	g_maxplayers = get_maxplayers()

	register_concmd("ap_reload_prefixes", "LoadFlagsPrefixes")
	register_concmd("ap_reload_bad_prefixes", "LoadBadPrefixes")
	register_concmd("ap_put", "SetPlayerPrefix")

	register_clcmd("say", "HookSay")
	register_clcmd("say_team", "HookSayTeam")

	pre_flags_collect = TrieCreate()
	bad_prefixes_collect = TrieCreate()
	client_prefix = TrieCreate()

	register_dictionary("cso.txt")

	set_task(0.5, "Init_MYSQL")
}

public Init_MYSQL()
{
	g_sqltuple = SQL_MakeDbTuple(host, user, pass, db)
	formatex(query, charsmax(query), "CREATE TABLE IF NOT EXISTS ap_prefixes (Type_fisn VARCHAR(2), Key_fisn VARCHAR(35), Prefix VARCHAR(32)) ; CREATE TABLE IF NOT EXISTS ap_bad_prefixes (Prefix VARCHAR(32))")
	SQL_ThreadQuery(g_sqltuple, "QueryCreateTable", query)
}

public QueryCreateTable(failstate, Handle:query, error[], errcode, data[], datasize, Float:queuetime)
{
	if(failstate == TQUERY_CONNECT_FAILED)
	{
		set_fail_state("[ADMIN PREFIXES] Could not connect to database!")
	}
	else if(failstate == TQUERY_QUERY_FAILED)
	{
		set_fail_state("[ADMIN PREFIXES] Query failed!")
	}
	else if(errcode)
	{
		server_print("%s Error on query: %s", in_prefix, error)
	}
	else
	{
		server_print("%s MYSQL connection succesful!", in_prefix)
		mysql_connected = true
		LoadFlagsPrefixes(0)
		LoadBadPrefixes(0)
	}	
}

public LoadFlagsPrefixes(id)
{
	if(!mysql_connected)
		return PLUGIN_HANDLED

	if(!(get_user_flags(id) & FLAG_LOAD))
	{
		console_print(id, "%L", LANG_SERVER, "PREFIX_PERMISSION", in_prefix)
		return PLUGIN_HANDLED
	}

	data_ready = false
	TrieClear(pre_flags_collect)

	new data[1];
	data[0] = id

	formatex(query, charsmax(query), "SELECT * FROM `ap_prefixes` WHERE Type_fisn = ^"f^";")
	SQL_ThreadQuery(g_sqltuple, "QueryLoadFlagPrefixes", query, data, 1)

	return PLUGIN_HANDLED
}

public QueryLoadFlagPrefixes(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		id = data[0]
		col_key = SQL_FieldNameToNum(Query, "Key_fisn")
		col_prefix = SQL_FieldNameToNum(Query, "Prefix")

		server_print(separator)
		
		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_key, temp_key, charsmax(temp_key))
			SQL_ReadResult(Query, col_prefix, temp_prefix, charsmax(temp_prefix))
			formatex(temp_flag_key, charsmax(temp_flag_key), "%c", temp_key)
			TrieSetString(pre_flags_collect, temp_flag_key, temp_prefix)
			server_print("%L", LANG_SERVER, "PREFIX_LOAD_FLAG", in_prefix, temp_prefix, temp_flag_key)
			SQL_NextRow(Query)
		}

		data_ready = true

		if(col_prefix <= 0)
		{
			server_print("%L", LANG_SERVER, "PREFIX_LOAD_NOFLAG", in_prefix)
		}

		get_user_name(id, g_name, charsmax(g_name))
		server_print("%L", LANG_SERVER, "PREFIX_LOADED_BY", in_prefix, g_name)
		console_print(id, "%L", LANG_SERVER, "PREFIX_LOADED", in_prefix)

		server_print(separator)

		for(new i = 1; i <= g_maxplayers; i++)
		{
			num_to_str(i, str_id, charsmax(str_id))
			TrieSetString(client_prefix, str_id, "")
			PutPrefix(i)
		}
	}	
}

public LoadBadPrefixes(id)
{
	if(!mysql_connected)
		return PLUGIN_HANDLED
		
	if(!get_pcvar_num(g_bad_prefix))
	{
		console_print(id, "%L", LANG_SERVER, "BADP_OFF", in_prefix)
		return PLUGIN_HANDLED
	}

	if(!(get_user_flags(id) & FLAG_LOAD))
	{
		console_print(id, "%L", LANG_SERVER, "BADP_PERMISSION", in_prefix)
		return PLUGIN_HANDLED
	}

	data_badp_ready = false
	TrieClear(bad_prefixes_collect)

	new data[1];
	data[0] = id

	formatex(query, charsmax(query), "SELECT * FROM `ap_bad_prefixes`;")
	SQL_ThreadQuery(g_sqltuple, "QueryLoadBadPrefixes", query, data, 1)

	return PLUGIN_HANDLED
}

public QueryLoadBadPrefixes(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		id = data[0]
		col_prefix = SQL_FieldNameToNum(Query, "Prefix")

		server_print(separator)

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_prefix, temp_prefix, charsmax(temp_prefix))

			TrieSetCell(bad_prefixes_collect, temp_prefix, 1)
			server_print("%L", LANG_SERVER, "BADP_LOAD", in_prefix, temp_prefix)

			SQL_NextRow(Query)
		}

		data_badp_ready = true

		if(col_prefix <= 0)
		{
			server_print("%L", LANG_SERVER, "BADP_NO", in_prefix)
		}

		get_user_name(id, g_name, charsmax(g_name))
		server_print("%L", LANG_SERVER, "BADP_LOADED_BY", in_prefix, g_name)
		console_print(id, "%L", LANG_SERVER, "BADP_LOADED", in_prefix)

		server_print(separator)
	}
}

public client_putinserver(id)
{
	wantTag[id] = true
	wantLevel[id] = true

	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")
	PutPrefix(id)
}

public HookSay(id)
{
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	if(equal(g_typed, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix") || equal(g_typed, "/tag"))
	{
		showPrefixMenu(id)

		return PLUGIN_HANDLED_MAIN
	}

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
	{
		if(check_say_characters(g_typed))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, g_name, charsmax(g_name))

	g_team = cs_get_user_team(id)

	if(temp_prefix[0])
	{
		formatex(g_message, charsmax(g_message), "^1%s%s^3 %s :^4 %s", say_team_info[is_user_alive(id)][g_team], getUserTag(id), g_name, g_typed)
	}
	else
	{
		formatex(g_message, charsmax(g_message), "^1%s^4[Level: %d] ^3%s :^1 %s", say_team_info[is_user_alive(id)][g_team], zp_get_user_level(id), g_name, g_typed)
	}

	get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue

		if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
		{
			send_message(g_message, id, i)
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public HookSayTeam(id)
{
	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	if(equal(g_typed, "") || !is_user_connected(id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix") || equal(g_typed, "/tag"))
	{
		showPrefixMenu(id)

		return PLUGIN_HANDLED_MAIN
	}

	num_to_str(id, str_id, charsmax(str_id))

	if((TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 1) || (!TrieGetString(client_prefix, str_id, temp_prefix, charsmax(temp_prefix)) && get_pcvar_num(g_say_characters) == 2) || get_pcvar_num(g_say_characters) == 3)
	{
		if(check_say_characters(g_typed))
			return PLUGIN_HANDLED_MAIN
	}

	get_user_name(id, g_name, charsmax(g_name))

	g_team = cs_get_user_team(id)

	if(temp_prefix[0])
	{
		formatex(g_message, charsmax(g_message), "^1%s^4%s^3 %s :^4 %s", sayteam_team_info[is_user_alive(id)][g_team], getUserTag(id), g_name, g_typed)
	}
	else
	{
		formatex(g_message, charsmax(g_message), "^1%s^4[Level: %d] ^3%s :^1 %s", sayteam_team_info[is_user_alive(id)][g_team], zp_get_user_level(id), g_name, g_typed)
	}

	get_pcvar_string(g_listen_flag, temp_cvar, charsmax(temp_cvar))

	for(new i = 1; i <= g_maxplayers; i++)
	{
		if(!is_user_connected(i))
			continue

		if(get_user_team(id) == get_user_team(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
		{
			if(is_user_alive(id) && is_user_alive(i) || !is_user_alive(id) && !is_user_alive(i) || get_pcvar_num(g_listen) && get_user_flags(i) & read_flags(temp_cvar))
			{
				send_message(g_message, id, i)
			}
		}
	}

	return PLUGIN_HANDLED_MAIN
}

public showPrefixMenu(id)
{
	new 
		string[40],
		menu = menu_create("Prefix Menu | Zombie-Plague \w[\rCSO\w]", "prefixMenuHandler")

	formatex(string, charsmax(string), "Level \y[%s]", wantLevel[id] ? "ON" : "OFF")
	menu_additem(menu, string)

	formatex(string, charsmax(string), "Tag \y[%s]", wantTag[id] ? "ON" : "OFF")
	menu_additem(menu, string)
	
	menu_display (id, menu)

	return PLUGIN_CONTINUE
}

public prefixMenuHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}
	
	switch(item)
	{
		case 0: wantLevel[id] = !wantLevel[id]
		case 1: wantTag[id] = !wantTag[id]
	}

	showPrefixMenu(id)

	return PLUGIN_CONTINUE
}

public SetPlayerPrefix(id)
{
	if(!mysql_connected || !data_ready || !data_badp_ready)
		return PLUGIN_HANDLED

	if(!get_pcvar_num(g_custom) || !get_pcvar_string(g_custom_flag, temp_cvar, charsmax(temp_cvar)))
	{
		console_print(id, "%L", LANG_SERVER, "CO_OFF", in_prefix)
		return PLUGIN_HANDLED
	}

	if(!(get_user_flags(id) & read_flags(temp_cvar)))
	{
		console_print(id, "%L", LANG_SERVER, "CO_FORBIDDEN", in_prefix)
		return PLUGIN_HANDLED
	}

	new input[128], target;
	new arg_type[2], arg_prefix[32], arg_key[35];
	new temp_str[16];

	read_args(input, charsmax(input))
	remove_quotes(input)
	parse(input, arg_type, charsmax(arg_type), arg_key, charsmax(arg_key), arg_prefix, charsmax(arg_prefix))
	trim(arg_prefix)

	if(get_pcvar_num(g_bad_prefix) && is_bad_prefix(arg_prefix) && !equali(arg_prefix, ""))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_FORBIDDEN", in_prefix, arg_prefix)
		return PLUGIN_HANDLED
	}

	if(get_pcvar_num(g_prefix_characters) && check_prefix_characters(arg_prefix))
	{
		console_print(id, "%L", LANG_SERVER, "CUSTOM_SYMBOL", in_prefix, arg_prefix, forbidden_prefixes_symbols[i])
		return PLUGIN_HANDLED
	}

	switch(arg_type[0])
	{
		case 'f':
		{
			target = 0
			temp_str = "Flag"
		}
		case 'i':
		{
			target = find_player("d", arg_key)
			temp_str = "IP"
		}
		case 's':
		{
			target = find_player("c", arg_key)
			temp_str = "SteamID"
		}
		case 'n':
		{
			target = find_player("a", arg_key)
			temp_str = "Name"
		}
		default:
		{
			console_print(id, "%s You typed an invalid prefix type - ^"%s^". Types you can use: ^"f^" - flags, ^"i^" - IP, ^"s^" - SteamID, ^"n^" - Name", in_prefix, arg_type)
			return PLUGIN_HANDLED
		}
	}

	get_user_name(id, g_name, charsmax(g_name))

	if(equali(arg_prefix, ""))
	{
		formatex(query, charsmax(query), "DELETE FROM `ap_prefixes` WHERE Type_fisn = ^"%s^" AND Key_fisn = ^"%s^";", arg_type, arg_key)
		SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
		
		if(equal(arg_type[0], "f"))
		{
			TrieSetString(pre_flags_collect, arg_key, "")
		}

		if(target)
		{
			PutPrefix(target)
		}
		else
		{
			for(new i = 1; i <= g_maxplayers; i++)
			{
				num_to_str(i, str_id, charsmax(str_id))
				TrieSetString(client_prefix, str_id, "")
				PutPrefix(i)
			}
		}

		console_print(id, "%s You have successfully removed %s ^"%s^"'s Custom Prefix.", in_prefix, temp_str, arg_key)
		server_print("%s Player %s removed %s ^"%s^"'s Custom Prefix.", in_prefix, g_name, temp_str, arg_key)
		return PLUGIN_HANDLED
	}

	formatex(query, charsmax(query), "DELETE FROM `ap_prefixes` WHERE Type_fisn = ^"%s^" AND Key_fisn = ^"%s^";", arg_type, arg_key)
	SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)

	formatex(query, charsmax(query), "INSERT INTO `ap_prefixes` (Type_fisn, Key_fisn, Prefix) VALUES (^"%s^", ^"%s^", ^"%s^");", arg_type, arg_key, arg_prefix)
	SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)

	if(equal(arg_type[0], "f"))
	{
		TrieSetString(pre_flags_collect, arg_key, arg_prefix)
	}

	if(target)
	{
		num_to_str(target, str_id, charsmax(str_id))
		TrieSetString(client_prefix, str_id, arg_prefix)
	}
	else
	{
		for(new i = 1; i <= g_maxplayers; i++)
		{
			num_to_str(i, str_id, charsmax(str_id))
			TrieSetString(client_prefix, str_id, "")
			PutPrefix(i)
		}
	}

	console_print(id, "%s You have successfully changed %s ^"%s^"'s Custom Prefix to - %s", in_prefix, temp_str, arg_key, arg_prefix)
	server_print("%s Player %s changed %s ^"%s^"'s Custom Prefix to - %s", in_prefix, g_name, temp_str, arg_key, arg_prefix) 

	return PLUGIN_HANDLED
}

public giveTag(id, const arg_prefix[])
{
	if(!mysql_connected || !data_ready || !data_badp_ready)
		return PLUGIN_HANDLED

	if(!get_pcvar_num(g_custom) || !get_pcvar_string(g_custom_flag, temp_cvar, charsmax(temp_cvar)))
		return PLUGIN_HANDLED

	if(!(get_user_flags(id) & read_flags(temp_cvar)))
		return PLUGIN_HANDLED

	if(get_pcvar_num(g_bad_prefix) && is_bad_prefix(arg_prefix) && !equali(arg_prefix, ""))
	{
		server_print("%L", LANG_SERVER, "CUSTOM_FORBIDDEN", in_prefix, arg_prefix)
		return PLUGIN_HANDLED
	}

	if(get_pcvar_num(g_prefix_characters) && check_prefix_characters(arg_prefix))
	{
		server_print("%L", LANG_SERVER, "CUSTOM_SYMBOL", in_prefix, arg_prefix, forbidden_prefixes_symbols[i])
		return PLUGIN_HANDLED
	}
	get_user_name(id, g_name, charsmax(g_name))

	formatex(query, charsmax(query), "INSERT INTO `ap_prefixes` (Type_fisn, Key_fisn, Prefix) VALUES (^"n^", ^"name^", ^"%s^");", arg_prefix)
	SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)

	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, arg_prefix)

	return PLUGIN_HANDLED
}


public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
}

public client_infochanged(id)
{
	if(!is_user_connected(id))
		return PLUGIN_CONTINUE

	new g_old_name[32];

	get_user_info(id, "name", g_name, charsmax(g_name))
	get_user_name(id, g_old_name, charsmax(g_old_name))

	if(!equal(g_name, g_old_name))
	{
		num_to_str(id, str_id, charsmax(str_id))
		TrieSetString(client_prefix, str_id, "")
		set_task(0.5, "PutPrefix", id)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public PutPrefix(id)
{
	if(!mysql_connected || !data_ready)
		return PLUGIN_HANDLED

	num_to_str(id, str_id, charsmax(str_id))
	TrieSetString(client_prefix, str_id, "")

	new sflags[32], temp_flag[2];
	get_flags(get_user_flags(id), sflags, charsmax(sflags))

	for(new i = 0; i <= charsmax(sflags); i++)
	{
		formatex(temp_flag, charsmax(temp_flag), "%c", sflags[i])

		if(TrieGetString(pre_flags_collect, temp_flag, temp_prefix, charsmax(temp_prefix)))
		{
			TrieSetString(client_prefix, str_id, temp_prefix)
		}
	}

	new data[1];
	data[0] = id

	get_user_ip(id, temp_key, charsmax(temp_key), 1)
	formatex(query, charsmax(query), "SELECT `Prefix` FROM `ap_prefixes` WHERE Type_fisn = ^"i^" AND Key_fisn = ^"%s^";", temp_key)
	SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)

	get_user_authid(id, temp_key, charsmax(temp_key))
	formatex(query, charsmax(query), "SELECT `Prefix` FROM `ap_prefixes` WHERE Type_fisn = ^"s^" AND Key_fisn = ^"%s^";", temp_key)
	SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)

	get_user_name(id, temp_key, charsmax(temp_key))
	formatex(query, charsmax(query), "SELECT `Prefix` FROM `ap_prefixes` WHERE Type_fisn = ^"n^" AND Key_fisn = ^"%s^";", temp_key)
	SQL_ThreadQuery(g_sqltuple, "QuerySelectData", query, data, 1)

	return PLUGIN_HANDLED
}

public QuerySelectData(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{ 
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		id = data[0];
		col_prefix = SQL_FieldNameToNum(Query, "Prefix")

		num_to_str(id, str_id, charsmax(str_id))

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, col_prefix, temp_prefix, charsmax(temp_prefix))
			TrieSetString(client_prefix, str_id, temp_prefix)
			SQL_NextRow(Query)
		}
	}
}

send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, g_saytxt, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}

bool:check_say_characters(const check_message[])
{
	for(new i = 0; i < charsmax(forbidden_say_symbols); i++)
	{
		if(check_message[0] == forbidden_say_symbols[i])
		{
			return true
		}
	}
	return false
}

bool:check_prefix_characters(const check_prefix[])
{
	for(i = 0; i < charsmax(forbidden_prefixes_symbols); i++)
	{
		if(containi(check_prefix, forbidden_prefixes_symbols[i]) != -1)
		{
			return true
		}
	}
	return false
}

bool:is_bad_prefix(const check_prefix[])
{
	if(TrieGetCell(bad_prefixes_collect, check_prefix, temp_value))
	{
		return true
	}
	return false
}

public getUserTag(id)
{
	new tag[30], prefix[30], level[30]

	if(wantLevel[id]) 
	{
		formatex(level, charsmax(level), "^4[Level: %d]", zp_get_user_level(id))
		add(tag, charsmax(tag), level)
	}

	if(temp_prefix[0] && wantTag[id]) 
	{
		formatex(prefix, charsmax(prefix), "^4%s", temp_prefix)
		add(tag, charsmax(tag), prefix)
	}

	return tag
}