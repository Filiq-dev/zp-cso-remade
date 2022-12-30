#include <amxmodx>
#include <fakemeta>
#include <fun> 
#include <engine> 
#include <hamsandwich>
#include <zombieplague>

#define PLUGIN    "Choose knifes"
#define VERSION    "1.0"
#define AUTHOR    "CHyC/4e/l"

#define VIP ADMIN_LEVEL_H
#define MAXPLAYERS 32

new combat_v_model[] = "models/tx/knifes/v_combat.mdl"
new combat_p_model[] = "models/tx/knifes/p_combat.mdl"

new strong_v_model[] = "models/tx/knifes/v_strong.mdl"
new strong_p_model[] = "models/tx/knifes/p_strong.mdl"

new axe_v_model[] = "models/tx/knifes/v_axe.mdl"    
new axe_p_model[] = "models/tx/knifes/p_axe.mdl"    

new hammer_v_model[] = "models/tx/knifes/v_hammer_norm.mdl"    
new hammer_p_model[] = "models/tx/knifes/p_hammer.mdl"    

const m_pPlayer = 41 
const m_flNextPrimaryAttack = 46 
const m_flNextSecondaryAttack = 47 
const m_flTimeWeaponIdle = 48 

new g_hasSpeed[33], SayText
new bool:g_WasShowed[MAXPLAYERS + 1]
new g_knife_combat[33], cvar_knife_combat_jump, cvar_knife_combat_spd, cvar_knife_combat_dmg, cvar_knife_combat_knock, cvar_knife_combat_spd_attack2
new g_knife_strong[33], cvar_knife_strong_jump, cvar_knife_strong_dmg, cvar_knife_strong_knock, cvar_knife_strong_spd_attack2
new g_knife_axe[33], cvar_knife_axe_jump, cvar_knife_axe_dmg, cvar_knife_axe_knock
new g_knife_hammer[33], cvar_knife_hammer_jump, cvar_knife_hammer_dmg, cvar_knife_hammer_knock, cvar_hammer_spd_attack2

new const g_sound_knife[] = { "items/gunpickup2.wav" }

new const combat_sounds[][] =
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

new const strong_sounds[][] =
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

new const axe_sounds[][] =
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

new const hammer_sounds[][] =
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

new const oldknife_sounds[][] =
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

public plugin_init()
{
	register_plugin(PLUGIN , VERSION , AUTHOR);
	register_cvar("zp_addon_knife", VERSION, FCVAR_SERVER);
	SayText = get_user_msgid("SayText")   

	register_clcmd("say /knife", "knife_menu")

	register_clcmd("combat", "give_combat")
	register_clcmd("strong", "give_strong")
	register_clcmd("axe", "give_axe")
	register_clcmd("hammer", "give_hammer")

	register_event("CurWeapon","checkWeapon","be","1=1");
	register_event("Damage" , "event_Damage" , "b" , "2>0");

	register_forward(FM_PlayerPreThink, "fw_PlayerPreThink");
	register_forward(FM_EmitSound, "fw_EmitSound");

	register_message(get_user_msgid("DeathMsg"), "message_DeathMsg");

	RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage");
	RegisterHam(Ham_Weapon_SecondaryAttack, "weapon_knife", "fw_Knife_SecondaryAttack_Post", 1) 

	cvar_knife_combat_jump= register_cvar("zp_knife_combat_jump", "290.0");
	cvar_knife_combat_spd = register_cvar("zp_knife_combat_spd", "290.0");
	cvar_knife_combat_dmg = register_cvar("zp_knife_combat_dmg" , "3.0");
	cvar_knife_combat_knock = register_cvar("zp_knife_combat_knock" , "6.0");
	cvar_knife_combat_spd_attack2 = register_cvar("zp_knife_combat_spd_attack2" , "1.3");

	cvar_knife_strong_jump= register_cvar("zp_knife_strong_jump", "290.0");
	cvar_knife_strong_dmg = register_cvar("zp_knife_strong_dmg" , "5.0");
	cvar_knife_strong_knock = register_cvar("zp_knife_strong_knock" , "10.0");
	cvar_knife_strong_spd_attack2 = register_cvar("zp_knife_strong_spd_attack2" , "1.7");

	cvar_knife_axe_jump= register_cvar("zp_knife_axe_jump", "350.0");
	cvar_knife_axe_dmg = register_cvar("zp_knife_axe_dmg" , "3.5");
	cvar_knife_axe_knock = register_cvar("zp_knife_axe_knock" , "6.0");

	cvar_knife_hammer_jump= register_cvar("zp_knife_hammer_jump", "350.0");
	cvar_knife_hammer_dmg = register_cvar("zp_knife_hammer_dmg" , "6.0");
	cvar_knife_hammer_knock = register_cvar("zp_knife_hammer_knock" , "20.0");
	cvar_hammer_spd_attack2 = register_cvar("zp_knife_hammer_spd_attack2" , "1.5");

	register_event("HLTV", "event_round_start", "a", "1=0", "2=0")
}

