#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <zombieplague>

#define PLUGIN "[ZP] Class : Pain Shock Free Zombie"
#define VERSION "1.2.3"
#define AUTHOR "Fry!"

const OFFSET_LINUX = 5
const OFFSET_PAINSHOCK = 108

new const zclass_name[] = "Pain Shock Free"
new const zclass_info[] = "Pain Shock Free"
new const zclass_model[] = "zombie_source"
new const zclass_clawmodel[] = "v_knife_zombie.mdl"
const zclass_health = 3000
const zclass_speed = 190
const Float:zclass_gravity = 1.0
const Float:zclass_knockback = 0.0

new g_zclass_pain_shock_free
new bool:g_has_pain_shock_free[33]

public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)
	
	register_cvar("zp_zclass_pain_shock_free",VERSION,FCVAR_SERVER|FCVAR_EXTDLL|FCVAR_UNLOGGED|FCVAR_SPONLY)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage_Post", 1)
}

public plugin_precache()
{
	g_zclass_pain_shock_free = zp_register_zombie_class(zclass_name, zclass_info, zclass_model, zclass_clawmodel, zclass_health, zclass_speed, zclass_gravity, zclass_knockback)
}

public zp_user_infected_post(player, infector)
{
    if(is_user_alive(player)){
	if (zp_get_user_zombie_class(player) == g_zclass_pain_shock_free){
		    g_has_pain_shock_free[player] = true
	    }
	}	
}

public fw_TakeDamage_Post(id)
{
	if (!is_user_alive(id) || !zp_get_user_zombie(id))
		return HAM_IGNORED
		
	if (zp_get_user_zombie_class(id) != g_zclass_pain_shock_free)
		return HAM_IGNORED
		
	g_has_pain_shock_free[id] = true
		
	set_pdata_float(id, OFFSET_PAINSHOCK, 1.0, OFFSET_LINUX)
	
	return HAM_IGNORED
}