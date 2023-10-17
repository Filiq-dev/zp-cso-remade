#if defined notused
#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fakemeta>
#include <hamsandwich>
#include <xs>
#include <sqlx>
#include <zp_cso_custom>
#endif

/*

	Acest sistem este conceput pentru a salva informatii folositoare sau mai putin folositoare, precum
		- Kill-uri
		- Decese ( decesele, se pun decesele doar cand nu mai respawn-uri de la server ca si zm si la ct atunci cand mori direct nu te transformi in zombie )
		- Infectat ( de cate ori ai fost transformat in zombie )
		- Infectati ( kill la zombie )
		- Nemesis kills
		- Survivor kills

*/

static
	totalKills[MAX_PLAYERS + 1] = 0,
	totalDeaths[MAX_PLAYERS + 1] = 0,
	totalInfections[MAX_PLAYERS + 1] = 0,
	totalInfectedPlayers[MAX_PLAYERS + 1] = 0,
	totalNemesisKills[MAX_PLAYERS + 1] = 0,
	totalSurvivorKills[MAX_PLAYERS + 1] = 0,

	currentKills[MAX_PLAYERS + 1] = 0,
	currentDeaths[MAX_PLAYERS + 1] = 0,
	currentInfections[MAX_PLAYERS + 1] = 0,
	currentInfectedPlayers[MAX_PLAYERS + 1] = 0,
	currentNemesisKills[MAX_PLAYERS + 1] = 0,
	currentSurvivorKills[MAX_PLAYERS + 1] = 0
	
public loadStats(id, Handle:Query)
{
	if(GetBit(g_isbot, id))
		return

	totalKills[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "kills"))
	totalDeaths[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "deaths"))
	totalInfections[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "infections"))
	totalInfectedPlayers[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "infectedplayers"))
	totalNemesisKills[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "nemesiskills"))
	totalSurvivorKills[id] = SQL_ReadResult(Query, SQL_FieldNameToNum(Query, "survivorkills"))
}

public saveCurrentStats(id)
{
	new query[256]

	formatex(query, 256, "UPDATE `players` SET kills = kills + '%d', deaths = deaths + '%d', infections = infections + '%d',  infectedplayers = infectedplayers + '%d',  nemesiskills = nemesiskills + '%d',  survivorkills = survivorkills + '%d' WHERE id = '%d'", currentKills[id], currentDeaths[id], currentInfections[id], currentInfectedPlayers[id], currentNemesisKills[id], currentSurvivorKills[id], getUserID(id))
	SQL_ThreadQuery(g_sqltuple, "burnQuery", query)
}

public updateUserStats(victim, attacker)
{
	if(!GetBit(g_zombie, attacker)) // human kill
		totalKills[attacker] += 1

	if(GetBit(g_lasthuman, victim)) // last human get death not infected
		currentDeaths[victim] += 1

	if(GetBit(g_lastzombie, victim)) // last zombie get death 
		currentDeaths[victim] += 1

	if(GetBit(g_zombie, attacker)) // zombie infected somebody
	{
		currentInfections[victim] += 1
		currentInfectedPlayers[attacker] += 1
	}

	if(GetBit(g_nemesis, attacker)) // nemesis kill
	{
		currentDeaths[victim] += 1
		currentNemesisKills[attacker] += 1
	}

	if(GetBit(g_survivor, attacker))
		currentSurvivorKills[attacker] += 1
}