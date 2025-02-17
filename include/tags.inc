#if defined notused
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <zp_cso_custom>
#endif

static
	tagPlayer[33][30],
	query[100],
	wantLevel[33],
	wantTag[33]

static const say_team_info[2][CsTeams][] =
{
	{"*SPEC* ", "*DEAD* ", "*DEAD* ", "*SPEC* "},
	{"", "", "", ""}
}

static const sayteam_team_info[2][CsTeams][] =
{
	{"(Spectator) ", "*DEAD*(Terrorist) ", "*DEAD*(Counter-Terrorist) ", "(Spectator) "},
	{"(Spectator) ", "(Terrorist) ", "(Counter-Terrorist) ", "(Spectator) "}
}

public tags_init()
{
	register_clcmd("say", "HookSay")
	register_clcmd("say_team", "HookSayTeam")
}

public HookSay(id)
{
	static g_typed[192], g_message[192]

	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	if(equal(g_typed, "") || !GetBit(g_isconnected, id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix") || equal(g_typed, "/tag"))
	{
		showPrefixMenu(id)

		return PLUGIN_HANDLED_MAIN
	}

	if(equal(g_typed, "/tags"))
	{
		showTags(id)

		return PLUGIN_HANDLED_MAIN
	}

	if(tagPlayer[id][0])
	{
		formatex(g_message, charsmax(g_message), "^1%s%s^3 %s :^4 %s", say_team_info[is_user_alive(id)][cs_get_user_team(id)], getUserTag(id), getName(id), g_typed)
		
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(!GetBit(g_isconnected, i))
				continue

			send_message(g_message, id, i)
		}

		return PLUGIN_HANDLED_MAIN
	}

	return PLUGIN_CONTINUE
}

public HookSayTeam(id)
{
	static g_typed[192], g_message[192]

	read_args(g_typed, charsmax(g_typed))
	remove_quotes(g_typed)

	if(equal(g_typed, "") || !GetBit(g_isconnected, id))
		return PLUGIN_HANDLED_MAIN

	if(equal(g_typed, "/prefix") || equal(g_typed, "/tag"))
	{
		showPrefixMenu(id)

		return PLUGIN_HANDLED_MAIN
	}

	if(equal(g_typed, "/tags"))
	{
		showTags(id)

		return PLUGIN_HANDLED_MAIN
	}

	if(tagPlayer[id][0])
	{
		formatex(g_message, charsmax(g_message), "^1%s%s^3 %s :^4 %s", sayteam_team_info[is_user_alive(id)][cs_get_user_team(id)], getUserTag(id), getName(id), g_typed)
		
		for(new i = 1; i <= g_maxplayers; i++)
		{
			if(!GetBit(g_isconnected, i))
				continue

			if(get_user_team(id) == get_user_team(i))
			{
				send_message(g_message, id, i)
			}
		}

		return PLUGIN_HANDLED_MAIN
	}

	return PLUGIN_CONTINUE
}

public showTags(id)
{
	new data[1];
	data[0] = id

	formatex(query, charsmax(query), "SELECT * FROM `tags` WHERE name = '%s';", sql_getName(id))
	SQL_ThreadQuery(g_sqltuple, "showMenuQuery", query, data, 1)
}

public showMenuQuery(FailState, Handle:Query, error[], errorcode, data[], datasize, Float:fQueueTime)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
	else
	{
		new 
			menu = menu_create("Tags Menu | Zombie-Plague \w[\rCSO\w]", "setTagHandler"),
			id = data[0]

		static
			tagName[30],
			string[50],
			string2[55]

		while(SQL_MoreResults(Query)) 
		{
			SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "prefix"), tagName, charsmax(tagName))
			
			if(equali(tagPlayer[id], tagName))
				formatex(string2, charsmax(string2), "\r%s", tagName)
			else
				formatex(string2, charsmax(string2), "\w%s", tagName)

			formatex(string, charsmax(string), "%s", string2)
			menu_additem(menu, string, tagName)

			SQL_NextRow(Query)
		}

		menu_display(id, menu)
	}	
}

public setTagHandler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	new szData[31], szName[64]
	new _access, item_callback
	menu_item_getinfo(menu, item, _access, szData,charsmax(szData), szName,charsmax(szName), item_callback)

	copy(tagPlayer[id], 31, szData)
	showTags(id)

	return PLUGIN_HANDLED
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

public giveUserTag(id, const tag[])
{
	query[0] = (EOS)

	formatex(query, charsmax(query), "INSERT INTO `tags` (name, prefix) VALUES ('%s', '%s');", sql_getName(id), tag)
	SQL_ThreadQuery(g_sqltuple, "QuerySetData", query)
}

public QuerySetData(FailState, Handle:Query, error[],errcode, data[], datasize)
{
	if(FailState == TQUERY_CONNECT_FAILED || FailState == TQUERY_QUERY_FAILED)
	{
		log_amx("%s", error)
		return
	}
}

stock getUserTag(id)
{
	new tag[30], prefix[30], level[30]

	if(wantLevel[id]) 
	{
		formatex(level, charsmax(level), "^4[Level: %d]", zp_get_user_level(id))
		add(tag, charsmax(tag), level)
	}

	if(tagPlayer[id][0] && wantTag[id]) 
	{
		formatex(prefix, charsmax(prefix), "^4%s", tagPlayer[id])
		add(tag, charsmax(tag), prefix)
	}

	return tag
}

send_message(const message[], const id, const i)
{
	message_begin(MSG_ONE, g_msgSayText, {0, 0, 0}, i)
	write_byte(id)
	write_string(message)
	message_end()
}