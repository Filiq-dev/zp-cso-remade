#include <amxmodx>
#include <sqlx>
#include <zp_cso_custom>
#include <hamsandwich>

#define PLUGIN "[CSO] Save data to SQL"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

#define DEBUG

new 
	Handle:g_SqlTuple,
	gQuery[256],
	bool:isUserLoaded[33]

public plugin_precache(){
	register_plugin(PLUGIN, VERSION, AUTHOR)

	g_SqlTuple = SQL_MakeDbTuple(host, user, pass, db)
}

public plugin_natives()
{
	register_native("is_user_loaded", "native_is_user_loaded", 1)
}

public client_putinserver(id)
{
	if(is_user_bot(id))
	{
		isUserLoaded[id] = true
		return
	}

	isUserLoaded[id] = false

	new data[1]
	data[0] = id

	formatex(gQuery, 65, "SELECT * FROM players WHERE name = '%s'", sql_getName(id))	
	SQL_ThreadQuery(g_SqlTuple, "checkAccount", gQuery, data, 2)
}

public client_disconnected(id)
{
	if(is_user_bot(id))
		return

	if(zp_get_user_level(id) == 0)
		return

	formatex(gQuery, 256,"UPDATE `players` SET lastip = '%s', money = '%d', xp = '%d', level = '%d' WHERE name = '%s'", getIP(id), zp_get_user_money(id), zp_get_user_exp(id), zp_get_user_level(id), sql_getName(id))
	SQL_ThreadQuery(g_SqlTuple, "burnQuery", gQuery)

	zp_level_reset(id)
	zp_money_reset(id)
}

public checkAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	new id = Data[0]

	if(SQL_NumResults(Query)) {
		new money = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "money"))
		zp_set_user_money(id, money)
		new level = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "level"))
		zp_set_user_level(id, level)
		new xp = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "xp"))
		zp_set_user_exp(id, xp)

		log_amx("loading data for %s", sql_getName(id))

		isUserLoaded[id] = true
	}else{
		formatex(gQuery, 90, "INSERT INTO players (name, lastip) VALUES ('%s', '%s')", sql_getName(id), getIP(id))	
		SQL_ThreadQuery(g_SqlTuple, "insertPlayer", gQuery, Data, DataSize)
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

	log_amx("inserting data for %s in db", sql_getName(id))

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