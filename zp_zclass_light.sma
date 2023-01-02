#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <engine>
#include <zombieplague>
#include <fun>

#define PLUGIN "[ZP] Zombie Class: Light Zombie"
#define VERSION "1.0"
#define AUTHOR "Dias"

#define TASK_INVISIBLE 124798
#define TASK_COOLDOWN 574825

new g_zclass_light // ID cua class
new bool:can_invisible[33] // Co the su dung Skill neu = True
new bool:is_invisible[33] // Dang tang Hinh neu = True

new const zclass_name[] = "Light Zombie" // Ten
new const zclass_info[] = "| G -> Tang Hinh" // Thong Tin
new const zclass_model[] = "speed_zombi_host"// Player Model
new const zclass_clawmodel[] = "v_knife_speed_zombi.mdl" // Hand Model
new const invisible_sound[] = "zombie_plague/zombi_pressure_female.wav"
const zclass_health = 2000 // Mau
const zclass_speed = 260 // Toc Do
const Float:zclass_gravity = 0.7 // Trong Luc
const Float:zclass_knockback = 1.3 // Do Day Lui

new cvar_inv_time
new cvar_cooldown
new cvar_invisible_amount

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	register_clcmd("drop", "use_skill")
	
	cvar_inv_time = register_cvar("zp_zclass_light_invisible_time", "10.0")
	cvar_cooldown = register_cvar("zp_zclass_light_cooldown", "30.0")
	cvar_invisible_amount = register_cvar("zp_zclass_light_invisible_amount", "0")
}

public plugin_precache()
{
	g_zclass_light = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)	
	precache_sound(invisible_sound)
}

public zp_user_infected_post(id)
{
	if(zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclass_light)
	{
		can_invisible[id] = true
		is_invisible[id] = false
		remove_task(id+TASK_INVISIBLE)
		remove_task(id+TASK_COOLDOWN)
		
		client_print(id, print_chat, "[ZP] You are Light Zombie. Press (G) to Invisible")
	}
}

public zp_user_humanized_post(id)
{
	can_invisible[id] = false
	is_invisible[id] = false
	
	remove_task(id-TASK_INVISIBLE)
	remove_task(id-TASK_COOLDOWN)
}

public use_skill(id)
{
	if(is_user_alive(id) && zp_get_user_zombie(id) && zp_get_user_zombie_class(id) == g_zclass_light && !zp_get_user_nemesis(id))
	{
		if(can_invisible[id] && !is_invisible[id])
		{
			do_skill(id)		
		} else {
			client_print(id, print_chat,"[ZP] You can't Invisible at this time...")
		}
	}
}

public do_skill(id)
{
	is_invisible[id] = true
	can_invisible[id] = false

	set_user_maxspeed(id, get_user_maxspeed(id) + 50)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, get_pcvar_num(cvar_invisible_amount))

	emit_sound(id, CHAN_VOICE, invisible_sound, 1.0, ATTN_NORM, 0, PITCH_NORM)

	set_task(get_pcvar_float(cvar_inv_time), "visible", id+TASK_INVISIBLE)
	
	client_print(id, print_chat, "[ZP] You are Invisible.")
}

public visible(taskid)
{
	new id = taskid - TASK_INVISIBLE
	
	is_invisible[id] = false
	
	set_user_maxspeed(id, get_user_maxspeed(id) - 50)
	set_user_rendering(id, kRenderFxGlowShell, 0, 0, 0, kRenderTransAlpha, 255)
	
	client_print(id, print_chat, "[ZP] You are Visible")
	
	set_task(get_pcvar_float(cvar_cooldown), "reset_cooldown", id+TASK_COOLDOWN)
}

public reset_cooldown(taskid)
{
	new id = taskid - TASK_COOLDOWN
	if(zp_get_user_zombie(id) && zp_get_user_zombie_class(id) && g_zclass_light)
	{		
		can_invisible[id] = true
		client_print(id, print_chat, "[ZP] Now. You can Invisible. Press (G)")
	}
}
/* AMXX-Studio Notes - DO NOT MODIFY BELOW HERE
*{\\ rtf1\\ ansi\\ deff0{\\ fonttbl{\\ f0\\ fnil Tahoma;}}\n\\ viewkind4\\ uc1\\ pard\\ lang1066\\ f0\\ fs16 \n\\ par }
*/
