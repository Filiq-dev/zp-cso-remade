#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>
#include <hamsandwich>
#include <xs>
#include <cstrike>
#include <zombieplague>

#define ENG_NULLENT            -1
#define EV_INT_WEAPONKEY    EV_INT_impulse
#define infi_WEAPONKEY         8476
#define MAX_PLAYERS          32
#define IsValidUser(%1) (1 <= %1 <= g_MaxPlayers)

const USE_STOPPED = 0
const OFFSET_ACTIVE_ITEM = 373
const OFFSET_WEAPONOWNER = 41
const OFFSET_LINUX = 5
const OFFSET_LINUX_WEAPONS = 4

#define WEAP_LINUX_XTRA_OFF        4
#define m_pPlayer                            41
#define m_iId                                       43
#define m_fKnown                    44
#define m_flNextPrimaryAttack         46
#define m_flNextSecondaryAttack         47
#define m_flTimeWeaponIdle            48
#define m_iClip                    51
#define m_fInReload                54
#define PLAYER_LINUX_XTRA_OFF    5
#define m_flNextAttack                83

#define infi_DRAW_TIME             1.0
#define infi_RELOAD_TIME        4.5

#define infi_SHOOT_LEFT        1
#define infi_SHOOT_RIGHT        2
#define infi_SHOOT_LEFTLAST    3
#define infi_SHOOT_RIGHTLAST    4
#define infi_SP_SHOOT_LEFT1    5
#define infi_SP_SHOOT_LEFT2    6
#define infi_SP_SHOOT_RIGHT1    7
#define infi_SP_SHOOT_RIGHT2    8
#define infi_SP_SHOOT_LAST    9
#define infi_RELOAD            10
#define infi_DRAW                11

#define write_coord_f(%1)    engfunc(EngFunc_WriteCoord,%1)

new const Fire_Sounds_infi[][] = { "weapons/infi.wav" }
new const Sounds_infi[][] = { "weapons/infi_clipin.wav" , "weapons/infi_clipon.wav" , "weapons/infi_clipout.wav" , "weapons/infi_draw.wav" }

new infi_V_MODEL[64] = "models/zm/v_dinfi.mdl"
new infi_P_MODEL[64] = "models/zm/p_dinfi.mdl"
new infi_W_MODEL[64] = "models/zm/w_dinfi.mdl"

new const GUNSHOT_DECALS[] = { 41, 42, 43, 44, 45 }

new cvar_dmg_infi, cvar_recoil_infi, g_itemid_infi, cvar_clip_infi, cvar_spd_infi, cvar_spd_mode_infi, cvar_infi_ammo
new g_MaxPlayers, g_orig_event_infi, g_orig_event_infi2, g_IsInPrimaryAttack, g_iClip
new Float:cl_pushangle[MAX_PLAYERS + 1][3], m_iBlood[2]
new g_has_infi[33], g_clip_ammo[33], g_infi_TmpClip[33], oldweap[33], g_mode[33]
new gmsgWeaponList

const SECONDARY_WEAPONS_BIT_SUM = (1<<CSW_P228)|(1<<CSW_ELITE)|(1<<CSW_FIVESEVEN)|(1<<CSW_USP)|(1<<CSW_GLOCK18)|(1<<CSW_DEAGLE)
new const WEAPONENTNAMES[][] = { "", "weapon_p228", "", "weapon_scout", "weapon_hegrenade", "weapon_xm1014", "weapon_c4", "weapon_mac10", "weapon_aug", "weapon_smokegrenade", "weapon_elite", "weapon_fiveseven", "weapon_ump45", "weapon_sg550", "weapon_deagle", "weapon_famas", "weapon_usp", "weapon_glock18", "weapon_awp", "weapon_mp5navy", "weapon_m249",
"weapon_m3", "weapon_m4a1", "weapon_tmp", "weapon_g3sg1", "weapon_flashbang", "weapon_deagle", "weapon_sg552",
"weapon_ak47", "weapon_knife", "weapon_p90" }

