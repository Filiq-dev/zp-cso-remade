#include <amxmodx>
#include <fakemeta>
#include <engine> 
#include <hamsandwich>
#include <zombieplague>
#include <colorchat>
#include <cstrike>

#define PLUGIN    "[CSO] Knife menu"
#define VERSION    "1.0"
#define AUTHOR    "Filiq_ - CHyC/4e/l"

#define VIP ADMIN_LEVEL_H

#define kCombat 0
#define kStrong 1
#define kAxe 2
#define kHammer 3

#define m_pPlayer 41 
#define m_flNextPrimaryAttack 46 
#define m_flNextSecondaryAttack 47 
#define m_flTimeWeaponIdle 48 

enum ekData {
	kname[15],
	vmodel[50],
	pmodel[50]
}

new const knifeData[][ekData] = {
	{
		"Combat Knife",
		"models/tx/knifes/v_combat.mdl", 
		"models/tx/knifes/p_combat.mdl"
	},
	{
		"Strong Knife",
		"models/tx/knifes/v_strong.mdl",
		"models/tx/knifes/p_strong.mdl"
	},
	{
		"Axe Knife",
		"models/tx/knifes/v_axe.mdl",
		"models/tx/knifes/p_axe.mdl"
	},
	{
		"Hammer Knife",
		"models/tx/knifes/v_hammer_norm.mdl",
		"models/tx/knifes/p_hammer.mdl"
	}
}

new const oldSounds[][] =
{
	"weapons/knife_deploy1.wav",
	"weapons/knife_hit1.wav",
	"weapons/knife_hit2.wav",
	"weapons/knife_hit3.wav",
	"weapons/knife_hit4.wav",
	"weapons/knife_hitwall1.wav",
	"weapons/knife_slash1.wav",
	"weapons/knife_slash2.wav",
	"weapons/knife_stab.wav"
}

new const combatSounds[][] = 
{
	"tox_cso/combat_deploy1.wav",
	"tox_cso/combat1.wav",
	"tox_cso/combat1.wav",
	"tox_cso/combat2.wav",
	"tox_cso/combat2.wav",
	"tox_cso/combat_hwall.wav",
	"tox_cso/combat_slash1.wav",
	"tox_cso/combat_slash1.wav",
	"tox_cso/combatstab.wav"
}

new const strongSounds[][] = 
{
	"tox_cso/strongdeply.wav",
	"tox_cso/strong-1.wav",
	"tox_cso/strong-1.wav",
	"tox_cso/strong-2.wav",
	"tox_cso/strong-2.wav",
	"tox_cso/strong-wall.wav",
	"tox_cso/strong-slash1.wav",
	"tox_cso/strong-slash1.wav",
	"tox_cso/strongstab.wav"
}

new const axeSounds[][] =
{
	"tox_cso/axedep.wav",
	"tox_cso/axe_hit2222.wav",
	"tox_cso/axe_hit2222.wav",
	"tox_cso/axe_hit11111.wav",
	"tox_cso/axe_hit11111.wav",
	"tox_cso/axe_hit_wall1.wav",
	"tox_cso/axe_slash11.wav",
	"tox_cso/axe_slash11.wav",
	"tox_cso/axstab.wav"
}

new const hammerSounds[][] = 
{
	"tox_cso/hammer_deploy111.wav",
	"tox_cso/ham1.wav",
	"tox_cso/ham1.wav",
	"tox_cso/ham2.wav",
	"tox_cso/ham2.wav",
	"tox_cso/hammer_hitwall11.wav",
	"tox_cso/hammer_slash111.wav",
	"tox_cso/hammer_slash111.wav",
	"tox_cso/hammerstab.wav"
}

new const g_sound_knife[] = { "items/gunpickup2.wav" }
	
new 
	hasKnife[33] = -1,
	bool:hasChoosed[33] = false

