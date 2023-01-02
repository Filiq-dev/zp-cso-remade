#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <zombieplague>

// Zombie Attributes
new const zclass_name[] = "Deimos Zombie" // name
new const zclass_info[] = "[G -> Drop Human Weapon]" // description
new const zclass_model[] = "deimos_zombi_origin" // model
new const zclass_clawmodel[] = "v_knife_deimos_zombi.mdl" // claw model
const zclass_health = 12000 // health
const zclass_speed = 280 // speed
const Float:zclass_gravity = 1.0 // gravity
const Float:zclass_knockback = 1.0 // knockback

new g_zclass_deimos
new bool:can_use_skill[33]

new trail_spr
new exp_spr

const m_flTimeWeaponIdle = 48
const m_flNextAttack = 83

new const light_classname[] = "deimos_skill"
new const skill_start[] = "zombie_plague/deimos_skill_start.wav"
new const skill_hit[] = "zombie_plague/deimos_skill_hit.wav"

#define TASK_WAIT 11111
#define TASK_ATTACK 22222
#define TASK_COOLDOWN 33333

const WPN_NOT_DROP = ((1<<2)|(1<<CSW_HEGRENADE)|(1<<CSW_SMOKEGRENADE)|(1<<CSW_FLASHBANG)|(1<<CSW_KNIFE)|(1<<CSW_C4))

new cvar_cooldown


public plugin_init()
{
	register_plugin("[ZP] Zombie Class: Deimos", "1.0", "Dias")
	
	cvar_cooldown = register_cvar("zp_deimos_cooldown", "30")
	
	register_forward(FM_Touch, "fw_Touch")
	register_clcmd("drop", "use_skill")
}

public plugin_precache()
{
	trail_spr = precache_model("sprites/zb3/trail.spr")
	exp_spr = precache_model("sprites/zb3/deimosexp.spr")
	
	precache_sound(skill_start)
	precache_sound(skill_hit)
	
	g_zclass_deimos = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)	
}

public zp_user_infected_post(id, infector)
{
	if (zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclass_deimos)
	{
		can_use_skill[id] = true
		client_print(id, print_chat, "[ZP] You are Deimos Zombie, Aim and Press (G) to Drop Human Weapon")
	}
}

public use_skill(id)
{
	if (zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclass_deimos && !zp_get_user_nemesis(id))
	{
		if(can_use_skill[id])
		{
			do_skill(id)
			can_use_skill[id] = false
		} else {
			client_print(id, print_chat, "[ZP] You can't use your skill now...")
		}
	}
}

public do_skill(id)
{
	play_weapon_anim(id, 8)
	set_weapons_timeidle(id, 7.0)
	set_player_nextattack(id, 0.5)
	PlayEmitSound(id, skill_start)
	entity_set_int(id, EV_INT_sequence, 10)

	set_task(0.5, "launch_light", id+TASK_ATTACK)
}

public launch_light(taskid)
{
	new id = taskid - TASK_ATTACK
	if (task_exists(id+TASK_ATTACK)) remove_task(id+TASK_ATTACK)
	
	if (!is_user_alive(id)) return;
	
	// check
	new Float: fOrigin[3], Float:fAngle[3],Float: fVelocity[3]
	pev(id, pev_origin, fOrigin)
	pev(id, pev_view_ofs, fAngle)
	fm_velocity_by_aim(id, 2.0, fVelocity, fAngle)
	fAngle[0] *= -1.0
	
	// create ent
	new ent = engfunc(EngFunc_CreateNamedEntity, engfunc(EngFunc_AllocString, "info_target"))
	set_pev(ent, pev_classname, light_classname)
	engfunc(EngFunc_SetModel, ent, "models/w_hegrenade.mdl")
	set_pev(ent, pev_mins, Float:{-1.0, -1.0, -1.0})
	set_pev(ent, pev_maxs, Float:{1.0, 1.0, 1.0})
	set_pev(ent, pev_origin, fOrigin)
	fOrigin[0] += fVelocity[0]
	fOrigin[1] += fVelocity[1]
	fOrigin[2] += fVelocity[2]
	set_pev(ent, pev_movetype, MOVETYPE_BOUNCE)
	set_pev(ent, pev_gravity, 0.01)
	fVelocity[0] *= 1000
	fVelocity[1] *= 1000
	fVelocity[2] *= 1000
	set_pev(ent, pev_velocity, fVelocity)
	set_pev(ent, pev_owner, id)
	set_pev(ent, pev_angles, fAngle)
	set_pev(ent, pev_solid, SOLID_BBOX)						//store the enitty id
	
	// invisible ent
	fm_set_rendering(ent, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)
	
	// show trail	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY )
	write_byte(TE_BEAMFOLLOW)
	write_short(ent)				//entity
	write_short(trail_spr)		//model
	write_byte(5)		//10)//life
	write_byte(3)		//5)//width
	write_byte(209)					//r, hegrenade
	write_byte(120)					//g, gas-grenade
	write_byte(9)					//b
	write_byte(200)		//brightness
	message_end()					//move PHS/PVS data sending into here (SEND_ALL, SEND_PVS, SEND_PHS)
	
	client_print(id, print_chat, "[ZP] You have to wait %i seconds to continue use skill !!!", get_pcvar_num(cvar_cooldown))
	set_task(get_pcvar_float(cvar_cooldown), "reset_cooldown", id+TASK_COOLDOWN)
	
	return;
}