public plugin_natives()
{
	register_native("zp_knife_menu", "knife_menu", 1)
}

public client_connect(id)
{
	g_knife_combat[id] = false
	g_knife_strong[id] = false
	g_knife_axe[id] = false
	g_knife_hammer[id] = false
	g_hasSpeed[id] = false

	give_axe(id)
}

public client_disconnect(id)
{
	g_knife_combat[id] = false
	g_knife_strong[id] = false
	g_knife_axe[id] = false
	g_knife_hammer[id] = false
	g_hasSpeed[id] = false
}

public plugin_precache()
{
	precache_model(combat_v_model)
	precache_model(combat_p_model)
	precache_model(strong_v_model)
	precache_model(strong_p_model)
	precache_model(axe_v_model)
	precache_model(axe_p_model)
	precache_model(hammer_v_model)
	precache_model(hammer_p_model)

	precache_sound(g_sound_knife)

	for(new i = 0; i < sizeof combat_sounds; i++)
		precache_sound(combat_sounds[i])

	for(new i = 0; i < sizeof strong_sounds; i++)
		precache_sound(strong_sounds[i])

	for(new i = 0; i < sizeof axe_sounds; i++)
		precache_sound(axe_sounds[i])  

	for(new i = 0; i < sizeof hammer_sounds; i++)
		precache_sound(hammer_sounds[i])
}

public event_round_start(id)
{
		for (new i; i < MAXPLAYERS + 1; i++)
			g_WasShowed[i] = false
}

public knife_menu(id)
{
	if (g_WasShowed[id])
	{
		print_col_chat(id, "^1[^4ZP^1] You can choose your knife only one time per round")
		return PLUGIN_HANDLED
	}

	if(is_user_alive(id) && !zp_get_user_zombie(id))
	{
		my_menu(id)
	}

	return PLUGIN_HANDLED
}

public my_menu(id)
{
	new menu = menu_create("Knife Menu | Zombie-Plague \w[\rCSO\w]^n^n", "menu_handler");

	menu_additem(menu, "\wCombat \y[Speed]", "1", 0);
	menu_additem(menu, "\wStrong \y[Damage]", "2", 0);
	menu_additem(menu, "\wAxe \y[Jump]", "3", 0);
	menu_additem(menu, "\yHammer \r[Admin/Vip]", "4", 0);
	
	menu_setprop(menu, MPROP_EXIT, MEXIT_ALL);
	menu_display(id, menu, 0);    
} 

public menu_handler(id, menu, item)
{
	if( item == MENU_EXIT )
	{
		menu_destroy(menu);
		return PLUGIN_HANDLED;    
	}
	
	new data[6], iName[64];
	new access, callback;
	
	menu_item_getinfo(menu, item, access, data,5, iName, 63, callback);
	
	new key = str_to_num(data);
	
	switch(key)
	{
		case 1:
		{
			give_combat(id)
			menu_destroy(menu);
			return PLUGIN_HANDLED
		}
		case 2:
		{
			give_strong(id)
			menu_destroy(menu);
			return PLUGIN_HANDLED
		}
		case 3:
		{
			give_axe(id)
			menu_destroy(menu);
			return PLUGIN_HANDLED
		}
		case 4:
		{
			give_hammer(id)
			menu_destroy(menu);
			return PLUGIN_HANDLED
		}
	}
	menu_destroy(menu);
	return PLUGIN_HANDLED
}

public give_combat(id)
{
	g_knife_combat[id] = true    
	g_knife_strong[id] = false
	g_knife_axe[id] = false    
	g_knife_hammer[id] = false
	g_hasSpeed[id] =  true
	g_WasShowed[id] = true

	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public give_strong(id)
{
	g_knife_combat[id] = false    
	g_knife_strong[id] = true    
	g_knife_axe[id] = false
	g_knife_hammer[id] = false
	g_WasShowed[id] = true

	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)
}

public give_axe(id)
{
	g_knife_combat[id] = false    
	g_knife_strong[id] = false    
	g_knife_axe[id] = true
	g_knife_hammer[id] = false
	g_WasShowed[id] = true

	engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)
}