public plugin_init()
{
    register_plugin("[ZP] Extra: Dual Infinity", "1.0", "Crock / =) (Poprogun4ik) / LARS-DAY[BR]EAKER")
    register_message(get_user_msgid("DeathMsg"), "message_DeathMsg")
    register_event("CurWeapon","CurrentWeapon","be","1=1")
    RegisterHam(Ham_Item_AddToPlayer, "weapon_elite", "fw_infi_AddToPlayer")
    RegisterHam(Ham_Use, "func_tank", "fw_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tankmortar", "fw_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tankrocket", "fw_UseStationary_Post", 1)
    RegisterHam(Ham_Use, "func_tanklaser", "fw_UseStationary_Post", 1)
    for (new i = 1; i < sizeof WEAPONENTNAMES; i++)
    if (WEAPONENTNAMES[i][0]) RegisterHam(Ham_Item_Deploy, WEAPONENTNAMES[i], "fw_Item_Deploy_Post", 1)
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_infi_PrimaryAttack")
    RegisterHam(Ham_Weapon_PrimaryAttack, "weapon_elite", "fw_infi_PrimaryAttack_Post", 1)
    RegisterHam(Ham_Item_PostFrame, "weapon_elite", "infi_ItemPostFrame")
    RegisterHam(Ham_Weapon_Reload, "weapon_elite", "infi_Reload")
    RegisterHam(Ham_Weapon_Reload, "weapon_elite", "infi_Reload_Post", 1)
    RegisterHam(Ham_TakeDamage, "player", "fw_TakeDamage")
    register_forward(FM_SetModel, "fw_SetModel")
    register_forward(FM_UpdateClientData, "fw_UpdateClientData_Post", 1)
    register_forward(FM_PlaybackEvent, "fwPlaybackEvent")
    register_forward(FM_CmdStart, "fw_CmdStart")
    
    RegisterHam(Ham_TraceAttack, "worldspawn", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_breakable", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_wall", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_door", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_door_rotating", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_plat", "fw_TraceAttack", 1)
    RegisterHam(Ham_TraceAttack, "func_rotating", "fw_TraceAttack", 1)

    cvar_clip_infi = register_cvar("zp_infi_clip", "30")
    cvar_infi_ammo = register_cvar("zp_infi_ammo", "200")
    cvar_dmg_infi = register_cvar("zp_infi_dmg", "2.2")
    cvar_recoil_infi = register_cvar("zp_infi_recoil", "0.8")
    cvar_spd_infi = register_cvar("zp_infi_spd", "1.2")
    cvar_spd_mode_infi = register_cvar("zp_infi_mode_spd", "0.95")
    
    g_itemid_infi = zp_register_extra_item("Dual Inf", 3, ZP_TEAM_HUMAN)
    g_MaxPlayers = get_maxplayers()
    gmsgWeaponList = get_user_msgid("WeaponList")
}

public plugin_precache()
{
    precache_model(infi_V_MODEL)
    precache_model(infi_P_MODEL)
    precache_model(infi_W_MODEL)
    for(new i = 0; i < sizeof Fire_Sounds_infi; i++)
    precache_sound(Fire_Sounds_infi[i])    
    for(new i = 0; i < sizeof Sounds_infi; i++)
    precache_sound(Sounds_infi[i])    
    m_iBlood[0] = precache_model("sprites/blood.spr")
    m_iBlood[1] = precache_model("sprites/bloodspray.spr")
    precache_generic("sprites/weapon_infinity.txt")
       precache_generic("sprites/zm/640hud39.spr")
        precache_generic("sprites/zm/640hud7.spr")
    
        register_clcmd("weapon_infinity", "weapon_hook")    

    register_forward(FM_PrecacheEvent, "fwPrecacheEvent_Post", 1)
}

public weapon_hook(id)
{
    engclient_cmd(id, "weapon_elite")
    return PLUGIN_HANDLED
}

public fw_TraceAttack(iEnt, iAttacker, Float:flDamage, Float:fDir[3], ptr, iDamageType)
{
    if(!is_user_alive(iAttacker))
        return

    new g_currentweapon = get_user_weapon(iAttacker)

    if(g_currentweapon != CSW_ELITE) return
    
    if(!g_has_infi[iAttacker]) return

    static Float:flEnd[3]
    get_tr2(ptr, TR_vecEndPos, flEnd)
    
    if(iEnt)
    {
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_DECAL)
        write_coord_f(flEnd[0])
        write_coord_f(flEnd[1])
        write_coord_f(flEnd[2])
        write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
        write_short(iEnt)
        message_end()
    }
    else
    {
        message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
        write_byte(TE_WORLDDECAL)
        write_coord_f(flEnd[0])
        write_coord_f(flEnd[1])
        write_coord_f(flEnd[2])
        write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
        message_end()
    }
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY)
    write_byte(TE_GUNSHOTDECAL)
    write_coord_f(flEnd[0])
    write_coord_f(flEnd[1])
    write_coord_f(flEnd[2])
    write_short(iAttacker)
    write_byte(GUNSHOT_DECALS[random_num (0, sizeof GUNSHOT_DECALS -1)])
    message_end()
}