new cvar_knife_combat_jump, cvar_knife_combat_spd, cvar_knife_combat_dmg, cvar_knife_combat_knock, cvar_knife_combat_spd_attack2
new cvar_knife_strong_jump, cvar_knife_strong_dmg, cvar_knife_strong_knock, cvar_knife_strong_spd_attack2
new cvar_knife_axe_jump, cvar_knife_axe_dmg, cvar_knife_axe_knock
new cvar_knife_hammer_jump, cvar_knife_hammer_dmg, cvar_knife_hammer_knock, cvar_hammer_spd_attack2


public plugin_init()
{
	register_plugin(PLUGIN, VERSION, AUTHOR)

	register_clcmd("say /knife", "knife_menu")

	register_event("Damage", "event_Damage" , "b" , "2>0")
	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink")
	register_forward(FM_EmitSound, "fw_EmitSound")

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")

	RegisterHam(Ham_Item_Deploy, "weapon_knife", "changeModel", 1)
	
	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1) 

	cvar_knife_combat_jump= register_cvar("zp_knife_combat_jump", "290.0")
	cvar_knife_combat_spd = register_cvar("zp_knife_combat_spd", "290.0")
	cvar_knife_combat_dmg = register_cvar("zp_knife_combat_dmg" , "3.0")
	cvar_knife_combat_knock = register_cvar("zp_knife_combat_knock" , "6.0")
	cvar_knife_combat_spd_attack2 = register_cvar("zp_knife_combat_spd_attack2" , "1.3")

	cvar_knife_strong_jump= register_cvar("zp_knife_strong_jump", "290.0")
	cvar_knife_strong_dmg = register_cvar("zp_knife_strong_dmg" , "5.0")
	cvar_knife_strong_knock = register_cvar("zp_knife_strong_knock" , "10.0")
	cvar_knife_strong_spd_attack2 = register_cvar("zp_knife_strong_spd_attack2" , "1.7")

	cvar_knife_axe_jump= register_cvar("zp_knife_axe_jump", "350.0")
	cvar_knife_axe_dmg = register_cvar("zp_knife_axe_dmg" , "3.5")
	cvar_knife_axe_knock = register_cvar("zp_knife_axe_knock" , "6.0")

	cvar_knife_hammer_jump= register_cvar("zp_knife_hammer_jump", "350.0")
	cvar_knife_hammer_dmg = register_cvar("zp_knife_hammer_dmg" , "6.0")
	cvar_knife_hammer_knock = register_cvar("zp_knife_hammer_knock" , "20.0")
	cvar_hammer_spd_attack2 = register_cvar("zp_knife_hammer_spd_attack2" , "1.5")
}

public plugin_natives()
{
	register_native("zp_knife_menu", "knife_menu", 1)
}

public plugin_precache()
{
	for(new i = 0; i < sizeof knifeData; i++) 
	{
		precache_model(knifeData[i][vmodel])
		precache_model(knifeData[i][pmodel])
	}

	for(new i = 0; i < sizeof combatSounds; i++)
		precache_sound(combatSounds[i])

	for(new i = 0; i < sizeof strongSounds; i++)
		precache_sound(strongSounds[i])

	for(new i = 0; i < sizeof axeSounds; i++)
		precache_sound(axeSounds[i])

	for(new i = 0; i < sizeof hammerSounds; i++)
		precache_sound(hammerSounds[i])

	precache_sound(g_sound_knife)
}

public client_connect(id)
{
	hasKnife[id] = kAxe
}

public event_Damage(id)
{
	new weapon , attacker = get_user_attacker(id, weapon)

	if(!is_user_alive(attacker))
		return PLUGIN_HANDLED

	if(hasKnife[id] == -1)
		return PLUGIN_HANDLED

	if(weapon != CSW_KNIFE)
		return PLUGIN_HANDLED

	new Float:vec[3];
	new Float:oldvelo[3];

	get_user_velocity(id, oldvelo);
	create_velocity_vector(id , attacker , vec);

	vec[0] += oldvelo[0];
	vec[1] += oldvelo[1];
	set_user_velocity(id , vec);

	return PLUGIN_CONTINUE
}