public give_hammer(id)
{
	if (get_user_flags(id) & VIP)
	{
		g_knife_combat[id] = false    
		g_knife_strong[id] = false    
		g_knife_axe[id] = false
		g_knife_hammer[id] = true
		g_WasShowed[id] = true

		engfunc(EngFunc_EmitSound, id, CHAN_BODY, g_sound_knife, 1.0, ATTN_NORM, 0, PITCH_NORM)
	}
	else 
	{
		client_cmd(id, "/knife")
		g_WasShowed[id] = true
	}
}

public checkWeapon(id)
{
	new plrWeapId
	
	plrWeapId = get_user_weapon(id)
	
	if (plrWeapId == CSW_KNIFE && (g_knife_combat[id] || g_knife_strong[id] || g_knife_axe[id] || g_knife_hammer[id]))
	{
		checkModel(id)
	}
}

public checkModel(id)
{
	if (zp_get_user_zombie(id))
		return PLUGIN_HANDLED
	
	if (g_knife_combat[id])
	{
		set_pev(id, pev_viewmodel2, combat_v_model)
		set_pev(id, pev_weaponmodel2, combat_p_model)
	}

	if (g_knife_strong[id])
	{
		set_pev(id, pev_viewmodel2, strong_v_model)
		set_pev(id, pev_weaponmodel2, strong_p_model)
	}

	if (g_knife_axe[id])
	{
		set_pev(id, pev_viewmodel2, axe_v_model)
		set_pev(id, pev_weaponmodel2, axe_p_model)
	}

	if (g_knife_hammer[id])
	{
		set_pev(id, pev_viewmodel2, hammer_v_model)
		set_pev(id, pev_weaponmodel2, hammer_p_model)
	}
	return PLUGIN_HANDLED
}