public reset_cooldown(taskid)
{
	new id = taskid - TASK_COOLDOWN
	
	if (zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclass_deimos && !zp_get_user_nemesis(id))
	{
		can_use_skill[id] = true
		client_print(id, print_chat, "[ZP] Now. You can use your skill. Aim and Press (G)")
	}
}

public fw_Touch(ent, victim)
{
	if (!pev_valid(ent)) return FMRES_IGNORED
	
	new EntClassName[32]
	entity_get_string(ent, EV_SZ_classname, EntClassName, charsmax(EntClassName))
	
	if (equal(EntClassName, light_classname)) 
	{
		light_exp(ent, victim)
		remove_entity(ent)
		return FMRES_IGNORED
	}
	
	return FMRES_IGNORED
}

light_exp(ent, victim)
{
	if (!pev_valid(ent)) return;
	
	if (is_user_alive(victim) && !zp_get_user_zombie(victim) && !zp_get_user_survivor(victim))
	{
		new wpn, wpnname[32]
		wpn = get_user_weapon(victim)
		if( !(WPN_NOT_DROP & (1<<wpn)) && get_weaponname(wpn, wpnname, charsmax(wpnname)) )
		{
			engclient_cmd(victim, "drop", wpnname)
		}
	}
	
	// create effect
	static Float:origin[3];
	pev(ent, pev_origin, origin);
	message_begin(MSG_BROADCAST,SVC_TEMPENTITY); 
	write_byte(TE_EXPLOSION); // TE_EXPLOSION
	write_coord(floatround(origin[0])); // origin x
	write_coord(floatround(origin[1])); // origin y
	write_coord(floatround(origin[2])); // origin z
	write_short(exp_spr); // sprites
	write_byte(40); // scale in 0.1's
	write_byte(30); // framerate
	write_byte(14); // flags 
	message_end(); // message end
	
	// play sound exp
	PlayEmitSound(ent, skill_hit)
}

PlayEmitSound(id, const sound[])
{
	emit_sound(id, CHAN_WEAPON, sound, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

play_weapon_anim(player, anim)
{
	set_pev(player, pev_weaponanim, anim)
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, player)
	write_byte(anim)
	write_byte(pev(player, pev_body))
	message_end()
}

fm_velocity_by_aim(iIndex, Float:fDistance, Float:fVelocity[3], Float:fViewAngle[3])
{
	//new Float:fViewAngle[3]
	pev(iIndex, pev_v_angle, fViewAngle)
	fVelocity[0] = floatcos(fViewAngle[1], degrees) * fDistance
	fVelocity[1] = floatsin(fViewAngle[1], degrees) * fDistance
	fVelocity[2] = floatcos(fViewAngle[0]+90.0, degrees) * fDistance
	return 1
}

get_weapon_ent(id, weaponid)
{
	static wname[32], weapon_ent
	get_weaponname(weaponid, wname, charsmax(wname))
	weapon_ent = fm_find_ent_by_owner(-1, wname, id)
	return weapon_ent
}

set_weapons_timeidle(id, Float:timeidle)
{
	new entwpn = get_weapon_ent(id, get_user_weapon(id))
	if (pev_valid(entwpn)) set_pdata_float(entwpn, m_flTimeWeaponIdle, timeidle+3.0, 4)
}

set_player_nextattack(id, Float:nexttime)
{
	set_pdata_float(id, m_flNextAttack, nexttime, 4)
}

stock fm_find_ent_by_owner(entity, const classname[], owner)
{
	while ((entity = engfunc(EngFunc_FindEntityByString, entity, "classname", classname)) && pev(entity, pev_owner) != owner) { /* keep looping */ }
	return entity;
}

stock fm_set_rendering(entity, fx = kRenderFxNone, r = 255, g = 255, b = 255, render = kRenderNormal, amount = 16)
{
	static Float:color[3]
	color[0] = float(r)
	color[1] = float(g)
	color[2] = float(b)
	
	set_pev(entity, pev_renderfx, fx)
	set_pev(entity, pev_rendercolor, color)
	set_pev(entity, pev_rendermode, render)
	set_pev(entity, pev_renderamt, float(amount))
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1066\\ f0\\ fs16 \n\\ par }
*/
