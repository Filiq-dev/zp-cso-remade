#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <zombieplague>
#include <hamsandwich>

#define PLUGIN "[ZP] Zombie Class: Tank"
#define VERSION "1.0"
#define AUTHOR "Dias Leon"

new g_zclassic_zombie
new bool:g_hasSpeedBoost[33]
new bool:g_hasSpeedTime[33]
new g_sb_maxspeed, g_sb_time, g_msgSetFOV, cvar_zombiehp
new cvar_spnvgcolor[3]

new const zombie_pressure[][] = { "zombie_plague/zombie_pressure.wav" }
new const zombie_pre_idle1[][] = { "zombie_plague/zombie_pre_idle_1.wav" }
new const zombie_pre_idle2[][] = { "zombie_plague/zombie_pre_idle_2.wav" }

new const zclass_name[] = { "Normal Zombie" }
new const zclass_info[] = { "[G -> Fast Run]" }
new const zclass_model[] = { "tank_zombi_origin" }
new const zclass_clawmodel[] = { "v_knife_tank_zombi.mdl" }
const zclass_health = 12000
const zclass_speed = 280
const Float:zclass_gravity = 0.7
const Float:zclass_knockback = 1.3

public plugin_init() 
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_forward(FM_EmitSound, "fw_EmitSound")
	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	
	// Death Msg
	register_event("DeathMsg", "Death", "a")
	register_message(get_user_msgid("TextMsg"), "message_textmsg")
	
	RegisterHam(Ham_Spawn, "player", "fwHamPlayerSpawnPost", 1)
	
	register_clcmd("drop", "madness")
	g_msgSetFOV = get_user_msgid("SetFOV")
	g_sb_maxspeed = register_cvar("zp_znormal_pressure_maxspeed", "500.0")
	g_sb_time = register_cvar("zp_znormal_pressure_time", "10.0")
	cvar_zombiehp = register_cvar("zp_znormal_pressure_health", "100")
	cvar_spnvgcolor[0] = register_cvar("zp_znormal_prenvg_color_R", "255")
	cvar_spnvgcolor[1] = register_cvar("zp_znormal_prenvg_color_G", "0")
	cvar_spnvgcolor[2] = register_cvar("zp_znormal_prenvg_color_B", "0")
}

public Death()
{
	g_hasSpeedTime[read_data(2)] = false
	g_hasSpeedBoost[read_data(2)] = false
}

public fwHamPlayerSpawnPost(id)
{
	g_hasSpeedTime[id] = false
	g_hasSpeedBoost[id] = false
}

public plugin_precache()
{
	new i
	
	g_zclassic_zombie = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)

	//Sounds
	for (i = 0; i < sizeof zombie_pressure; i++)
		engfunc(EngFunc_PrecacheSound, zombie_pressure[i])
	for (i = 0; i < sizeof zombie_pre_idle1; i++)
		engfunc(EngFunc_PrecacheSound, zombie_pre_idle1[i])
	for (i = 0; i < sizeof zombie_pre_idle2; i++)
		engfunc(EngFunc_PrecacheSound, zombie_pre_idle2[i])
}

public zp_user_infected_post(id)
{
	if(zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclassic_zombie)
		client_print(id, print_center, "[G] -> Fast Run")
}