public zp_user_humanized_post(id)
{
    g_has_infi[id] = false
}

public plugin_natives ()
{
    register_native("give_weapon_infi", "native_give_weapon_add", 1)
}
public native_give_weapon_add(id)
{
    give_infi(id)
}

public fwPrecacheEvent_Post(type, const name[])
{
    if (equal("events/elite_right.sc", name))
    {
        g_orig_event_infi = get_orig_retval()
        return FMRES_HANDLED
    }
    else if (equal("events/elite_left.sc", name))
    {
        g_orig_event_infi = get_orig_retval()
        return FMRES_HANDLED
    }
    return FMRES_IGNORED
}

public client_connect(id)
{
    g_has_infi[id] = false
    g_mode[id] = 0
}

public client_disconnect(id)
{
    g_has_infi[id] = false
    g_mode[id] = 0
}

public zp_user_infected_post(id)
{
    if (zp_get_user_zombie(id))
    {
        g_has_infi[id] = false
        g_mode[id] = 0
    }
}

public fw_SetModel(entity, model[])
{
    if(!is_valid_ent(entity))
        return FMRES_IGNORED
    
    static szClassName[33]
    entity_get_string(entity, EV_SZ_classname, szClassName, charsmax(szClassName))
        
    if(!equal(szClassName, "weaponbox"))
        return FMRES_IGNORED
    
    static iOwner
    
    iOwner = entity_get_edict(entity, EV_ENT_owner)
    
    if(equal(model, "models/w_elite.mdl"))
    {
        static iStoredAugID
        
        iStoredAugID = find_ent_by_owner(ENG_NULLENT, "weapon_elite", entity)
    
        if(!is_valid_ent(iStoredAugID))
            return FMRES_IGNORED
    
        if(g_has_infi[iOwner])
        {
            entity_set_int(iStoredAugID, EV_INT_WEAPONKEY, infi_WEAPONKEY)

            g_has_infi[iOwner] = false

            entity_set_model(entity, infi_W_MODEL)
                        
            return FMRES_SUPERCEDE
        }
    }
    return FMRES_IGNORED
}

public give_infi(id)
{
    drop_weapons(id, 2)
    new iWep2 = give_item(id,"weapon_elite")
    if( iWep2 > 0 )
    {
        g_mode[id] = 0
        cs_set_weapon_ammo(iWep2, get_pcvar_num(cvar_clip_infi))
        cs_set_user_bpammo (id, CSW_ELITE, get_pcvar_num(cvar_infi_ammo))    
        UTIL_PlayWeaponAnimation (id, infi_DRAW)
        set_pdata_float(id, m_flNextAttack, infi_DRAW_TIME, OFFSET_LINUX)

        message_begin(MSG_ONE_UNRELIABLE, gmsgWeaponList, {0,0,0}, id)
        write_string("weapon_infinity")
        write_byte(10)
        write_byte(120)
        write_byte(-1)
        write_byte(-1)
        write_byte(1)
        write_byte(5)
        write_byte(CSW_ELITE)
        message_end()
    }
    g_has_infi[id] = true
}

public zp_extra_item_selected(id, itemid)
{
    if(itemid != g_itemid_infi)
        return

    give_infi(id)
}

public fw_infi_AddToPlayer(infi, id)
{
    if(!is_valid_ent(infi) || !is_user_connected(id))
        return HAM_IGNORED
    
    if(entity_get_int(infi, EV_INT_WEAPONKEY) == infi_WEAPONKEY)
    {
        g_has_infi[id] = true
        entity_set_int(infi, EV_INT_WEAPONKEY, 0)

        message_begin(MSG_ONE_UNRELIABLE, gmsgWeaponList, {0,0,0}, id)
        write_string("weapon_infinity")
        write_byte(10)
        write_byte(120)
        write_byte(-1)
        write_byte(-1)
        write_byte(1)
        write_byte(5)
        write_byte(CSW_ELITE)
        message_end()

        return HAM_HANDLED
    }
    else
    {
        message_begin(MSG_ONE_UNRELIABLE, gmsgWeaponList, {0,0,0}, id)
        write_string("weapon_elite")
        write_byte(10)
        write_byte(120)
        write_byte(-1)
        write_byte(-1)
        write_byte(1)
        write_byte(5)
        write_byte(CSW_ELITE)
        message_end()
    }
    return HAM_IGNORED
}