public fw_EmitSound(id, channel, const sound[])
{
	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED
		
	for(new i = 0; i < sizeof combat_sounds; i++) 
	for(new i = 0; i < sizeof strong_sounds; i++)
	for(new i = 0; i < sizeof axe_sounds; i++)
	for(new i = 0; i < sizeof hammer_sounds; i++)
	{
		if(equal(sound, oldknife_sounds[i]))
		{
			if (g_knife_combat[id])
			{
				emit_sound(id, channel, combat_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
			if (g_knife_strong[id])
			{
				emit_sound(id, channel, strong_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
			if (g_knife_axe[id])
			{
				emit_sound(id, channel, axe_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
			if (g_knife_hammer[id])
			{
				emit_sound(id, channel, hammer_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
			}
			if (!g_knife_combat[id] || !g_knife_strong[id] || !g_knife_axe[id] || !g_knife_hammer[id])
			{
				emit_sound(id, channel, oldknife_sounds[i], 1.0, ATTN_NORM, 0, PITCH_NORM)
				return FMRES_SUPERCEDE
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
		return PLUGIN_CONTINUE

	if (!zp_get_user_zombie(iattacker))
	{
		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)
		{
			if(g_knife_combat[iattacker])
				set_msg_arg_string(4, "Combat knife")
		}
	
		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)
		{
			if(g_knife_strong[iattacker])
				set_msg_arg_string(4, "Strong knife")
		}

		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)
		{
			if(g_knife_axe[iattacker])
				set_msg_arg_string(4, "Axe knife")
		}

		if(equal(szTruncatedWeapon, "knife") && get_user_weapon(iattacker) == CSW_KNIFE)
		{
			if(g_knife_hammer[iattacker])
				set_msg_arg_string(4, "Ice knife")
		}
	}
	return PLUGIN_CONTINUE
}

stock print_col_chat(const id, const input[], any:...)  
{  
	new count = 1, players[32];  
	static msg[191];  
	vformat(msg, 190, input, 3);  
	replace_all(msg, 190, "!g", "^4"); // Green Color  
	replace_all(msg, 190, "!y", "^1"); // Default Color 
	replace_all(msg, 190, "!t", "^3"); // Team Color  
	if (id) players[0] = id; else get_players(players, count, "ch");  
	{  
		for ( new i = 0; i < count; i++ )  
		{  
			if ( is_user_connected(players[i]) )  
			{  
				message_begin(MSG_ONE_UNRELIABLE, SayText, _, players[i]);  
				write_byte(players[i]);  
				write_string(msg);  
				message_end();  
			}  
		}  
	}  
}   

public fw_PlayerPreThink(id)
{

	if(!is_user_alive(id) || zp_get_user_zombie(id))
		return FMRES_IGNORED

	new temp[2], weapon = get_user_weapon(id, temp[0], temp[1])

	if (weapon == CSW_KNIFE && g_knife_combat[id])
	{
		g_hasSpeed[id] = true
		set_pev(id, pev_maxspeed, get_pcvar_float(cvar_knife_combat_spd))
	}

	if(weapon == CSW_KNIFE && g_knife_combat[id])   
	{
		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
		{
			new flags = pev(id, pev_flags)
			new waterlvl = pev(id, pev_waterlevel)
			
			if (!(flags & FL_ONGROUND))
				return FMRES_IGNORED

			if (flags & FL_WATERJUMP)
				return FMRES_IGNORED

			if (waterlvl > 1)
				return FMRES_IGNORED
			
			new Float:fVelocity[3]
			pev(id, pev_velocity, fVelocity)
			
			fVelocity[2] += get_pcvar_num(cvar_knife_combat_jump)
			
			set_pev(id, pev_velocity, fVelocity)
			set_pev(id, pev_gaitsequence, 6)
		}
	}
	if (weapon == CSW_KNIFE && g_knife_strong[id])
	{
		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
		{
			new flags = pev(id, pev_flags)
			new waterlvl = pev(id, pev_waterlevel)
			
			if (!(flags & FL_ONGROUND))
				return FMRES_IGNORED

			if (flags & FL_WATERJUMP)
				return FMRES_IGNORED

			if (waterlvl > 1)
				return FMRES_IGNORED
			
			new Float:fVelocity[3]
			pev(id, pev_velocity, fVelocity)
			
			fVelocity[2] += get_pcvar_num(cvar_knife_strong_jump)
			
			set_pev(id, pev_velocity, fVelocity)
			set_pev(id, pev_gaitsequence, 6)
		}
	}
	if (weapon == CSW_KNIFE && g_knife_axe[id])
	{
		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
		{
			new flags = pev(id, pev_flags)
			new waterlvl = pev(id, pev_waterlevel)
			
			if (!(flags & FL_ONGROUND))
				return FMRES_IGNORED

			if (flags & FL_WATERJUMP)
				return FMRES_IGNORED

			if (waterlvl > 1)
				return FMRES_IGNORED
			
			new Float:fVelocity[3]
			pev(id, pev_velocity, fVelocity)
			
			fVelocity[2] += get_pcvar_num(cvar_knife_axe_jump)
			
			set_pev(id, pev_velocity, fVelocity)
			set_pev(id, pev_gaitsequence, 6)
		}
	}
	if (weapon == CSW_KNIFE && g_knife_hammer[id])
	{
		if ((pev(id, pev_button) & IN_JUMP) && !(pev(id, pev_oldbuttons) & IN_JUMP))
		{
			new flags = pev(id, pev_flags)
			new waterlvl = pev(id, pev_waterlevel)
			
			if (!(flags & FL_ONGROUND))
				return FMRES_IGNORED

			if (flags & FL_WATERJUMP)
				return FMRES_IGNORED

			if (waterlvl > 1)
				return FMRES_IGNORED
			
			new Float:fVelocity[3]
			pev(id, pev_velocity, fVelocity)
			
			fVelocity[2] += get_pcvar_num(cvar_knife_hammer_jump)
			
			set_pev(id, pev_velocity, fVelocity)
			set_pev(id, pev_gaitsequence, 6)
		}
	}

	return FMRES_IGNORED
}  

public fw_TakeDamage(victim, inflictor, attacker, Float:damage, damage_type)
{
	if(!is_user_connected(attacker))
		return HAM_IGNORED
	
	if(zp_get_user_zombie(attacker))
		return HAM_IGNORED

	new weapon = get_user_weapon(attacker)

	if (weapon == CSW_KNIFE && g_knife_combat[attacker])
	{    
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_combat_dmg))
	}
	if (weapon == CSW_KNIFE && g_knife_strong[attacker])
	{    
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_strong_dmg))
	}
	if (weapon == CSW_KNIFE && g_knife_axe[attacker])
	{    
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_axe_dmg))
	}
		
	if (weapon == CSW_KNIFE && g_knife_hammer[attacker])
	{     
		SetHamParamFloat(4, damage * get_pcvar_float(cvar_knife_hammer_dmg))
	}

	return HAM_IGNORED
}

public fw_Knife_SecondaryAttack_Post(knife) 
{     
		static id 
		id = get_pdata_cbase(knife, m_pPlayer, 4) 

		if(zp_get_user_zombie(id))
		return HAM_IGNORED
	
		if(is_user_connected(id) && g_knife_combat[id]) 
		{ 
			static Float:flRate 
			flRate = get_pcvar_float(cvar_knife_combat_spd_attack2) 
		 
			set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 
		} 
 
		if(is_user_connected(id) && g_knife_strong[id]) 
		{ 
			static Float:flRate 
			flRate = get_pcvar_float(cvar_knife_strong_spd_attack2) 
			 
			set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 
		} 

		if(is_user_connected(id) && g_knife_hammer[id]) 
		{ 
			static Float:flRate 
			flRate = get_pcvar_float(cvar_hammer_spd_attack2) 
			 
			set_pdata_float(knife, m_flNextPrimaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flNextSecondaryAttack, flRate, 4) 
			set_pdata_float(knife, m_flTimeWeaponIdle, flRate, 4) 
		}     
   
		return HAM_IGNORED 
} 

public event_Damage(id)
{
	new weapon , attacker = get_user_attacker(id , weapon);

	if(!is_user_alive(attacker))
		return PLUGIN_CONTINUE;

	if(weapon == CSW_KNIFE && g_knife_combat[attacker])
	{
		new Float:vec[3];
		new Float:oldvelo[3];
		get_user_velocity(id, oldvelo);
		create_velocity_vector(id , attacker , vec);
		vec[0] += oldvelo[0];
		vec[1] += oldvelo[1];
		set_user_velocity(id , vec);
	}

	if(weapon == CSW_KNIFE && g_knife_strong[attacker])
	{
		new Float:vec[3];
		new Float:oldvelo[3];
		get_user_velocity(id, oldvelo);
		create_velocity_vector(id , attacker , vec);
		vec[0] += oldvelo[0];
		vec[1] += oldvelo[1];
		set_user_velocity(id , vec);
	}

	if(weapon == CSW_KNIFE && g_knife_axe[attacker])
	{
		new Float:vec[3];
		new Float:oldvelo[3];
		get_user_velocity(id, oldvelo);
		create_velocity_vector(id , attacker , vec);
		vec[0] += oldvelo[0];
		vec[1] += oldvelo[1];
		set_user_velocity(id , vec);
	}

	if(weapon == CSW_KNIFE && g_knife_hammer[attacker])
	{
		new Float:vec[3];
		new Float:oldvelo[3];
		get_user_velocity(id, oldvelo);
		create_velocity_vector(id , attacker , vec);
		vec[0] += oldvelo[0];
		vec[1] += oldvelo[1];
		set_user_velocity(id , vec);
	}

	return PLUGIN_CONTINUE;
}

stock create_velocity_vector(victim,attacker,Float:velocity[3])
{
	if(!zp_get_user_zombie(victim) || !is_user_alive(attacker))
		return 0;

	new Float:vicorigin[3];
	new Float:attorigin[3];
	entity_get_vector(victim   , EV_VEC_origin , vicorigin);
	entity_get_vector(attacker , EV_VEC_origin , attorigin);

	new Float:origin2[3]
	origin2[0] = vicorigin[0] - attorigin[0];
	origin2[1] = vicorigin[1] - attorigin[1];

	new Float:largestnum = 0.0;

	if(floatabs(origin2[0])>largestnum) largestnum = floatabs(origin2[0]);
	if(floatabs(origin2[1])>largestnum) largestnum = floatabs(origin2[1]);

	origin2[0] /= largestnum;
	origin2[1] /= largestnum;

	if (g_knife_combat[attacker])
	{
		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);
		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_combat_knock) * 3000) ) / get_entity_distance(victim , attacker);
	}

	if (g_knife_strong[attacker])
	{
		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);
		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_strong_knock) * 3000) ) / get_entity_distance(victim , attacker);
	}

	if (g_knife_axe[attacker])
	{
		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);
		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_axe_knock) * 3000) ) / get_entity_distance(victim , attacker);
	}

	if (g_knife_hammer[attacker])
	{
		velocity[0] = ( origin2[0] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);
		velocity[1] = ( origin2[1] * (get_pcvar_float(cvar_knife_hammer_knock) * 3000) ) / get_entity_distance(victim , attacker);
	}

	if(velocity[0] <= 20.0 || velocity[1] <= 20.0)
		velocity[2] = random_float(200.0 , 275.0);

	return 1;
}

public client_putinserver(id)
{
	switch(random_num(0, 0))
	{
		case 0:
		{
			g_knife_combat[id] = true
			g_hasSpeed[id] = true
		}

	}
} 