public madness(id)
{		
	if(!zp_get_user_zombie(id) && zp_get_user_zombie_class(id) != g_zclassic_zombie)
		return PLUGIN_HANDLED

	#if defined FOR_ADMINS_A_FLAG
		if ( !( get_user_flags(id) & ADMINACCESS))
			return PLUGIN_HANDLED
	#endif
	
	if (!is_user_alive(id))
	{
		return PLUGIN_HANDLED
	}
	if (g_hasSpeedBoost[id])
	{
		return PLUGIN_HANDLED
	}
	if (g_hasSpeedTime[id])
	{
		return PLUGIN_HANDLED
	}
	if (pev(id, pev_health) < 1+get_pcvar_num(cvar_zombiehp))
	{
		return PLUGIN_HANDLED
	}

	g_hasSpeedBoost[id] = true

	set_pev(id, pev_maxspeed, get_pcvar_float(g_sb_maxspeed))
	set_task(get_pcvar_float(g_sb_time), "boost_over", id)
	set_task(3.0, "zombie_pre_idle1_sound", id)
	set_task(5.0, "zombie_pre_idle2_sound", id)
	set_task(7.0, "zombie_pre_idle1_sound", id)
	set_task(9.0, "zombie_pre_idle2_sound", id)
	fov(id)
	speed_glow(id)
	speed_aura(id)
	fm_set_user_health(id, pev(id, pev_health)-get_pcvar_num(cvar_zombiehp))
	engfunc(EngFunc_EmitSound, id, CHAN_VOICE, zombie_pressure[random_num(0, sizeof zombie_pressure - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)
	
	return PLUGIN_CONTINUE
}

public boost_over(id)
{
	if(g_hasSpeedBoost[id])
	{
		g_hasSpeedBoost[id] = false
		g_hasSpeedTime[id] = true
		fov_end(id)
		set_task(get_pcvar_float(g_sb_time), "boost_reset", id)
		client_print(id, print_center, "You can continue use after 10 seconds")
	}
}

public boost_reset(id) g_hasSpeedTime[id] = false

public fov(id)
{
	message_begin(MSG_ONE, g_msgSetFOV, _, id)
	write_byte(110) // angle
	message_end()
}

public fov_end(id)
{
	message_begin(MSG_ONE, g_msgSetFOV, _, id)
	write_byte(90) // angle
	message_end()
}

public zombie_pre_idle1_sound(id) engfunc(EngFunc_EmitSound, id, CHAN_VOICE, zombie_pre_idle1[random_num(0, sizeof zombie_pre_idle1 - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

public zombie_pre_idle2_sound(id) engfunc(EngFunc_EmitSound, id, CHAN_VOICE, zombie_pre_idle2[random_num(0, sizeof zombie_pre_idle2 - 1)], 1.0, ATTN_NORM, 0, PITCH_NORM)

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
		return FMRES_IGNORED
		
	#if defined FOR_ADMINS_A_FLAG
		if ( !( get_user_flags(id) & ADMINACCESS) )
			return PLUGIN_CONTINUE
	#endif
	
	if (g_hasSpeedBoost[id])
	{
		set_pev(id, pev_maxspeed, get_pcvar_float(g_sb_maxspeed))		
	}
	return PLUGIN_CONTINUE
}

public speed_glow(id)
{
	if (g_hasSpeedBoost[id])
	{

	if (zp_get_user_zombie_class(id) == g_zclassic_zombie && zp_get_user_zombie(id) && !zp_get_user_nemesis(id))
{
	if(pev(id, pev_maxspeed) != 1.0)
		fm_set_rendering(id, kRenderFxGlowShell, Float:{ 255.0, 0.0, 0.0 }, kRenderNormal, 25)
}
	// Keep sending aura messages
	set_task(0.1, "speed_glow", id)
	}
}

public speed_aura(id)
{
	if (g_hasSpeedBoost[id])
	{
	// Get player origin
	static Float:originF[3]
	pev(id, pev_origin, originF)

	// Colored Aura
	engfunc(EngFunc_MessageBegin, MSG_PVS, SVC_TEMPENTITY, originF, 0)
	write_byte(TE_DLIGHT) // TE id
	engfunc(EngFunc_WriteCoord, originF[0]) // x
	engfunc(EngFunc_WriteCoord, originF[1]) // y
	engfunc(EngFunc_WriteCoord, originF[2]) // z
	write_byte(10) // radius
	write_byte(get_pcvar_num(cvar_spnvgcolor[0])) // r
	write_byte(get_pcvar_num(cvar_spnvgcolor[1])) // g
	write_byte(get_pcvar_num(cvar_spnvgcolor[2])) // b
	write_byte(10) // life
	write_byte(0) // decay rate
	message_end()
	
	// Keep sending aura messages
	set_task(0.1, "speed_aura", id)
	}
}

stock fm_set_user_maxspeed(index, Float:speed = -1.0) 
{
	engfunc(EngFunc_SetClientMaxspeed, index, speed);
	set_pev(index, pev_maxspeed, speed);

	return 1;
}

stock fm_set_user_health(id, health)
{
	(health > 0) ? set_pev(id, pev_health, float(health)) : dllfunc(DLLFunc_ClientKill, id);
}

stock fm_set_rendering(entity, fx = kRenderFxNone, Float:color[3] = { 255.0, 255.0, 255.0 }, render = kRenderNormal, amount = 16)
{
	
    set_pev(entity, pev_renderfx, fx)
    set_pev(entity, pev_rendercolor, color)
    set_pev(entity, pev_rendermode, render)
    set_pev(entity, pev_renderamt, float(amount))
    
}

public message_textmsg()
{
	static textmsg[22]
	get_msg_arg_string(2, textmsg, charsmax(textmsg))
	
	// Block drop weapon related messages
	if (equal(textmsg, "#Weapon_Cannot_Be_Dropped"))
		return PLUGIN_HANDLED
		
	return PLUGIN_CONTINUE
}