public fw_UseStationary_Post(entity, caller, activator, use_type)
{
    if (use_type == USE_STOPPED && is_user_connected(caller))
        replace_weapon_models(caller, get_user_weapon(caller))
}

public fw_Item_Deploy_Post(weapon_ent)
{
    static owner
    owner = fm_cs_get_weapon_ent_owner(weapon_ent)
    
    static weaponid
    weaponid = cs_get_weapon_id(weapon_ent)
    
    replace_weapon_models(owner, weaponid)
}

public CurrentWeapon(id)
{
    replace_weapon_models(id, read_data(2))

    if(read_data(2) != CSW_ELITE || !g_has_infi[id])
        return
     
    static Float:iSpeed, Ent
         Ent = find_ent_by_owner(-1,"weapon_deagle",id)

    if(g_mode[id] == 1)
             iSpeed = get_pcvar_float(cvar_spd_mode_infi) 
    else
             iSpeed = get_pcvar_float(cvar_spd_infi) 

         if(Ent)
         {
        static Float:Delay, Float:M_Delay
              Delay = get_pdata_float( Ent, 46, 4) * iSpeed
           M_Delay = get_pdata_float( Ent, 47, 4) * iSpeed
              if(Delay > 0.0)
              {
            set_pdata_float(Ent, 46, Delay, 4)
                   set_pdata_float(Ent, 47, M_Delay, 4)
              }
         }
}

replace_weapon_models(id, weaponid)
{
    switch (weaponid)
    {
        case CSW_ELITE:
        {
            if (zp_get_user_zombie(id) || zp_get_user_survivor(id))
                return
            
            if(g_has_infi[id])
            {
                set_pev(id, pev_viewmodel2, infi_V_MODEL)
                set_pev(id, pev_weaponmodel2, infi_P_MODEL)
                if(oldweap[id] != CSW_ELITE) 
                {
                    UTIL_PlayWeaponAnimation (id, infi_DRAW)
                    set_pdata_float(id, m_flNextAttack, infi_DRAW_TIME, OFFSET_LINUX)

                    message_begin(MSG_ONE_UNRELIABLE, gmsgWeaponList, {0,0,0}, id)
                    write_string("weapon_infinity")
                    write_byte(10)
                    write_byte(120)
                    write_byte(-1)
                    write_byte(-1)
                    write_byte(1)
                    write_byte(5)
                    write_byte(CSW_ELITE)
                    message_end()
                }
            }
        }
    }
    oldweap[id] = weaponid
}

public fw_UpdateClientData_Post(Player, SendWeapons, CD_Handle)
{
    if(!is_user_alive(Player) || (get_user_weapon(Player) != CSW_ELITE || !g_has_infi[Player]))
        return FMRES_IGNORED
    
    set_cd(CD_Handle, CD_flNextAttack, halflife_time () + 0.001)
    return FMRES_HANDLED
}

public fw_infi_PrimaryAttack(Weapon)
{
    new Player = get_pdata_cbase(Weapon, 41, 4)
    
    if (!g_has_infi[Player])
        return
    
    g_IsInPrimaryAttack = 1
    pev(Player,pev_punchangle,cl_pushangle[Player])
    
    g_clip_ammo[Player] = cs_get_weapon_ammo(Weapon)
    g_iClip = cs_get_weapon_ammo(Weapon)
}

public fwPlaybackEvent(flags, invoker, eventid, Float:delay, Float:origin[3], Float:angles[3], Float:fparam1, Float:fparam2, iParam1, iParam2, bParam1, bParam2)
{
    if ((eventid != g_orig_event_infi && eventid != g_orig_event_infi2) || !g_IsInPrimaryAttack)
        return FMRES_IGNORED
    if (!(1 <= invoker <= g_MaxPlayers))
    return FMRES_IGNORED

    playback_event(flags | FEV_HOSTONLY, invoker, eventid, delay, origin, angles, fparam1, fparam2, iParam1, iParam2, bParam1, bParam2)
    return FMRES_SUPERCEDE
}

