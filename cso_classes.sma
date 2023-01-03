#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <zombieplague>
#include <hamsandwich>
#include <ColorChat>
#include <dhudmessage>
#include <zp_cso_custom>
#include <fun>
#include <engine>

#define PLUGIN "[CSO] Default Classes"
#define VERSION "1.0"
#define AUTHOR "Filiq_ & Dias"

#define SPEED 0
#define INVIS 1
#define HEAVY 2
#define BANSHEE 3
#define DEIMOS 4

enum cData 
{
	zID,
	zName[50],
	zInfo[50],
	zcModel[50],
	zModel[50],
	zHP,
	zSpeed,
	Float:zGravity,
	Float:zKnockback
}

new classData[][cData] =
{
	{
		-1,
		"Normal Zombie", 
		"[G -> Fast Run]", 
		"v_knife_tank_zombi.mdl", 
		"tank_zombi_origin", 
		12000, 
		280, 
		0.7, 
		1.3
	},
	{
		-1,
		"Light Zombie", 
		"[G -> Invisibility]", 
		"v_knife_speed_zombi.mdl", 
		"speed_zombi_host", 
		7000, 
		260, 
		0.7, 
		1.3
	},
	{
		-1,
		"Heavy Zombie", 
		"[G -> Make a Trap]", 
		"v_knife_heavy_zombi.mdl", 
		"heavy_zombi_origin", 
		9000, 
		230, 
		1.0, 
		1.0
	},
	{
		-1,
		"Banshee Zombie", 
		"[G -> Send bats to him]", 
		"v_knife_witch_zombi.mdl", 
		"witch_zombi_origin", 
		5000, 
		280, 
		0.7, 
		1.0
	},
	{
		-1,
		"Deimos Zombie", 
		"[G -> Drop Human Weapon]", 
		"v_knife_deimos_zombi.mdl", 
		"deimos_zombi_origin", 
		12000, 
		280, 
		1.0, 
		1.0
	}
}

// light custom
new const invisible_sound[] = "zombie_plague/zombi_pressure_female.wav"

// trap custom
#define TASK_REMOVE_TRAP 37015

new const trap_string[] = "trap"
new const trap_model[] = "models/zombie_plague/zombie_trap.mdl"
new bool:player_trapped[33]



// others
new 
	g_msgSetFOV,
	abilityUse[33],
	abilityCD[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_message(get_user_msgid("TextMsg"), "message_textmsg")

	register_event("ResetHUD", "newRound", "be")

	register_forward(FM_PlayerPreThink, "playerPreThink")

	register_clcmd("drop", "useAbility")

	register_touch(trap_string, "*", "fw_touch")

	g_msgSetFOV = get_user_msgid("SetFOV")
}

public plugin_precache() 
{
	for(new i = 0; i < sizeof classData; i++)
		classData[i][zID] = zp_register_zombie_class(classData[i][zName], classData[i][zInfo], classData[i][zModel], classData[i][zcModel], classData[i][zHP], classData[i][zSpeed], classData[i][zGravity], classData[i][zKnockback])

	precache_sound(invisible_sound)

	precache_model(trap_model)
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

public client_putinserver(id)
{
	abilityUse[id] = -1
}

public newRound(id)
{
	player_trapped[id] = false

	remove_entity(find_ent_by_class(0, trap_string))
	set_user_maxspeed(id, -1.0)
	set_user_gravity(id, 1.0)
	
	remove_task(id+TASK_REMOVE_TRAP)
}

public playerPreThink(id)
{
	if(is_user_alive(id) && player_trapped[id] == true)
	{
		set_user_maxspeed(id, 0.1)
		set_user_gravity(id, 10000.0)
	}
}

public zp_user_infected_post(id)
{
	if(zp_get_user_zombie_class(id) == -1)
		return PLUGIN_HANDLED

	new class = zp_get_user_zombie_class(id)

	ColorChat(id, RED, "^x04[CSO] ^x01Your class is ^x04[%s]^x01, your ^x03health ^x01is now ^x04[%d] ^x01and you can access the ^x03ability ^x01on ^x04[G]", classData[class][zName], classData[class][zHP])

	if(player_trapped[id] == true)
	{
		player_trapped[id] = false
		
		remove_entity(find_ent_by_class(0, trap_string))
		remove_task(id+TASK_REMOVE_TRAP)
	}

	return PLUGIN_CONTINUE
}

public useAbility(id)
{
	if(!zp_get_user_zombie(id))
		return PLUGIN_HANDLED
	
	if(!is_user_alive(id))
		return PLUGIN_HANDLED

	if(abilityUse[id] != -1)
		return PLUGIN_HANDLED

	switch(zp_get_user_zombie_class(id))
	{
		case SPEED: speedAbility(id)
		case INVIS: invisAbility(id)
		case HEAVY: heavyAbility(id)
		case BANSHEE: {}
		case DEIMOS: {}
	}

	
	return PLUGIN_CONTINUE
}

// speed
public speedAbility(id)
{
	if(pev(id, pev_health) < 101) 
		return PLUGIN_HANDLED

	abilityUse[id] = 10

	set_pev(id, pev_maxspeed, 500.0)
	set_task(1.0, "timerAbility", id, _, _, "b")

	fm_set_user_health(id, pev(id, pev_health)-101)

	// fov
	message_begin(MSG_ONE, g_msgSetFOV, _, id)
	write_byte(110) // angle
	message_end()

	// glow
	speed_glow(id)
	// aura
	speed_aura(id)

	return PLUGIN_CONTINUE
}

public resetSpeed(id)
{
	abilityCD[id] = 10 // cd ability

	message_begin(MSG_ONE, g_msgSetFOV, _, id)
	write_byte(90) // angle
	message_end()
}

public speed_glow(id)
{
	if(abilityUse[id] == 0)
		return

	if(pev(id, pev_maxspeed) != 1.0)
		fm_set_rendering(id, kRenderFxGlowShell, Float:{ 255.0, 0.0, 0.0 }, kRenderNormal, 25)

	set_task(0.1, "speed_glow", id)
}

public speed_aura(id)
{
	if(abilityUse[id] == 0)
		return

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
	write_byte(255) // r
	write_byte(0) // g
	write_byte(0) // b
	write_byte(10) // life
	write_byte(0) // decay rate
	message_end()
	
	// Keep sending aura messages
	set_task(0.1, "speed_aura", id)
}
// speed

//invis
public invisAbility(id)
{
	abilityUse[id] = 10

	set_user_maxspeed(id, get_user_maxspeed(id) + 50)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 0)

	emit_sound(id, CHAN_VOICE, invisible_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)

	set_task(1.0, "timerAbility", id, _, _, "b")
}

