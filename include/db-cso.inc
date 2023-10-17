#if defined notused
#include <amxmodx>
#include <sqlx>
#include <zp_cso_custom>
#include <hamsandwich>
#endif

static 
	bool:isUserLoaded[MAX_PLAYERS + 1],
	gQuery[256],
	userID[MAX_PLAYERS + 1]

public dbcso_natives()
{
	register_native("is_user_loaded", "native_is_user_loaded", 1)
	register_native("save_data_remote", "native_save_data_remote", 1)
}

public sql_precache()
{
	g_sqltuple = SQL_MakeDbTuple("191.96.94.200", "u126_bDuPyF4XTy", "AyfzvFhmwsADRI@saa!NxRny", "s126_zmeasy")

	if(!g_sqltuple)
	{
		server_print("nu merge baza de date")
		log_error(1, "Nu se poate conecta la baza de date, se opreste tot serverul")
		server_cmd("exit")
		server_exec()
	}

	return true
}

public dbcso_end()
{
	for(new id = 1; id <= g_maxplayers; id++)
	{
		if(!GetBit(g_isconnected, id))
			continue

		saveData(id)
	}
}

public dbcso_putinserver(id)
{
	if(is_user_bot(id))
	{
		isUserLoaded[id] = true
		return
	}

	userID[id] = 0
	
	zp_level_reset(id)
	zp_money_reset(id)

	if(gameplay_active() != -1)
		loadFromSQL(id)
}

public dbcso_disconnected(id)
{
	if(is_user_bot(id))
		return

	if(task_exists(id+252525))
		remove_task(id+252525)

	if(zp_get_user_level(id) == 0)
		return

	saveData(id)
}

public beginLoadDataSQL()
{
	// Aragon*/DaNNe.
	new Players[32], PlayersNum, id
	get_players(Players, PlayersNum)

	if(PlayersNum) 
	{
		for(new i; i < PlayersNum; i++) 
		{
			id = Players[i]

			if(GetBit(g_isconnected, id) && !is_user_bot(id)) 
			{
				switch(id) 
				{
					case 1..7: set_task(1.0, "loadDataSQL", id+252525)
					case 8..15: set_task(3.0, "loadDataSQL", id+252525)
					case 16..23: set_task(6.0, "loadDataSQL", id+252525)
					case 24..32: set_task(9.0, "loadDataSQL", id+252525)
				}
			}
		}
	}
}

public loadDataSQL(id) {
	loadFromSQL(id - 252525)
}	

public loadFromSQL(id)
{
	if(is_user_connected(id))
	{
		isUserLoaded[id] = false

		new data[1]
		data[0] = id

		formatex(gQuery, 65, "SELECT * FROM players WHERE name = '%s'", sql_getName(id))	
		SQL_ThreadQuery(g_sqltuple, "checkAccount", gQuery, data, 2)
	}
}

public saveData(id)
{
	formatex(gQuery, 256,"UPDATE `players` SET lastip = '%s', money = '%d', xp = '%d', level = '%d' WHERE id = '%d'", getIP(id), zp_get_user_money(id), zp_get_user_exp(id), zp_get_user_level(id), getUserID(id))
	SQL_ThreadQuery(g_sqltuple, "burnQuery", gQuery)

	return true
}

public checkAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	new id = Data[0]

	if(SQL_NumResults(Query)) {
		userID[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "id"))

		new money = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "money"))
		zp_set_user_money(id, money)
		
		new level = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "level"))
		zp_set_user_level(id, level)
		
		new xp = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "xp"))
		zp_set_user_exp(id, xp)

		#if defined STATS_SYSTEM
			loadStats(id, Query)
		#endif

		isUserLoaded[id] = true
	}else{
		formatex(gQuery, 90, "INSERT INTO players (name, lastip) VALUES ('%s', '%s')", sql_getName(id), getIP(id))	
		SQL_ThreadQuery(g_sqltuple, "insertPlayer", gQuery, Data, DataSize)
	}

	return PLUGIN_CONTINUE
}

public insertPlayer(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	new id = Data[0]

	zp_set_user_money(id, get_cvar_num("ms_default_money"))
	zp_set_user_level(id, 1)

	isUserLoaded[id] = true

	return PLUGIN_CONTINUE
}

public burnQuery(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}

public native_is_user_loaded(id)
{
	return isUserLoaded[id]
}

public native_save_data_remote(id)
{
	return saveData(id)
}

public mysql_escape_string(dest[], len)
{
    //copy(dest, len, source);
    replace_all(dest, len, "\\", "\\\\")
    replace_all(dest, len, "\0", "\\0")
    replace_all(dest, len, "\n", "\\n")
    replace_all(dest, len, "\r", "\\r")
    replace_all(dest, len, "\x1a", "\Z")
    replace_all(dest, len, "'", "\'")
    replace_all(dest, len, "^"", "\^"")
}

stock sql_getName(id)
{
	new name[96]

	get_user_name(id, name, charsmax(name))
	mysql_escape_string(name, charsmax(name))

	return name
}

public isUserLoadedDB(id)
{
	return isUserLoaded[id]
}

stock getUserID(id)
{
	if(!isUserLoaded[id])
	{
		log_amx("getUserID(%d): Am incercat preluarea unui id din baza de date si jucatorul nu indeplineste conditiile. (db-cso.inc)", id)
		return -1
	}

	return userID[id]
}