#include <amxmodx>
#include <sqlx>
#include <zp_cso_custom>
#include <hamsandwich>

#define PLUGIN "[CSO] Save data to SQL"
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

	g_SqlTuple = SQL_MakeDbTuple("localhost", "root", "", "server")

}

public client_putinserver(id)
{
	if(is_user_bot(id))
		return

	load(id)
}

public client_disconnect(id)
{
	if(is_user_bot(id))
		return

	if(zp_get_user_level(id) == 0)
		return

	formatex(gQuery, 256,"UPDATE `players` SET lastip = '%s', money = '%d', xp = '%d', level = '%d' WHERE name = '%s'", getIP(id), zp_get_user_money(id), zp_get_user_exp(id), zp_get_user_level(id), getName(id))
	SQL_ThreadQuery(g_SqlTuple, "burnQuery", gQuery)

	zp_level_reset(id)
	zp_money_reset(id)
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

	if(SQL_NumResults(Query)) {
		new money = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "money"))
		zp_set_user_money(id, money)
		new level = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "level"))
		zp_set_user_level(id, level)
		new xp = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "xp"))
		zp_set_user_exp(id, xp)

		log_amx("loading data for %s", getName(id))
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

	log_amx("inserting data for %s in db", getName(id))

	return PLUGIN_CONTINUE
}

public burnQuery(FailState, Handle:Query, Error[], Errcode, Data[], DataSize){
	if(FailState){
		log_amx("SQL Error: %s (%d)", Error, Errcode)
		return PLUGIN_HANDLED
	}

	return PLUGIN_CONTINUE
}