public fw_CmdStart(id, uc_handle, seed)
{        
         if(!g_has_infi[id])
              return

        if(!is_user_alive(id))
                return
 
        new pItem = get_pdata_cbase(id, OFFSET_ACTIVE_ITEM)
 
        if(get_pdata_int(pItem, m_iId, 4) != CSW_ELITE)
                return
 
        if(get_pdata_float(id, m_flNextAttack) > 0.0)
                return
 
    new szClip, szAmmo
    get_user_weapon(id, szClip, szAmmo)

        new iButtons = get_uc(uc_handle, UC_Buttons)
 
        if(!(iButtons & IN_ATTACK) && (iButtons & IN_ATTACK2))
        {
                if(get_pdata_float(pItem, m_flNextSecondaryAttack, 4) <= 0.0)
                {
                        if(get_pdata_int(pItem, m_iClip) <= 0)
                                return
 
             g_mode[id] = 1
                        ExecuteHamB(Ham_Weapon_PrimaryAttack, find_ent_by_owner(-1, "weapon_elite", id))
            new num
            num = random_num(1,2)
            if(num == 1)UTIL_PlayWeaponAnimation(id, szClip < 1 ? infi_SP_SHOOT_LAST : random_num(infi_SP_SHOOT_LEFT1, infi_SP_SHOOT_RIGHT1))
            if(num == 2)UTIL_PlayWeaponAnimation(id, szClip < 1 ? infi_SP_SHOOT_LAST : random_num(infi_SP_SHOOT_LEFT2, infi_SP_SHOOT_RIGHT2))
                }
        }
    else if(!(iButtons & IN_ATTACK2) && (iButtons & IN_ATTACK))
        {
                if(get_pdata_float(pItem, m_flNextSecondaryAttack, 4) <= 0.0)
                {
                        if(get_pdata_int(pItem, m_iClip) <= 0)
                                return

             g_mode[id] = 0
                }
        }
}

public fw_infi_PrimaryAttack_Post(Weapon)
{
    g_IsInPrimaryAttack = 0
    new Player = get_pdata_cbase(Weapon, 41, 4)
    
    if(!is_user_alive(Player))
        return

    new szClip, szAmmo
    get_user_weapon(Player, szClip, szAmmo)

    if(g_iClip <= cs_get_weapon_ammo(Weapon))
        return

    if(g_has_infi[Player])
    {
        if (!g_clip_ammo[Player])
            return

        new Float:push[3]

        pev(Player,pev_punchangle,push)
        xs_vec_sub(push,cl_pushangle[Player],push)

        xs_vec_mul_scalar(push , get_pcvar_float(cvar_recoil_infi), push)
        xs_vec_add(push,cl_pushangle[Player],push)
        set_pev(Player,pev_punchangle,push)

        UTIL_PlayWeaponAnimation(Player, szClip < 1 ? random_num(infi_SHOOT_LEFTLAST,infi_SHOOT_RIGHTLAST) : random_num(infi_SHOOT_LEFT, infi_SHOOT_RIGHT))

        emit_sound(Player, CHAN_WEAPON, Fire_Sounds_infi[0], VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
    }
}

public fw_TakeDamage(victim, inflictor, attacker, Float:damage)
{
    if (victim != attacker && is_user_connected(attacker))
    {
        if(get_user_weapon(attacker) == CSW_ELITE)
        {
            if(g_has_infi[attacker])
                SetHamParamFloat(4, damage * get_pcvar_float(cvar_dmg_infi))        
        }
    }
}

public message_DeathMsg(msg_id, msg_dest, id)
{
    static szTruncatedWeapon[33], iAttacker, iVictim
    
    get_msg_arg_string(4, szTruncatedWeapon, charsmax(szTruncatedWeapon))
    
    iAttacker = get_msg_arg_int(1)
    iVictim = get_msg_arg_int(2)
    
    if(!is_user_connected(iAttacker) || iAttacker == iVictim)
        return PLUGIN_CONTINUE
    
    if(equal(szTruncatedWeapon, "elite") && get_user_weapon(iAttacker) == CSW_ELITE)
    {
        if(g_has_infi[iAttacker])
            set_msg_arg_string(4, "elite")
    }
    return PLUGIN_CONTINUE
}

stock fm_cs_get_current_weapon_ent(id)
{
    return get_pdata_cbase(id, OFFSET_ACTIVE_ITEM, OFFSET_LINUX)
}

stock fm_cs_get_weapon_ent_owner(ent)
{
    return get_pdata_cbase(ent, OFFSET_WEAPONOWNER, OFFSET_LINUX_WEAPONS)
}

stock UTIL_PlayWeaponAnimation(const Player, const Sequence)
{
    set_pev(Player, pev_weaponanim, Sequence)
    
    message_begin(MSG_ONE_UNRELIABLE, SVC_WEAPONANIM, .player = Player)
    write_byte(Sequence)
    write_byte(pev(Player, pev_body))
    message_end()
}

public infi_ItemPostFrame(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_infi[id])
          return HAM_IGNORED

     static iClipExtra
     
     iClipExtra = get_pcvar_num(cvar_clip_infi)
     new Float:flNextAttack = get_pdata_float(id, m_flNextAttack, PLAYER_LINUX_XTRA_OFF)

     new iBpAmmo = cs_get_user_bpammo(id, CSW_ELITE)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     new fInReload = get_pdata_int(weapon_entity, m_fInReload, WEAP_LINUX_XTRA_OFF) 

     if(fInReload && flNextAttack <= 0.0)
     {
         new j = min(iClipExtra - iClip, iBpAmmo)
    
         set_pdata_int(weapon_entity, m_iClip, iClip + j, WEAP_LINUX_XTRA_OFF)
         cs_set_user_bpammo(id, CSW_ELITE, iBpAmmo-j)
        
         set_pdata_int(weapon_entity, m_fInReload, 0, WEAP_LINUX_XTRA_OFF)
         fInReload = 0
     }
     return HAM_IGNORED
}

