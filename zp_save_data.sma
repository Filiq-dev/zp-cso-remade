#include <amxmodx>
#include <sqlx>
#include <zp_cso_custom>

#define PLUGIN "[ZP] Save data to SQL"
#define VERSION "1.0"
#define AUTHOR "Filiq_"

new 
	Handle:g_SqlTuple,
	gQuery[256]

public plugin_precache(){
	register_plugin(PLUGIN, VERSION, AUTHOR)

	sql_init()
}

public sql_init(){
	new host[128]
	new user[64]
	new pass[64]
	new database[64]
	new db_type[16]

	get_cvar_string("amx_sql_type", db_type, 15)
	SQL_SetAffinity(db_type)
	get_cvar_string("amx_sql_db", database, 63)
	get_cvar_string("amx_sql_host", host, 127)
	get_cvar_string("amx_sql_user", user, 63)
	get_cvar_string("amx_sql_pass", pass, 63)

	g_SqlTuple = SQL_MakeDbTuple(host, user, pass, database)
}

public client_putinserver(id)
{
	if(is_user_bot(id))
		return

	set_task(1.0, "load", id)
}

public client_disconnect(id)
{
	if(is_user_bot(id))
		return

	formatex(gQuery, 256,"UPDATE `players` SET lastip = '%s', money = '%d', xp = '%d', level = '%d' WHERE name = '%s'", getIP(id), zp_get_user_money(id), zp_get_user_exp(id), zp_get_user_level(id), getName(id))
	SQL_ThreadQuery(g_SqlTuple, "burnQuery", gQuery)
}

public load(id)
{
	if(!is_user_connected(id))
		return

	new data[2]
	data[0] = id

	formatex(gQuery, 50, "SELECT * FROM players WHERE name = '%s'", getName(id))	
	SQL_ThreadQuery(g_SqlTuple, "checkAccount", gQuery, data, 2)
}

public checkAccount(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	new id = Data[0]

	if(SQL_MoreResults(Query)) {
		new money = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "money"))
		zp_set_user_money(id, money)
		new level = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "level"))
		zp_set_user_level(id, level)
		new xp = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "xp"))
		zp_set_user_exp(id, xp)


	}else{
		formatex(gQuery, 90, "INSERT INTO players (name, lastip) VALUES ('%s', '%s')", getName(id), getIP(id))	
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

	return PLUGIN_CONTINUE
}

public burnQuery(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
