#include <amxmodx>
#include <fakemeta>
#include <zombieplague>

new const g_item_name[] = { "Multijump (+1)" };
const g_item_cost = 25;
new g_maxJumps = 2;

new jumpnum[33] = 0;
new bool:dojump[33] = false;
new g_itemid_multijump;
new g_multijumps[33] = 0;

public plugin_init()
{
	register_plugin("[ZP] Extra Item: Multijump", "1.0", "pharse");
	
	g_itemid_multijump = zp_register_extra_item(g_item_name, g_item_cost, ZP_TEAM_HUMAN);
	
	register_forward(FM_PlayerPreThink, "FW_PlayerPreThink");
	register_forward(FM_PlayerPostThink, "FW_PlayerPostThink");
	
	register_event("HLTV", "EVENT_round_start", "a", "1=0", "2=0");
}

public FW_PlayerPreThink(id)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id) || !g_multijumps[id]) return PLUGIN_CONTINUE
	new nbut = pev(id,pev_button);
	new obut = pev(id,pev_oldbuttons);
	if((nbut & IN_JUMP) && !(pev(id,pev_flags) & FL_ONGROUND) && !(obut & IN_JUMP))
	{
		if(jumpnum[id] < g_multijumps[id])
		{
			dojump[id] = true;
			jumpnum[id]++;
			return PLUGIN_CONTINUE
		}
	}
	if((nbut & IN_JUMP) && (pev(id,pev_flags) & FL_ONGROUND))
	{
		jumpnum[id] = 0;
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}

public FW_PlayerPostThink(id)
{
	if(!is_user_alive(id) || zp_get_user_zombie(id) || !g_multijumps[id]) return PLUGIN_CONTINUE
	if(dojump[id] == true)
	{
		new Float:velocity[3];
		pev(id,pev_velocity,velocity);
		velocity[2] = random_float(265.0,285.0);
		set_pev(id,pev_velocity,velocity)
		dojump[id] = false
		return PLUGIN_CONTINUE
	}
	return PLUGIN_CONTINUE
}	

public zp_extra_item_selected(player, itemid)
{
	if (itemid == g_itemid_multijump){
		if (g_multijumps[player] < g_maxJumps || !g_maxJumps){
			g_multijumps[player]++;
			if (g_maxJumps)
				client_print(player, print_center, "Now you can jump %d / %d times in mid air.", g_multijumps[player], g_maxJumps);
			else
				client_print(player, print_center, "Now you can jump %d times in mid air.", g_multijumps[player]);
		}
		else
			client_print(player, print_center, "You can't jump more than %d times in mid air!", g_maxJumps);
	}
}

public EVENT_round_start()
{
    arrayset(g_multijumps, false, 33)
}