public event_round_start(id)
{
	hasChoosed[id] = false
}

public fw_PlayerPreThink(id)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED

	new temp[2], weapon = get_user_weapon(id, temp[0], temp[1])

	if(weapon != CSW_KNIFE)
		return FMRES_IGNORED

	if(hasKnife[id] == kCombat) {
		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_combat_spd))
	}

	if((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
	{
		new vel = 0

		switch(hasKnife[id])
		{
			case kCombat: vel = get_pcvar_num(cvar_knife_combat_jump)
			case kStrong: vel = get_pcvar_num(cvar_knife_strong_jump)
			case kAxe: vel = get_pcvar_num(cvar_knife_axe_jump)
			case kHammer: vel = get_pcvar_num(cvar_knife_hammer_jump)
		}
		
		if (!(pev(id, pev_flags) & FL_ONGROUND))
			return FMRES_IGNORED

		if (pev(id, pev_flags) & FL_WATERJUMP)
			return FMRES_IGNORED

		if (pev(id, pev_waterlevel) > 1.0)
			return FMRES_IGNORED
		
		new Float:fVelocity[3]
		pev(id, pev_velocity, fVelocity)
		
		fVelocity[2] += vel
		
		set_pev(id, pev_velocity, fVelocity)
		set_pev(id, pev_gaitsequence, 6)
	}

	// return FMRES_IGNORED // for bhop
	return FMRES_SUPERCEDE
}  

public fw_EmitSound(id, channel, const sound[])
{
	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED

	if(hasKnife[id] == -1)
		return FMRES_IGNORED

	for(new i = 0; i < sizeof oldSounds; i++)
	{ 
		if(equal(sound, oldSounds[i]))
		{
			switch(hasKnife[id])
			{
				case kAxe:
				{
					emit_sound(id, channel, axeSounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				case kCombat:
				{
					emit_sound(id, channel, combatSounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				case kStrong:
				{
					
					emit_sound(id, channel, strongSounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				case kHammer:
				{
					emit_sound(id, channel, hammerSounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
				default:
				{
					emit_sound(id, channel, oldSounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
					return FMRES_SUPERCEDE
				}
			}
		}
	}
	return FMRES_IGNORED
}

public message_DeathMsg(msg_id, msg_dest, id)
{
	static szTruncatedWeapon[33], iattacker, ivictim
	
	get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
	
	iattacker = get_msg_arg_int(1)
	ivictim = get_msg_arg_int(2)
	
	if(!is_user_connected(iattacker) || iattacker == ivictim)
		return PLUGIN_HANDLED

	if(zp_get_user_zombie(iattacker))
		return PLUGIN_HANDLED

	if(!(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE))
		return PLUGIN_HANDLED

	set_msg_arg_string(4, knifeData[hasKnife[id]][kname])
		
	return PLUGIN_CONTINUE
}

public changeModel(weapon)
{
	static id; id = fm_cs_get_weapon_ent_owner(weapon)

	if(!pev_valid(id))
		return HAM_HANDLED

	if(zp_get_user_zombie(id))
		return HAM_HANDLED

	if(hasKnife[id] == -1)
		return HAM_HANDLED

	if(cs_get_weapon_id(weapon) != CSW_KNIFE)
		return HAM_HANDLED

	set_pev(id, pev_viewmodel2, knifeData[hasKnife[id]][vmodel])
	set_pev(id, pev_weaponmodel2, knifeData[hasKnife[id]][pmodel])

	return HAM_IGNORED
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker))
		return HAM_HANDLED
	
	if(zp_get_user_zombie(attacker))
		return HAM_HANDLED

	if(get_user_weapon(attacker) != CSW_KNIFE)
		return HAM_HANDLED

	static Float:kDamage

	switch(hasKnife[attacker])
	{
		case kCombat: kDamage = get_pcvar_float(cvar_knife_combat_dmg)
		case kStrong: kDamage = get_pcvar_float(cvar_knife_strong_dmg)
		case kAxe: kDamage = get_pcvar_float(cvar_knife_axe_dmg)
		case kHammer: kDamage = get_pcvar_float(cvar_knife_hammer_dmg)
	}

	SetHamParamFloat(4, damage * kDamage)

	return HAM_IGNORED
}

public fw_Knife_SecondaryAttack_Post(weapon) 
{     
	static id; id = get_pdata_cbase(weapon, m_pPlayer, 4) 

	if(zp_get_user_zombie(id))
		return HAM_HANDLED

	if(weapon != CSW_KNIFE)
		return HAM_HANDLED

	if(hasKnife[id] == kAxe)
		return HAM_HANDLED
		
	static Float:flRate 

	switch(hasKnife[id])
	{
		case kCombat: flRate = get_pcvar_float(cvar_knife_combat_spd_attack2) 
		case kStrong: flRate = get_pcvar_float(cvar_knife_strong_spd_attack2) 
		case kHammer: flRate = get_pcvar_float(cvar_hammer_spd_attack2) 
	}

	set_pdata_float(weapon, m_flNextPrimaryAttack, flRate, 4) 
	set_pdata_float(weapon, m_flNextSecondaryAttack, flRate, 4) 
	set_pdata_float(weapon, m_flTimeWeaponIdle, flRate, 4) 

	return HAM_IGNORED 
} 

public knife_menu(id)
{
	if(hasChoosed[id])
	{
		ColorChat(id, NORMAL, "^1[^4CSO^1] You can choose your knife only one time per round.")
		return PLUGIN_HANDLED_MAIN
	}

	if(zp_get_user_zombie(id))
		return PLUGIN_HANDLED_MAIN

	new menu = menu_create("Knife Menu | Zombie-Plague \w[\rCSO\w]^n^n", "menu_handler");

	menu_additem(menu, "Combat \y[Speed]");
	menu_additem(menu, "Strong \y[Damage]");
	menu_additem(menu, "Axe \y[Jump]");
	menu_additem(menu, "\yHammer \r[Admin/Vip]");
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);    

	return PLUGIN_HANDLED_MAIN
}

public menu_handler(id, menu, item)
{
	if(item == MENU_EXIT)
	{
		menu_destroy(menu)
		return PLUGIN_HANDLED
	}

	hasKnife[id] = item
	
	set_pev(id, pev_viewmodel2, knifeData[item][vmodel])
	set_pev(id, pev_weaponmodel2, knifeData[item][pmodel])

	menu_destroy(menu)

	return PLUGIN_HANDLED
}

public create_velocity_vector(victim, attacker, Float:velocity[3])
{
	if(!zp_get_user_zombie(victim) || !is_user_alive(attacker))
		return PLUGIN_HANDLED

	static Float:vicorigin[3];
	static Float:attorigin[3];

	entity_get_vector(victim   , EV_VEC_origin , vicorigin);
	entity_get_vector(attacker , EV_VEC_origin , attorigin);

	static Float:origin2[3]
	origin2[0] = vicorigin[0] - attorigin[0];
	origin2[1] = vicorigin[1] - attorigin[1];

	static Float:largestnum = 0.0;

	if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0]);
	if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1]);

	origin2[0] /= largestnum;
	origin2[1] /= largestnum;

	switch(hasKnife[attacker])
	{
		case kAxe: 
		{
			velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);
			velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);
		}
		case kCombat:
		{
			velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);
			velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);
		}
		case kStrong:
		{
			velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);
			velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);
		}
		case kHammer:
		{
			velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);
			velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);
		}
	}

	if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
		velocity[2] = random_float(200.0 , 275.0);

	return 1;
}

fm_cs_get_weapon_ent_owner(ent)
{
	// Prevent server crash if entity's private data not initalized
	if (pev_valid(ent) != 2) return -1;

	return get_pdata_cbase(ent, 41, 4);
} 