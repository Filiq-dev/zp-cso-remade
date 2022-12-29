 new xs__ITaskId;
new xs__ITaskParam[1033] =
{
	0, 32, 60, 92, 140, 164, 208, 256, 304, 80, 73, 83, 84, 79, 76, 83, 0, 83, 72, 79, 84, 71, 85, 78, 83, 0, 65, 85, 84, 79, 77, 65, 67, 72, 73, 78, 69, 83, 0, 82, 73, 70, 76, 69, 83, 0, 77, 65, 67, 72, 73, 78, 69, 71, 85, 78, 83, 0, 72, 95, 69, 88, 84, 82, 65, 73, 84, 69, 77, 83, 0, 90, 95, 69, 88, 84, 82, 65, 73, 84, 69, 77, 83, 0, 75, 78, 73, 70, 69, 83, 0, 8, 48, 76, 69, 86, 69, 76, 83, 95, 69, 88, 80, 0, 76, 69, 86, 69, 76, 83, 95, 87, 69, 65, 80, 75, 69, 89, 0, 36, 40, 44, 48, 52, 56, 60, 64, 68, 97, 0, 98, 0, 99, 0, 100, 0, 101, 0, 102, 0, 103, 0, 104, 0, 105, 0, 200, 220, 252, 268, 284, 304, 324, 356, 368, 392, 412, 432, 452, 480, 496, 508, 536, 568, 588, 612, 628, 644, 684, 720, 744, 760, 796, 824, 848, 892, 912, 924, 932, 944, 956, 976, 988, 1000, 1016, 1032, 1064, 1084, 1108, 1128, 1144, 1168, 1220, 1260, 1304, 1336, 103, 97, 108, 105, 108, 0, 100, 101, 102, 101, 110, 100, 101, 114, 0, 97, 107, 52, 55, 0, 99, 118, 52, 55, 0, 115, 99, 111, 117, 116, 0, 115, 103, 53, 53, 50, 0, 107, 114, 105, 101, 103, 53, 53, 50, 0, 97, 119, 112, 0, 109, 97, 103, 110, 117, 109, 0, 103, 51, 115, 103, 49, 0, 100, 51, 97, 117, 49, 0, 102, 97, 109, 97, 115, 0, 99, 108, 97, 114, 105, 111, 110, 0, 109, 52, 97, 49, 0, 97, 117, 103, 0, 98, 117, 108, 108, 112, 117, 112, 0, 107, 114, 105, 101, 103, 53, 53, 48, 0, 103, 108, 111, 99, 107, 0, 57, 120, 49, 57, 109, 109, 0, 107, 109, 52, 53, 0, 112, 50, 50, 56, 0, 50, 50, 56, 99, 111, 109, 112, 97, 99, 116, 0, 110, 105, 103, 104, 116, 104, 97, 119, 107, 0, 101, 108, 105, 116, 101, 115, 0, 102, 110, 53, 55, 0, 102, 105, 118, 101, 115, 101, 118, 101, 110, 0, 49, 50, 103, 97, 117, 103, 101, 0, 120, 109, 49, 48, 49, 52, 0, 97, 117, 116, 111, 115, 104, 111, 116, 103, 117, 110, 0, 109, 97, 99, 49, 48, 0, 116, 109, 112, 0, 109, 112, 0, 109, 112, 53, 0, 115, 109, 103, 0, 117, 109, 112, 52, 53, 0, 112, 57, 48, 0, 99, 57, 48, 0, 109, 50, 52, 57, 0, 118, 101, 115, 116, 0, 118, 101, 115, 116, 104, 101, 108, 109, 0, 102, 108, 97, 115, 104, 0, 104, 101, 103, 114, 101, 110, 0, 115, 103, 114, 101, 110, 0, 110, 118, 103, 115, 0, 115, 104, 105, 101, 108, 100, 0, 99, 108, 95, 115, 101, 116, 97, 117, 116, 111, 98, 117, 121, 0, 99, 108, 95, 97, 117, 116, 111, 98, 117, 121, 0, 99, 108, 95, 115, 101, 116, 114, 101, 98, 117, 121, 0, 99, 108, 95, 114, 101, 98, 117, 121, 0, 98, 117, 121, 101, 113, 117, 105, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 132, 160, 188, 216, 244, 272, 300, 328, 356, 384, 412, 440, 468, 496, 524, 552, 580, 608, 636, 664, 692, 720, 748, 776, 804, 832, 860, 888, 916, 944, 972, 1000, 1028, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
new xs__TaskFlags[5] =
{
	0, 32, 60, 92, 140
};
new xs__TaskFunc[48] =
{
	0, 32, 60, 92, 140, 164, 208, 256, 304, 80, 73, 83, 84, 79, 76, 83, 0, 83, 72, 79, 84, 71, 85, 78, 83, 0, 65, 85, 84, 79, 77, 65, 67, 72, 73, 78, 69, 83, 0, 82, 73, 70, 76, 69, 83, 0, 77, 65
};
new xs__TaskId;
new Float:xs__TaskInterval;
new xs__TaskParam[1033] =
{
	0, 32, 60, 92, 140, 164, 208, 256, 304, 80, 73, 83, 84, 79, 76, 83, 0, 83, 72, 79, 84, 71, 85, 78, 83, 0, 65, 85, 84, 79, 77, 65, 67, 72, 73, 78, 69, 83, 0, 82, 73, 70, 76, 69, 83, 0, 77, 65, 67, 72, 73, 78, 69, 71, 85, 78, 83, 0, 72, 95, 69, 88, 84, 82, 65, 73, 84, 69, 77, 83, 0, 90, 95, 69, 88, 84, 82, 65, 73, 84, 69, 77, 83, 0, 75, 78, 73, 70, 69, 83, 0, 8, 48, 76, 69, 86, 69, 76, 83, 95, 69, 88, 80, 0, 76, 69, 86, 69, 76, 83, 95, 87, 69, 65, 80, 75, 69, 89, 0, 36, 40, 44, 48, 52, 56, 60, 64, 68, 97, 0, 98, 0, 99, 0, 100, 0, 101, 0, 102, 0, 103, 0, 104, 0, 105, 0, 200, 220, 252, 268, 284, 304, 324, 356, 368, 392, 412, 432, 452, 480, 496, 508, 536, 568, 588, 612, 628, 644, 684, 720, 744, 760, 796, 824, 848, 892, 912, 924, 932, 944, 956, 976, 988, 1000, 1016, 1032, 1064, 1084, 1108, 1128, 1144, 1168, 1220, 1260, 1304, 1336, 103, 97, 108, 105, 108, 0, 100, 101, 102, 101, 110, 100, 101, 114, 0, 97, 107, 52, 55, 0, 99, 118, 52, 55, 0, 115, 99, 111, 117, 116, 0, 115, 103, 53, 53, 50, 0, 107, 114, 105, 101, 103, 53, 53, 50, 0, 97, 119, 112, 0, 109, 97, 103, 110, 117, 109, 0, 103, 51, 115, 103, 49, 0, 100, 51, 97, 117, 49, 0, 102, 97, 109, 97, 115, 0, 99, 108, 97, 114, 105, 111, 110, 0, 109, 52, 97, 49, 0, 97, 117, 103, 0, 98, 117, 108, 108, 112, 117, 112, 0, 107, 114, 105, 101, 103, 53, 53, 48, 0, 103, 108, 111, 99, 107, 0, 57, 120, 49, 57, 109, 109, 0, 107, 109, 52, 53, 0, 112, 50, 50, 56, 0, 50, 50, 56, 99, 111, 109, 112, 97, 99, 116, 0, 110, 105, 103, 104, 116, 104, 97, 119, 107, 0, 101, 108, 105, 116, 101, 115, 0, 102, 110, 53, 55, 0, 102, 105, 118, 101, 115, 101, 118, 101, 110, 0, 49, 50, 103, 97, 117, 103, 101, 0, 120, 109, 49, 48, 49, 52, 0, 97, 117, 116, 111, 115, 104, 111, 116, 103, 117, 110, 0, 109, 97, 99, 49, 48, 0, 116, 109, 112, 0, 109, 112, 0, 109, 112, 53, 0, 115, 109, 103, 0, 117, 109, 112, 52, 53, 0, 112, 57, 48, 0, 99, 57, 48, 0, 109, 50, 52, 57, 0, 118, 101, 115, 116, 0, 118, 101, 115, 116, 104, 101, 108, 109, 0, 102, 108, 97, 115, 104, 0, 104, 101, 103, 114, 101, 110, 0, 115, 103, 114, 101, 110, 0, 110, 118, 103, 115, 0, 115, 104, 105, 101, 108, 100, 0, 99, 108, 95, 115, 101, 116, 97, 117, 116, 111, 98, 117, 121, 0, 99, 108, 95, 97, 117, 116, 111, 98, 117, 121, 0, 99, 108, 95, 115, 101, 116, 114, 101, 98, 117, 121, 0, 99, 108, 95, 114, 101, 98, 117, 121, 0, 98, 117, 121, 101, 113, 117, 105, 112, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 132, 160, 188, 216, 244, 272, 300, 328, 356, 384, 412, 440, 468, 496, 524, 552, 580, 608, 636, 664, 692, 720, 748, 776, 804, 832, 860, 888, 916, 944, 972, 1000, 1028, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};
new xs__TaskRepeat;
new xs__global_null;
new xs__internalseed;
new xs__logtypenames[6][0] =
{
	{
		0, ...
	},
	{
		80, ...
	},
	{
		83, ...
	},
	{
		65, ...
	},
	{
		82, ...
	},
	{
		77, ...
	}
};
new xs__maxnum;
new String:xs__replace_buf[12288];
new SETTINGS_NAMES[8][0] =
{
	{
		80, ...
	},
	{
		83, ...
	},
	{
		65, ...
	},
	{
		82, ...
	},
	{
		77, ...
	},
	{
		72, ...
	},
	{
		90, ...
	},
	{
		75, ...
	}
};
new __dhud_color = 32;
new __dhud_effect = 32;
new __dhud_fadeintime = 32;
new __dhud_fadeouttime = 32;
new __dhud_fxtime = 32;
new __dhud_holdtime = 32;
new __dhud_reliable = 32;
new __dhud_x = 32;
new __dhud_y = 32;
new SETTINGS_NAMES_LEVEL[2][0] =
{
	{
		76, ...
	},
	{
		76, ...
	}
};
new FLAGS[9][0] =
{
	{
		97, ...
	},
	{
		98, ...
	},
	{
		99, ...
	},
	{
		100, ...
	},
	{
		101, ...
	},
	{
		102, ...
	},
	{
		103, ...
	},
	{
		104, ...
	},
	{
		105, ...
	}
};
new Commands[50][0] =
{
	{
		103, ...
	},
	{
		100, ...
	},
	{
		97, ...
	},
	{
		99, ...
	},
	{
		115, ...
	},
	{
		115, ...
	},
	{
		107, ...
	},
	{
		97, ...
	},
	{
		109, ...
	},
	{
		103, ...
	},
	{
		100, ...
	},
	{
		102, ...
	},
	{
		99, ...
	},
	{
		109, ...
	},
	{
		97, ...
	},
	{
		98, ...
	},
	{
		107, ...
	},
	{
		103, ...
	},
	{
		57, ...
	},
	{
		107, ...
	},
	{
		112, ...
	},
	{
		50, ...
	},
	{
		110, ...
	},
	{
		101, ...
	},
	{
		102, ...
	},
	{
		102, ...
	},
	{
		49, ...
	},
	{
		120, ...
	},
	{
		97, ...
	},
	{
		109, ...
	},
	{
		116, ...
	},
	{
		109, ...
	},
	{
		109, ...
	},
	{
		115, ...
	},
	{
		117, ...
	},
	{
		112, ...
	},
	{
		99, ...
	},
	{
		109, ...
	},
	{
		118, ...
	},
	{
		118, ...
	},
	{
		102, ...
	},
	{
		104, ...
	},
	{
		115, ...
	},
	{
		110, ...
	},
	{
		115, ...
	},
	{
		99, ...
	},
	{
		99, ...
	},
	{
		99, ...
	},
	{
		99, ...
	},
	{
		98, ...
	}
};
new g_Menus[8];
new Array:g_Items[8];
new Array:g_ItemsCosts[8];
new Array:g_ItemsFlags2[8];
new Array:g_ItemsLevels[8];
new Array:g_ItemsMinimumPlayers[8];
new Array:g_Levels;
new Array:g_WeaponKeys[2];
new g_LevelsNum;
new g_LockedItem[8];
new g_MsgMoney;
new g_msgMoneyBlink;
new g_File;
new g_maxplayers;
new g_PlayerItemsBitsum[33][8];
new g_PlayerMoney[33];
new g_PlayerSpentMoney[33];
new g_PlayerIsChoosedKnife[33];
new Float:g_PlayerLastSpawnTime[33];
new g_Callback;
new g_CallbackFlags;
new g_fwSpawn;
new g_BuyzoneEnt;
new g_PlayerExp[33];
new g_PlayerLevel[33];
new Float:g_PlayerDamage[33];
new pcvar_open_all_menu_for_zombie;
new pcvar_open_all_menu_for_human;
new pcvar_lvl_system;
new pcvar_xp_given;
new pcvar_xp_given_nem;
new pcvar_xp_given_surv;
new pcvar_damage_for_xp;
new pcvar_xp_for_damage;
new pcvar_lvl_for_zomb;
new pcvar_lvl_for_nem;
new pcvar_lvl_for_surv;
new pcvar_xp_given_infect;
new pcvar_xp_given_kill_lhuman;
new pcvar_save_type;
new pcvar_hud;
new pcvar_money_auttosave;
new pcvar_off_menu_when_mode_start;
new pcvar_time_spawn_for_buy;
new g_database;
new g_database_money;
new g_started;
bool:operator>(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 < floatcmp(oper1, oper2);
}

bool:operator>=(Float:,Float:)(Float:oper1, Float:oper2)
{
	return 0 <= floatcmp(oper1, oper2);
}

replace_all(string[], len, what[], with[])
{
	new pos;
	if ((pos = contain(string, what)) == -1)
	{
		return 0;
	}
	new total;
	new with_len = strlen(with);
	new diff = strlen(what) - with_len;
	new total_len = strlen(string);
	new temp_pos;
	while (replace(string[pos], len - pos, what, with))
	{
		pos = with_len + pos;
		total_len -= diff;
		if (!(pos >= total_len))
		{
			temp_pos = contain(string[pos], what);
			if (!(temp_pos == -1))
			{
				pos = temp_pos + pos;
				total++;
			}
			return total;
		}
		return total;
	}
	return total;
}

get_configsdir(name[], len)
{
	return get_localinfo("amxx_configsdir", name, len);
}

public __fatal_ham_error(Ham:id, HamError:err, reason[])
{
	new func = get_func_id("HamFilter", -1);
	new bool:fail = 1;
	new var1;
	if (func != -1 && callfunc_begin_i(func, -1) == 1)
	{
		callfunc_push_int(id);
		callfunc_push_int(err);
		callfunc_push_str(reason, "amxx_configsdir");
		if (callfunc_end() == 1)
		{
			fail = false;
		}
	}
	if (fail)
	{
		set_fail_state(reason);
	}
	return 0;
}

fm_find_ent_by_integer(index, pev_field, value)
{
	static maxents;
	if (!xs__ITaskId)
	{
		xs__ITaskId = global_get(6);
	}
	new i = index + 1;
	while (i < xs__ITaskId)
	{
		new var1;
		if (pev_valid(i) && value == pev(i, pev_field))
		{
			return i;
		}
		i++;
	}
	return 0;
}

public plugin_init()
{
	register_plugin("[ZP]BuyMenu&MoneySystem", "3.6", "Arwel");
	register_dictionary("buymenu.txt");
	register_clcmd("client_buy_open", "vgui_menu_hook", -1, 5032, -1);
	register_clcmd("buy_wpn", "main_menu_build", -1, 5032, -1);
	register_clcmd("buy", "main_menu_build", -1, 5032, -1);
	new i;
	while (i <= 49)
	{
		register_clcmd(Commands[i], "BlockAutobuy", -1, 5032, -1);
		i++;
	}
	pcvar_open_all_menu_for_zombie = register_cvar("ms_zombie_open_all_menu", 5360, "amxx_configsdir", "amxx_configsdir");
	pcvar_open_all_menu_for_human = register_cvar("ms_human_open_all_menu", 5460, "amxx_configsdir", "amxx_configsdir");
	pcvar_off_menu_when_mode_start = register_cvar("ms_off_menu_when_mode_started", 5588, "amxx_configsdir", "amxx_configsdir");
	pcvar_time_spawn_for_buy = register_cvar("ms_time_for_buy", "15.0", "amxx_configsdir", "amxx_configsdir");
	pcvar_lvl_system = register_cvar("ms_lvl_system_active", 5764, "amxx_configsdir", "amxx_configsdir");
	pcvar_lvl_for_zomb = register_cvar("ms_lvl_system_active_zombie", 5884, "amxx_configsdir", "amxx_configsdir");
	pcvar_lvl_for_nem = register_cvar("ms_lvl_system_active_nem", 5992, "amxx_configsdir", "amxx_configsdir");
	pcvar_lvl_for_surv = register_cvar("ms_lvl_system_active_surv", 6104, "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_given = register_cvar("ms_lvl_system_given_xp", "150", "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_given_nem = register_cvar("ms_lvl_system_given_xp_nem", "10", "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_given_surv = register_cvar("ms_lvl_system_given_xp_surv", "10", "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_given_infect = register_cvar("ms_lvl_system_given_xp_infect", 6584, "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_given_kill_lhuman = register_cvar("ms_lvl_system_given_xp_kill_lhuman", 6732, "amxx_configsdir", "amxx_configsdir");
	pcvar_damage_for_xp = register_cvar("ms_lvl_system_damage_for_xp", "1000", "amxx_configsdir", "amxx_configsdir");
	pcvar_xp_for_damage = register_cvar("ms_lvl_system_given_xp_damage", 6992, "amxx_configsdir", "amxx_configsdir");
	pcvar_save_type = register_cvar("ms_lvl_system_save_type", 7096, "amxx_configsdir", "amxx_configsdir");
	pcvar_money_auttosave = register_cvar("ms_money_autosave", 7176, "amxx_configsdir", "amxx_configsdir");
	pcvar_hud = register_cvar("ms_lvl_system_show_hud", 7276, "amxx_configsdir", "amxx_configsdir");
	register_srvcmd("ExecCvarsBuymenu", "ExecCvarsBuymenu", -1, 7420);
	new confdir[64];
	new path[128];
	get_configsdir(confdir, 63);
	formatex(path, 127, "%s/%s", confdir, "zp_buymenu.cfg");
	server_cmd("exec", path);
	g_Callback = menu_makecallback("main_menu_callback");
	g_CallbackFlags = menu_makecallback("flags_callback");
	register_event("HLTV", "EventRoundStart", 7748, "1=0", "2=0");
	RegisterHam("amxx_configsdir", "player", "fwSpawn", 1);
	RegisterHam(42, "weaponbox", "fwTouch", "amxx_configsdir");
	unregister_forward(91, g_fwSpawn, "amxx_configsdir");
	register_forward(xs__ITaskId, "fw_PlayerPreThink", "amxx_configsdir");
	register_forward("", "fw_SetModelPre", "amxx_configsdir");
	new temp[128];
	new i;
	while (i < 8)
	{
		formatex(temp, 127, "%L", -1, SETTINGS_NAMES[i]);
		g_Menus[i] = menu_create(temp, "weapons_menus_handler", 1);
		formatex(temp, 127, "%L", -1, "EXIT");
		menu_setprop(g_Menus[i], 4, temp);
		formatex(temp, 127, "%L", -1, "NEXT");
		menu_setprop(g_Menus[i], "", temp);
		formatex(temp, 127, "%L", -1, "BACK");
		menu_setprop(g_Menus[i], 2, temp);
		g_Items[i] = ArrayCreate(128, 32);
		g_ItemsCosts[i] = ArrayCreate(1, 32);
		g_ItemsFlags2[i] = ArrayCreate(9, 32);
		g_ItemsLevels[i] = ArrayCreate(1, 32);
		g_ItemsMinimumPlayers[i] = ArrayCreate(1, 32);
		i++;
	}
	g_Levels = ArrayCreate(1, 32);
	g_WeaponKeys[0] = ArrayCreate(1, 32);
	g_WeaponKeys[1] = ArrayCreate(1, 32);
	g_MsgMoney = get_user_msgid("Money");
	g_msgMoneyBlink = get_user_msgid("BlinkAcct");
	register_message(g_MsgMoney, "Msg_Money");
	register_message(get_user_msgid("StatusIcon"), "Msg_StatusIcon");
	g_maxplayers = get_maxplayers();
	return 0;
}

public plugin_cfg()
{
	new confdir[64];
	new path[128];
	get_configsdir(confdir, 63);
	formatex(path, 127, "%s/%s", confdir, "zp_buymenu.ini");
	g_File = fopen(path, "rt");
	new i;
	while (i < 8)
	{
		load_settings_for_section(SETTINGS_NAMES[i], i);
		if (0 >= menu_items(g_Menus[i]))
		{
			g_LockedItem[i] = 1;
		}
		i++;
	}
	new var1 = SETTINGS_NAMES_LEVEL;
	load_settings_for_section(var1[0][var1], -1);
	load_settings_for_section(SETTINGS_NAMES_LEVEL[1], -2);
	fclose(g_File);
	set_cvar_num("zp_remove_money", "amxx_configsdir");
	server_cmd("ExecCvarsBuymenu");
	g_database_money = nvault_open("money_save");
	g_database = nvault_open("lvl_system");
	return 0;
}

public ExecCvarsBuymenu()
{
	set_task(1065353216, "LevelSystemInit", "amxx_configsdir", 8836, "amxx_configsdir", 8840, "amxx_configsdir");
	return 0;
}

public LevelSystemInit()
{
	if (!get_pcvar_num(pcvar_lvl_system))
	{
		return 0;
	}
	RegisterHam(11, "player", "fwKilled", "amxx_configsdir");
	if (get_pcvar_num(pcvar_damage_for_xp))
	{
		RegisterHam(9, "player", "fwTakeDamage", "amxx_configsdir");
	}
	if (get_pcvar_num(pcvar_hud))
	{
		set_task(1050253722, "ShowInfo", -816596391, 8836, "amxx_configsdir", 9024, "amxx_configsdir");
	}
	return 0;
}

public plugin_precache()
{
	g_BuyzoneEnt = engfunc(21, engfunc(43, "func_buyzone"));
	dllfunc(1, g_BuyzoneEnt);
	set_pev(g_BuyzoneEnt, 70, 0);
	g_fwSpawn = register_forward(91, "fw_Spawn", "amxx_configsdir");
	return 0;
}

public plugin_natives()
{
	register_native("zp_cs_set_user_money", "set_user_money", 1);
	register_native("zp_cs_get_user_money", "get_user_money", 1);
	register_native("zp_get_user_level", "native_level_get", 1);
	register_native("zp_set_user_level", "native_level_set", 1);
	register_native("zp_get_user_exp", "native_exp_get", 1);
	register_native("zp_set_user_exp", "native_exp_set", 1);
	register_native("zp_get_exp_current", "native_current", 1);
	return 0;
}

public plugin_end()
{
	if (get_pcvar_num(pcvar_lvl_system))
	{
		nvault_close(g_database);
	}
	nvault_close(g_database_money);
	return 0;
}

public fw_Spawn(ent)
{
	if (!pev_valid(ent))
	{
		return 1;
	}
	new classname[32];
	pev(ent, 1, classname, 31);
	if (equal(classname, "func_buyzone", "amxx_configsdir"))
	{
		engfunc(20, ent);
		return 4;
	}
	return 1;
}

public fwSpawn(id)
{
	g_PlayerLastSpawnTime[id] = get_gametime();
	return 0;
}

public fw_PlayerPreThink(id)
{
	if (!is_user_alive(id))
	{
		return 0;
	}
	dllfunc(4, g_BuyzoneEnt, id);
	return 0;
}

public fw_SetModelPre(ent, model[])
{
	if (!g_LevelsNum)
	{
		return 1;
	}
	if (!pev_valid(ent))
	{
		return 1;
	}
	static classname[33];
	pev(ent, 1, classname, 32);
	if (!equal(classname, "weaponbox", "amxx_configsdir"))
	{
		return 1;
	}
	if (pev(ent, 101))
	{
		return 1;
	}
	new weap;
	new i;
	while (ArraySize(g_WeaponKeys[0]) > i)
	{
		weap = fm_find_ent_by_integer(-1, 82, ArrayGetCell(g_WeaponKeys[0], i));
		if (ent == pev(weap, 18))
		{
			set_pev(ent, 101, ArrayGetCell(g_WeaponKeys[1], i));
			return 1;
		}
		i++;
	}
	return 1;
}

public fwTouch(ent, id)
{
	if (!g_LevelsNum)
	{
		return 1;
	}
	if (!is_user_alive(id))
	{
		return 1;
	}
	if (g_PlayerLevel[id] < pev(ent, 101))
	{
		return 4;
	}
	return 1;
}

public client_authorized(id)
{
	set_user_info(id, "_vgui_menus", 10344);
	client_cmd(id, "setinfo _vgui_menus 0");
	client_cmd(id, "unbind b");
	client_cmd(id, "bind b buy");
	return 0;
}

public client_connect(id)
{
	if (get_pcvar_num(pcvar_lvl_system))
	{
		g_PlayerLevel[id] = 0;
		LevelLoad(id);
	}
	MoneyLoad(id);
	return 0;
}

public client_disconnect(id)
{
	if (!get_pcvar_num(pcvar_lvl_system))
	{
		return 0;
	}
	LevelSave(id);
	g_PlayerExp[id] = 0;
	g_PlayerLevel[id] = 0;
	return 0;
}

public EventRoundStart()
{
	client_cmd("amxx_configsdir", "setinfo _vgui_menus 0");
	arrayset(g_PlayerSpentMoney, "amxx_configsdir", 32);
	arrayset(g_PlayerIsChoosedKnife, "amxx_configsdir", 32);
	new i;
	new item;
	new type;
	while (type < 8)
	{
		item = 0;
		while (ArraySize(g_Items[type]) > item)
		{
			if (!(ArraySize(g_ItemsFlags2[type]) <= item))
			{
				if (ArrayGetCell(g_ItemsFlags2[type], item) & 128)
				{
					i = 1;
					while (i <= g_maxplayers)
					{
						new var1 = g_PlayerItemsBitsum[i][type];
						var1 = ~1 << item & var1;
						i++;
					}
				}
				item++;
			}
			type++;
		}
		type++;
	}
	g_started = 0;
	return 0;
}

public Msg_Money(msg_id, msg_dest, msg_entity)
{
	if (get_msg_arg_int(2))
	{
		return 1;
	}
	set_msg_arg_int(1, 4, g_PlayerMoney[msg_entity]);
	return 0;
}

public Msg_StatusIcon(msg_id, msg_dest, msg_entity)
{
	new var1;
	if (!is_user_alive(msg_entity) || get_msg_arg_int(1) == 1)
	{
		return 0;
	}
	static sprite[10];
	get_msg_arg_string(2, sprite, 9);
	if (!equal(sprite, "buyzone", "amxx_configsdir"))
	{
		return 0;
	}
	set_msg_arg_int("", get_msg_argtype(1), "amxx_configsdir");
	set_msg_arg_int(4, get_msg_argtype(1), "amxx_configsdir");
	set_msg_arg_int(5, get_msg_argtype(1), "amxx_configsdir");
	return 0;
}

public zp_round_started(gamemode, id)
{
	new i = 1;
	while (i <= g_maxplayers)
	{
		if (is_user_alive(i))
		{
			new var1;
			if (zp_get_user_zombie(i) || zp_get_user_survivor(i))
			{
				set_user_money(i, g_PlayerSpentMoney[i][g_PlayerMoney[i]]);
			}
			menu_cancel(i);
		}
		i++;
	}
	g_started = 1;
	return 0;
}

public fwKilled(id, killer)
{
	menu_cancel(id);
	if (!is_user_alive(killer))
	{
		return 0;
	}
	new var1;
	if (zp_get_user_zombie(killer) && !get_pcvar_num(pcvar_lvl_for_zomb))
	{
		return 0;
	}
	new var2;
	if (zp_get_user_survivor(killer) && !get_pcvar_num(pcvar_lvl_for_surv))
	{
		return 0;
	}
	new var3;
	if (zp_get_user_nemesis(killer) && !get_pcvar_num(pcvar_lvl_for_nem))
	{
		return 0;
	}
	if (zp_get_user_nemesis(id))
	{
		ExpUp(killer, get_pcvar_num(pcvar_xp_given_nem));
	}
	else
	{
		if (zp_get_user_survivor(id))
		{
			ExpUp(killer, get_pcvar_num(pcvar_xp_given_surv));
		}
		if (zp_get_user_last_human(id))
		{
			ExpUp(killer, get_pcvar_num(pcvar_xp_given_kill_lhuman));
		}
		ExpUp(killer, get_pcvar_num(pcvar_xp_given));
	}
	if (ArrayGetCell(g_Levels, g_PlayerLevel[killer]) <= g_PlayerExp[killer])
	{
		LevelUp(killer);
	}
	return 0;
}

public fwTakeDamage(id, inflictor, attacker, Float:damage)
{
	if (!is_user_alive(attacker))
	{
		return 0;
	}
	new var1;
	if (zp_get_user_zombie(attacker) && !get_pcvar_num(pcvar_lvl_for_zomb))
	{
		return 0;
	}
	new var2;
	if (zp_get_user_survivor(attacker) && !get_pcvar_num(pcvar_lvl_for_surv))
	{
		return 0;
	}
	new var3;
	if (zp_get_user_nemesis(attacker) && !get_pcvar_num(pcvar_lvl_for_nem))
	{
		return 0;
	}
	new var4 = g_PlayerDamage[attacker];
	var4 = floatadd(var4, damage);
	if (g_PlayerDamage[attacker] >= get_pcvar_float(pcvar_damage_for_xp))
	{
		ExpUp(attacker, get_pcvar_num(pcvar_xp_for_damage));
		new var5 = g_PlayerDamage[attacker];
		var5 = floatsub(var5, get_pcvar_float(pcvar_damage_for_xp));
	}
	if (ArrayGetCell(g_Levels, g_PlayerLevel[attacker]) <= g_PlayerExp[attacker])
	{
		LevelUp(attacker);
	}
	return 0;
}

public zp_user_infected_pre(id, infector)
{
	if (!is_user_alive(infector))
	{
		return 0;
	}
	new var1;
	if (!get_pcvar_num(pcvar_lvl_system) || !get_pcvar_num(pcvar_lvl_for_zomb))
	{
		return 0;
	}
	ExpUp(infector, get_pcvar_num(pcvar_xp_given_infect));
	if (ArrayGetCell(g_Levels, g_PlayerLevel[infector]) <= g_PlayerExp[infector])
	{
		LevelUp(infector);
	}
	return 0;
}

public LevelUp(id)
{
	new var1;
	if (!g_LevelsNum || g_PlayerLevel[id] >= g_LevelsNum)
	{
		return 0;
	}
	g_PlayerExp[id] -= ArrayGetCell(g_Levels, g_PlayerLevel[id]);
	g_PlayerLevel[id]++;
	LevelSave(id);
	return 0;
}

public ExpUp(id, xp)
{
	new var1;
	if (!g_LevelsNum || g_PlayerLevel[id] >= g_LevelsNum)
	{
		return 0;
	}
	new var2 = g_PlayerExp[id];
	var2 = var2[xp];
	return 0;
}

public LevelSave(id)
{
	new PlayerData[40];
	switch (get_pcvar_num(pcvar_save_type))
	{
		case 0:
		{
			get_user_authid(id, PlayerData, 39);
		}
		case 1:
		{
			get_user_name(id, PlayerData, 39);
		}
		case 2:
		{
			get_user_ip(id, PlayerData, 39, 1);
		}
		default:
		{
		}
	}
	new vaultkey[64];
	new vaultdata[256];
	format(vaultkey, "", "%s", PlayerData);
	format(vaultdata, 255, "%i#%i#", g_PlayerExp[id], g_PlayerLevel[id]);
	nvault_set(g_database, vaultkey, vaultdata);
	return 0;
}

public LevelLoad(id)
{
	new PlayerData[40];
	switch (get_pcvar_num(pcvar_save_type))
	{
		case 0:
		{
			get_user_authid(id, PlayerData, 39);
			if (equal(PlayerData, "STEAM_ID_LAN", "amxx_configsdir"))
			{
				g_PlayerExp[id] = 0;
				g_PlayerLevel[id] = 0;
				return 0;
			}
		}
		case 1:
		{
			get_user_name(id, PlayerData, 39);
		}
		case 2:
		{
			get_user_ip(id, PlayerData, 39, 1);
		}
		default:
		{
		}
	}
	new vaultkey[64];
	new vaultdata[256];
	format(vaultkey, "", "%s", PlayerData);
	format(vaultdata, 255, "%i#%i#", g_PlayerExp[id], g_PlayerLevel[id]);
	nvault_get(g_database, vaultkey, vaultdata, 255);
	replace_all(vaultdata, 255, 10812, 10820);
	new playerxp[32];
	new playerlevel[32];
	parse(vaultdata, playerxp, 31, playerlevel, 31);
	g_PlayerExp[id] = str_to_num(playerxp);
	g_PlayerLevel[id] = str_to_num(playerlevel);
	g_PlayerLevel[id] = clamp(g_PlayerLevel[id], "amxx_configsdir", g_LevelsNum + -1);
	return 0;
}

public MoneySave(id)
{
	if (!get_pcvar_num(pcvar_money_auttosave))
	{
		return 0;
	}
	new PlayerData[40];
	switch (get_pcvar_num(pcvar_save_type))
	{
		case 0:
		{
			get_user_authid(id, PlayerData, 39);
		}
		case 1:
		{
			get_user_name(id, PlayerData, 39);
		}
		case 2:
		{
			get_user_ip(id, PlayerData, 39, 1);
		}
		default:
		{
		}
	}
	new vaultkey[64];
	new vaultdata[256];
	format(vaultkey, "", "%s", PlayerData);
	format(vaultdata, 255, "%i#", g_PlayerMoney[id]);
	nvault_set(g_database_money, vaultkey, vaultdata);
	return 0;
}

public MoneyLoad(id)
{
	if (!get_pcvar_num(pcvar_money_auttosave))
	{
		return 0;
	}
	new PlayerData[40];
	switch (get_pcvar_num(pcvar_save_type))
	{
		case 0:
		{
			get_user_authid(id, PlayerData, 39);
		}
		case 1:
		{
			get_user_name(id, PlayerData, 39);
		}
		case 2:
		{
			get_user_ip(id, PlayerData, 39, 1);
		}
		default:
		{
		}
	}
	new vaultkey[64];
	new vaultdata[256];
	format(vaultkey, "", "%s", PlayerData);
	format(vaultdata, 255, "%i#", g_PlayerMoney[id]);
	nvault_get(g_database_money, vaultkey, vaultdata, 255);
	replace_all(vaultdata, 255, 10884, 10892);
	new player_money[32];
	parse(vaultdata, player_money, 31);
	g_PlayerMoney[id] = str_to_num(player_money);
	return 0;
}

public ShowInfo(TASKID)
{
	new i = 1;
	while (i <= g_maxplayers)
	{
		if (is_user_alive(i))
		{
			set_hudmessage("amxx_configsdir", 255, "amxx_configsdir", -1082130432, 1063675494, "amxx_configsdir", "amxx_configsdir", floatadd(1050253722, 1036831949), "amxx_configsdir", "amxx_configsdir", 4);
			show_hudmessage(i, "%L", 0, "HUD_MESSAGE_DOWN", g_PlayerLevel[i], g_PlayerExp[i], ArrayGetCell(g_Levels, g_PlayerLevel[i]));
		}
		i++;
	}
	return 0;
}

public native_level_get(id)
{
	return g_PlayerLevel[id];
}

public native_exp_get(id)
{
	return g_PlayerExp[id];
}

public native_level_set(id, value)
{
	new var1 = value;
	g_PlayerLevel[id] = var1;
	return var1;
}

public native_exp_set(id, value)
{
	new var1 = value;
	g_PlayerExp[id] = var1;
	return var1;
}

public native_current(id)
{
	new var1;
	if (g_PlayerLevel[id] >= g_LevelsNum)
	{
		var1 = 0;
	}
	else
	{
		var1 = ArrayGetCell(g_Levels, g_PlayerLevel[id]);
	}
	return var1;
}

public BlockAutobuy(id)
{
	return 1;
}

public vgui_menu_hook(id)
{
	if (!is_user_alive(id))
	{
		return 0;
	}
	message_begin(1, get_user_msgid("BuyClose"), 11016, id);
	message_end();
	main_menu_build(id);
	return 1;
}

public main_menu_build(id)
{
	new var1;
	if (!is_user_alive(id) || zp_get_user_survivor(id))
	{
		return 1;
	}
	new zomb = zp_get_user_zombie(id);
	new var2;
	if (zomb && !get_pcvar_num(pcvar_open_all_menu_for_zombie))
	{
		menu_display(id, g_Menus[6], "amxx_configsdir");
		return 1;
	}
	new var3;
	if (floatsub(get_gametime(), g_PlayerLastSpawnTime[id]) > get_pcvar_float(pcvar_time_spawn_for_buy) && !get_pcvar_num(pcvar_open_all_menu_for_human) && g_started)
	{
		menu_display(id, g_Menus[zomb + 5], "amxx_configsdir");
		return 1;
	}
	new temp[128];
	new temp2[10];
	formatex(temp, 127, "%L", id, "MAIN_MENU");
	formatex(temp2, 9, "%i", zomb + 5);
	new menu = menu_create(temp, "main_menu_handler", "amxx_configsdir");
	formatex(temp, 127, "%L", id, "PISTOLS");
	menu_additem(menu, temp, 11208, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L", id, "SHOTGUNS");
	menu_additem(menu, temp, 11264, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L", id, "AUTOMACHINES");
	menu_additem(menu, temp, 11336, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L", id, "RIFLES");
	menu_additem(menu, temp, 11384, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L\n", id, "MACHINEGUNS");
	menu_additem(menu, temp, 11456, "amxx_configsdir", g_Callback);
	new var4;
	if (zomb)
	{
		var4 = 11480;
	}
	else
	{
		var4 = 11532;
	}
	formatex(temp, 127, "%L\n", id, var4);
	menu_additem(menu, temp, temp2, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L", id, "KNIFES");
	menu_additem(menu, temp, 11624, "amxx_configsdir", g_Callback);
	formatex(temp, 127, "%L", id, "EXIT");
	menu_setprop(menu, 4, temp);
	formatex(temp, 127, "%l", id, "NEXT");
	menu_setprop(menu, "", temp);
	formatex(temp, 127, "%l", id, "BACK");
	menu_setprop(menu, 2, temp);
	menu_display(id, menu, "amxx_configsdir");
	return 1;
}

public main_menu_handler(id, menu, item)
{
	if (item == -3)
	{
		menu_destroy(menu);
		return 1;
	}
	new var1;
	if (zp_get_user_zombie(id) && item == 5)
	{
		menu_display(id, g_Menus[6], "amxx_configsdir");
		menu_destroy(menu);
		return 1;
	}
	if (item >= 6)
	{
		item++;
	}
	if (item == 7)
	{
		client_cmd(id, "knife");
		return 1;
	}
	new name[64];
	formatex(name, "", "%L", id, SETTINGS_NAMES[item]);
	menu_setprop(g_Menus[item], 5, name);
	formatex(name, "", "%L", id, "EXIT");
	menu_setprop(g_Menus[item], 4, name);
	formatex(name, "", "%L", id, "BACK");
	menu_setprop(g_Menus[item], 2, name);
	formatex(name, "", "%L", id, "NEXT");
	menu_setprop(g_Menus[item], "", name);
	menu_display(id, g_Menus[item], "amxx_configsdir");
	menu_destroy(menu);
	return 0;
}

public main_menu_callback(id, menu, item)
{
	new var1;
	if ((zp_get_user_zombie(id) && item != 5) || (g_LockedItem[item] || (item == 7 && g_PlayerIsChoosedKnife[id])))
	{
		return 2;
	}
	new var4;
	if (floatsub(get_gametime(), g_PlayerLastSpawnTime[id]) > get_pcvar_float(pcvar_time_spawn_for_buy) && get_pcvar_num(pcvar_off_menu_when_mode_start) && item != 5 && g_started)
	{
		return 2;
	}
	return 1;
}

public flags_callback(id, menu, item)
{
	static i;
	static index;
	i = 0;
	while (i < 8)
	{
		if (menu == g_Menus[i])
		{
			index = i;
		}
		i += 1;
	}
	if (g_PlayerMoney[id] < ArrayGetCell(g_ItemsCosts[index], item))
	{
		return 2;
	}
	new var1;
	if (get_pcvar_num(pcvar_lvl_system) && ArrayGetCell(g_ItemsLevels[index], item) > g_PlayerLevel[id])
	{
		return 2;
	}
	if (ArrayGetCell(g_ItemsMinimumPlayers[index], item) > get_playersnum("amxx_configsdir"))
	{
		return 2;
	}
	if (ArraySize(g_ItemsFlags2[index]))
	{
		static flag;
		flag = ArrayGetCell(g_ItemsFlags2[index], item);
		new var2;
		if (flag & 1 && !g_started)
		{
			return 2;
		}
		new var3;
		if (flag & 128 || flag & 256)
		{
			if (1 << item & g_PlayerItemsBitsum[id][index])
			{
				return 2;
			}
		}
		new var4;
		if (!flag & 2 && zp_get_user_nemesis(id))
		{
			return 2;
		}
		new var5;
		if (flag & 4 && zp_get_user_first_zombie(id))
		{
			return 2;
		}
		new var6;
		if (flag & 8 && zp_is_nemesis_round())
		{
			return 2;
		}
		new var7;
		if (flag & 16 && zp_is_survivor_round())
		{
			return 2;
		}
		new var8;
		if (flag & 32 && zp_is_swarm_round())
		{
			return 2;
		}
		new var9;
		if (flag & 64 && zp_is_plague_round())
		{
			return 2;
		}
	}
	return 0;
}

public weapons_menus_handler(id, menu, item)
{
	new var1;
	if (item == -3 || zp_get_user_survivor(id))
	{
		return 1;
	}
	new var2;
	if (zp_get_user_zombie(id) && g_Menus[6] != menu)
	{
		return 1;
	}
	new data[6];
	new iName[64];
	new Access;
	new callback;
	menu_item_getinfo(menu, item, Access, data, 5, iName, "", callback);
	new PistolRealName[128];
	new cost;
	new index;
	new i;
	while (i < 8)
	{
		if (menu == g_Menus[i])
		{
			index = i;
		}
		i++;
	}
	ArrayGetString(g_Items[index], item, PistolRealName, 127);
	cost = ArrayGetCell(g_ItemsCosts[index], item);
	new var3 = g_PlayerItemsBitsum[id][index];
	var3 = 1 << item | var3;
	if (cost > g_PlayerMoney[id])
	{
		make_blink(id, 5);
		client_print(id, 4, "%L", id, "NO_MONEY");
		return 0;
	}
	new itemid = zp_get_extra_item_id(PistolRealName);
	if (itemid == -1)
	{
		log_amx("Item not found: %s", PistolRealName);
		return 0;
	}
	switch (index)
	{
		case 0:
		{
			drop_weapons(id, 2);
		}
		case 1, 2, 3, 4:
		{
			drop_weapons(id, 1);
		}
		case 7:
		{
			g_PlayerIsChoosedKnife[id] = 1;
		}
		default:
		{
		}
	}
	set_user_money(id, g_PlayerMoney[id] - cost);
	new var4 = g_PlayerSpentMoney[id];
	var4 = var4[cost];
	zp_force_buy_extra_item(id, itemid, 1);
	return 0;
}

public load_settings_for_section(setting_section[], type)
{
	if (!g_File)
	{
		return -1;
	}
	new linedata[512];
	new section[64];
	new weapon_name_lang[256];
	new weapon_name_real[128];
	new cost[10];
	new flags[9];
	new level[9];
	new min_players[9];
	fseek(g_File, "amxx_configsdir", "amxx_configsdir");
	while (!feof(g_File))
	{
		fgets(g_File, linedata, 511);
		new var1;
		if (!(linedata[0] == 59 || linedata[0] == 47))
		{
			replace(linedata, 511, 11996, 12004);
			if (linedata[0] == 91)
			{
				copyc(section, "", linedata[1], 93);
				if (equal(section, setting_section, "amxx_configsdir"))
				{
					while (!feof(g_File))
					{
						copy(linedata, 511, 12008);
						fgets(g_File, linedata, 511);
						new var2;
						if (!(linedata[0] == 123 || linedata[0] == 59 || linedata[0] == 47))
						{
							if (!(linedata[0] == 125))
							{
								replace(linedata, 511, 12012, 12020);
								replace(linedata, 511, 12024, 12032);
								trim(linedata);
								if (linedata[0])
								{
									if (type == -1)
									{
										parse(linedata, level, 8);
										g_LevelsNum += 1;
										ArrayPushCell(g_Levels, str_to_num(level));
									}
									else
									{
										if (type == -2)
										{
											parse(linedata, weapon_name_lang, 255, weapon_name_real, 127);
											ArrayPushCell(g_WeaponKeys[0], str_to_num(weapon_name_lang));
											ArrayPushCell(g_WeaponKeys[1], str_to_num(weapon_name_real));
										}
										parse(linedata, weapon_name_lang, 255, weapon_name_real, 127, cost, 9, flags, 9, level, 8, min_players, 8);
										register_item(weapon_name_lang, weapon_name_real, str_to_num(cost), flags, type, str_to_num(level), str_to_num(min_players));
										weapon_name_lang = {0};
										weapon_name_real = {0};
										flags = {0};
										level = {0};
										min_players = {0};
									}
								}
							}
							return 0;
						}
					}
					return 0;
				}
			}
		}
	}
	while (!feof(g_File))
	{
		copy(linedata, 511, 12008);
		fgets(g_File, linedata, 511);
		new var2;
		if (!(linedata[0] == 123 || linedata[0] == 59 || linedata[0] == 47))
		{
			if (!(linedata[0] == 125))
			{
				replace(linedata, 511, 12012, 12020);
				replace(linedata, 511, 12024, 12032);
				trim(linedata);
				if (linedata[0])
				{
					if (type == -1)
					{
						parse(linedata, level, 8);
						g_LevelsNum += 1;
						ArrayPushCell(g_Levels, str_to_num(level));
					}
					else
					{
						if (type == -2)
						{
							parse(linedata, weapon_name_lang, 255, weapon_name_real, 127);
							ArrayPushCell(g_WeaponKeys[0], str_to_num(weapon_name_lang));
							ArrayPushCell(g_WeaponKeys[1], str_to_num(weapon_name_real));
						}
						parse(linedata, weapon_name_lang, 255, weapon_name_real, 127, cost, 9, flags, 9, level, 8, min_players, 8);
						register_item(weapon_name_lang, weapon_name_real, str_to_num(cost), flags, type, str_to_num(level), str_to_num(min_players));
						weapon_name_lang = {0};
						weapon_name_real = {0};
						flags = {0};
						level = {0};
						min_players = {0};
					}
				}
			}
			return 0;
		}
	}
	return 0;
}

public register_item(weapon_name_lang[], weapon_name_real[], cost, flags[], type, level, min_players)
{
	new MenuName[128];
	new var1;
	if (weapon_name_lang[0] || weapon_name_real[0])
	{
		if (level)
		{
			formatex(MenuName, 127, "%s %L%L", weapon_name_lang, 0, "LANG_LVL", level, 0, "LANG_COST", cost);
		}
		else
		{
			formatex(MenuName, 127, "%s %L", weapon_name_lang, 0, "LANG_COST", cost);
		}
		if (min_players)
		{
			formatex(MenuName, 127, "%s %L", MenuName, 0, "LANG_PLAYERS", min_players);
		}
		menu_additem(g_Menus[type], MenuName, 12304, "amxx_configsdir", g_CallbackFlags);
	}
	new flag;
	new i;
	while (i <= 8)
	{
		if (containi(flags, FLAGS[i]) != -1)
		{
			flag = 1 << i | flag;
		}
		i++;
	}
	ArrayPushCell(g_ItemsFlags2[type], flag);
	ArrayPushString(g_Items[type], weapon_name_real);
	ArrayPushCell(g_ItemsCosts[type], cost);
	ArrayPushCell(g_ItemsLevels[type], level);
	ArrayPushCell(g_ItemsMinimumPlayers[type], min_players);
	return 0;
}

public get_user_money(id)
{
	return g_PlayerMoney[id];
}

public set_user_money(id, value)
{
	g_PlayerMoney[id] = value;
	MoneySave(id);
	if (!is_user_alive(id))
	{
		return 0;
	}
	sent_money(id, value);
	return 0;
}

sent_money(id, num)
{
	message_begin(1, g_MsgMoney, 11016, id);
	write_long(num);
	write_byte(1);
	message_end();
	return 0;
}

make_blink(id, num)
{
	message_begin(1, g_msgMoneyBlink, 11016, id);
	write_byte(num);
	message_end();
	return 0;
}

drop_weapons(id, dropwhat)
{
	static i;
	static num;
	static weapons[32];
	static wname[32];
	num = 0;
	get_user_weapons(id, weapons, num);
	i = 0;
	while (i < num)
	{
		new var1;
		if ((dropwhat == 1 && 1 << weapons[i] & 1509749160) || (dropwhat == 2 && 1 << weapons[i] & 67308546))
		{
			get_weaponname(weapons[i], wname, 31);
			engclient_cmd(id, "drop", wname, 12596);
		}
		i += 1;
	}
	return 0;
}

 