public infi_Reload(weapon_entity) 
{
     new id = pev(weapon_entity, pev_owner)
     if (!is_user_connected(id))
          return HAM_IGNORED

     if (!g_has_infi[id])
          return HAM_IGNORED

     static iClipExtra

     if(g_has_infi[id])
          iClipExtra = get_pcvar_num(cvar_clip_infi)

     g_infi_TmpClip[id] = -1

     new iBpAmmo = cs_get_user_bpammo(id, CSW_ELITE)
     new iClip = get_pdata_int(weapon_entity, m_iClip, WEAP_LINUX_XTRA_OFF)

     if (iBpAmmo <= 0)
          return HAM_SUPERCEDE

     if (iClip >= iClipExtra)
          return HAM_SUPERCEDE

     g_infi_TmpClip[id] = iClip

     return HAM_IGNORED
}

public infi_Reload_Post(weapon_entity) 
{
    new id = pev(weapon_entity, pev_owner)
    if (!is_user_connected(id))
        return HAM_IGNORED

    if (!g_has_infi[id])
        return HAM_IGNORED

    if (g_infi_TmpClip[id] == -1)
        return HAM_IGNORED

    set_pdata_int(weapon_entity, m_iClip, g_infi_TmpClip[id], WEAP_LINUX_XTRA_OFF)

    set_pdata_float(weapon_entity, m_flTimeWeaponIdle, infi_RELOAD_TIME, WEAP_LINUX_XTRA_OFF)
    set_pdata_float(id, m_flNextAttack, infi_RELOAD_TIME, PLAYER_LINUX_XTRA_OFF)

    UTIL_PlayWeaponAnimation (id, infi_RELOAD)

    set_pdata_int(weapon_entity, m_fInReload, 1, WEAP_LINUX_XTRA_OFF)

    return HAM_IGNORED
}

stock drop_weapons(id, dropwhat)
{
     static weapons[32], num, i, weaponid
     num = 0
     get_user_weapons(id, weapons, num)
     
     for (i = 0; i < num; i++)
     {
          weaponid = weapons[i]
          
          if (dropwhat == 2 && ((1<<weaponid) & SECONDARY_WEAPONS_BIT_SUM))
          {
               static wname[32]
               get_weaponname(weaponid, wname, sizeof wname - 1)
               engclient_cmd(id, "drop", wname)
          }
     }
} 