public resetInviis(id)
{
	abilityCD[id] = 30 // cd ability

	set_user_maxspeed(id, get_user_maxspeed(id) - 50)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
}
//invis

//heavy
public heavyAbility(id)
{
	abilityUse[id] = 0

	new Float:Origin[3]
	entity_get_vector(id, EV_VEC_origin, Origin)
	
	Origin[2] -= 35.0
	
	new trap = create_entity("info_target")
	entity_set_vector(trap, EV_VEC_origin, Origin)
	
	entity_set_float(trap, EV_FL_takedamage, 1.0)
	entity_set_float(trap, EV_FL_health, 500.0) // hp trap
	
	entity_set_string(trap, EV_SZ_classname, trap_string)
	entity_set_model(trap, trap_model)	
	entity_set_int(trap, EV_INT_solid, 1)
	
	entity_set_byte(trap,EV_BYTE_controller1,125);
	entity_set_byte(trap,EV_BYTE_controller2,125);
	entity_set_byte(trap,EV_BYTE_controller3,125);
	entity_set_byte(trap,EV_BYTE_controller4,125);
	
	new Float:size_max[3] = {5.0,5.0,5.0}
	new Float:size_min[3] = {-5.0,-5.0,-5.0}
	entity_set_size(trap, size_min, size_max)
	
	entity_set_float(trap, EV_FL_animtime, 2.0)
	entity_set_float(trap, EV_FL_framerate, 1.0)
	entity_set_int(trap, EV_INT_sequence, 0)
	
	drop_to_floor(trap)
	
	set_task(1.0, "timerAbility", id, _, _, "b")
}

public resetHeavy(id)
{
	abilityCD[id] = 30 // cd ability
}

public fw_touch(trap, id)
{
	if(!pev_valid(trap))
		return	
	
	if(!is_user_alive(id))
		return
	
	if(zp_get_user_zombie(id))
		return

	entity_set_int(find_ent_by_class(0, trap_string), EV_INT_sequence, 1)
	
	player_trapped[id] = true
	set_task(15.0, "remove_trap", id+TASK_REMOVE_TRAP)
}

public remove_trap(taskid)
{
	new id = taskid - TASK_REMOVE_TRAP
	
	set_user_maxspeed(id, -1.0)
	set_user_gravity(id, 1.0)

	player_trapped[id] = false

	remove_entity(find_ent_by_class(0, trap_string))
	
	remove_task(id+TASK_REMOVE_TRAP)
}
//heavy

//deimos

//deimos

//
public timerAbility(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id)
		return
	}

	if(hud_get_zinfo(id) && abilityUse[id] > 0)
	{
		set_dhudmessage(0, 255, 255, 0.0, 0.19, 1, 1.0, 1.0, 0.1, 0.9)
		show_dhudmessage(id, "%d secound%s until the ability is gone.", abilityUse[id]	, abilityUse[id] == 1 ? "" : "s")
	}
	
	if(abilityUse[id] == 0) // end
	{
		remove_task(id)

		// fov
		switch(zp_get_user_zombie_class(id))
		{
			case SPEED: resetSpeed(id)
			case INVIS: resetInviis(id)
			case HEAVY: resetHeavy(id)
			case BANSHEE: {}
			case DEIMOS: {}
		}

		set_task(1.0, "resetAbility", id, _, _, "b")

		return
	}

	abilityUse[id] --
	if(abilityUse[id] < 0) abilityUse[id] = 0 // to be sure 
}

public resetAbility(id)
{
	if(!is_user_connected(id))
	{
		remove_task(id)
		return
	}

	if(hud_get_zinfo(id) && abilityCD[id] > 0)
	{
		set_dhudmessage(0, 255, 255, 0.0, 0.19, 1, 1.0, 1.0, 0.1, 0.9)
		show_dhudmessage(id, "%d secound%s until you can use your ability again.", abilityCD[id], abilityCD[id] == 1 ? "" : "s")
	}

	if(abilityCD[id] == 0)
	{
		if(hud_get_zinfo(id))
		{
			set_dhudmessage(0, 255, 255, 0.0, 0.19, 1, 1.0, 1.0, 0.1, 0.9)
			show_dhudmessage(id, "You can use your ability again.")
		}

		abilityUse[id] = -1

		remove_task(id)
		return
	}

	abilityCD[id] --
	if(abilityCD[id] < 0) abilityCD[id] = 0 // to be sure 
}
//

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
