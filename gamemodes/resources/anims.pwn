static const g_aPreloadLibs[][] =
{
    "AIRPORT",      "ATTRACTORS",   "BAR",          "BASEBALL",     "BD_FIRE",
    "BEACH",        "BENCHPRESS",   "BF_INJECTION", "BIKE_DBZ",     "BIKED",
    "BIKEH",        "BIKELEAP",     "BIKES",        "BIKEV",        "BLOWJOBZ",
    "BMX",          "BOMBER",       "BOX",          "BSKTBALL",     "BUDDY",
    "BUS",          "CAMERA",       "CAR",          "CAR_CHAT",     "CARRY",
    "CASINO",       "CHAINSAW",     "CHOPPA",       "CLOTHES",      "COACH",
    "COLT45",       "COP_AMBIENT",  "COP_DVBYZ",    "CRACK",        "CRIB",
    "DAM_JUMP",     "DANCING",      "DEALER",       "DILDO",        "DODGE",
    "DOZER",        "DRIVEBYS",     "FAT",          "FIGHT_B",      "FIGHT_C",
    "FIGHT_D",      "FIGHT_E",      "FINALE",       "FINALE2",      "FLAME",
    "FLOWERS",      "FOOD",         "FREEWEIGHTS",  "GANGS",        "GFUNK",
    "GHANDS",       "GHETTO_DB",    "GOGGLES",      "GRAFFITI",     "GRAVEYARD",
    "GRENADE",      "GYMNASIUM",    "HAIRCUTS",     "HEIST9",       "INT_HOUSE",
    "INT_OFFICE",   "INT_SHOP",     "JST_BUISNESS", "KART",         "KISSING",
    "KNIFE",        "LAPDAN1",      "LAPDAN2",      "LAPDAN3",      "LOWRIDER",
    "MD_CHASE",     "MD_END",       "MEDIC",        "MISC",         "MTB",
    "MUSCULAR",     "NEVADA",       "ON_LOOKERS",   "OTB",          "PARACHUTE",
    "PARK",         "PAULNMAC",     "PED",          "PLAYER_DVBYS", "PLAYIDLES",
    "POLICE",       "POOL",         "POOR",         "PYTHON",       "QUAD",
    "QUAD_DBZ",     "RAPPING",      "RIFLE",        "RIOT",         "ROB_BANK",
    "ROCKET",       "RUNNINGMAN",   "RUSTLER",      "RYDER",        "SCRATCHING",
    "SEX",          "SHAMAL",       "SHOP",         "SHOTGUN",      "SILENCED",
    "SKATE",        "SMOKING",      "SNIPER",       "SNM",          "SPRAYCAN",
    "STRIP",        "SUNBATHE",     "SWAT",         "SWEET",        "SWIM",
    "SWORD",        "TANK",         "TATTOOS",      "TEC",          "TRAIN",
    "TRUCK",        "UZI",          "VAN",          "VENDING",      "VORTEX",
    "WAYFARER",     "WEAPONS",      "WOP",          "WUZI"
};

stock ApplyPlayerAnimation(playerid, animlib[], animname[], Float:fDelta, loop, lockx, locky, freeze, time, forcesync = 0)
{
    ApplyAnimation(playerid, animlib, "null", fDelta, loop, lockx, locky, freeze, time, forcesync);
    return ApplyAnimation(playerid, animlib, animname, fDelta, loop, lockx, locky, freeze, time, forcesync);
}

stock PreloadAnimations(playerid)
{
    for (new i = 0; i < sizeof(g_aPreloadLibs); i ++) {
        ApplyAnimation(playerid, g_aPreloadLibs[i], "null", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:crack(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/crack [1-2]");
    if(!strcmp(params, "1", true))
    {
   		ApplyPlayerAnimation(playerid, "CRACK", "crckdeth2", 4.0, 1, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
   		ApplyPlayerAnimation(playerid, "CRACK", "crckidle1", 4.0, 1, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:chat(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "MISC", "IDLE_CHAT_02", 2.0, 1, 0, 0, 0, 10000, 1);
	return 1;
}

CMD:hike(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PED","idle_taxi", 3.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:caract(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PED","TAP_HAND",4.0, 1, 0 , 0, 0, 0, 1);
	return 1;
}

CMD:give(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"KISSING","gift_give",3.0,0,0,0,0,0,1);
	return 1;
}

CMD:liftup(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "CARRY", "LIFTUP", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:putdown(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "CARRY", "PUTDWN", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:cry(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "GRAVEYARD", "MRNF_LOOP", 4.0, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:mourn(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "GRAVEYARD", "MRNM_LOOP", 4.0, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:endchat(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PED","endchat_01",8.0,0,0,0,0,0,1);
	return 1;
}

CMD:show(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "ON_LOOKERS", "point_loop", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:shoutanim(playerid, params[])
{
    ApplyPlayerAnimation(playerid, "ON_LOOKERS", "shout_loop", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:look(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "ON_LOOKERS", "lkup_loop", 4.0, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:drunk(playerid, params[])
{
	ApplyAnimation(playerid,"PED","WALK_DRUNK",4.1,1,1,1,1,1);
	return 1;
}

CMD:play(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/play [1-3]");
    if(!strcmp(params, "1", true))
    {
        ApplyPlayerAnimation(playerid, "CRIB", "PED_CONSOLE_LOOP", 4.0, 1, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
        ApplyPlayerAnimation(playerid, "CRIB", "PED_CONSOLE_WIN", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "3", true))
    {
        ApplyPlayerAnimation(playerid, "CRIB", "PED_CONSOLE_LOOSE", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:pee(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/pee [1-2]");
    if(!strcmp(params, "1", true))
    {
        ApplyPlayerAnimation(playerid, "PAULNMAC", "PISS_IN", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
        SetPlayerSpecialAction(playerid, 68);
    }
    return 1;
}

CMD:wank(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/wank [1-2]");
    if(!strcmp(params, "1", true))
    {
        ApplyPlayerAnimation(playerid, "PAULNMAC", "WANK_IN", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
        ApplyPlayerAnimation(playerid, "PAULNMAC", "WANK_LOOP", 4.0, 1, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:sit(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/sit [1-3]");
    if(!strcmp(params, "1", true))
    {
		ApplyPlayerAnimation(playerid, "MISC", "SEAT_LR", 4.0, 1, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
		ApplyPlayerAnimation(playerid, "MISC", "SEAT_TALK_01", 4.0, 1, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "3", true))
    {
		ApplyPlayerAnimation(playerid, "BEACH", "PARKSIT_M_LOOP", 4.0, 1, 0, 0, 0, 0, 1);
    }
	return 1;
}

CMD:bball(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/bball [1-6]");
    if(!strcmp(params, "1", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_JUMP_SHOT", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_DEF_LOOP", 4.0, 1, 1, 0, 1, 0, 1);
    }
    else if(!strcmp(params, "3", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_PICKUP", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "4", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_DNK", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "5", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_IDLE", 4.0, 1, 0, 0, 1, 0, 1);
    }
    else if(!strcmp(params, "6", true))
    {
		ApplyPlayerAnimation(playerid, "BSKTBALL", "BBALL_IDLE2", 4.0, 1, 0, 0, 1, 0, 1);
    }
	return 1;
}

CMD:scratch(playerid, params[])
{
    ApplyPlayerAnimation(playerid, "MISC", "Scratchballs_01", 4.0, 1, 0, 0, 0, 0, 1);
    return 1;
}

CMD:reload(playerid, params[])
{
    ApplyPlayerAnimation(playerid, "COLT45", "COLT45_RELOAD", 4.0, 0, 0, 0, 0, 0, 1);
    return 1;
}

CMD:injured(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.0, 1, 0, 0, 0, 0, 1);
	return 1;
}

CMD:gsign(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/gsign [1-8]");
    if(!strcmp(params, "1", true))
    {
    	ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN1", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
    	ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN2", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "3", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN3", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "4", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN4", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "5", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN5", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "6", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN1LH", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "7", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN2LH", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "8", true))
    {
        ApplyPlayerAnimation(playerid, "GHANDS", "GSIGN5LH", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:chill(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/chill [1-2]");
    if(!strcmp(params, "1", true))
    {
    	ApplyPlayerAnimation(playerid, "RAPPING", "RAP_A_Loop", 4.1, 1, 1, 1, 1, 1, 1);
    }
    else if(!strcmp(params, "2", true))
    {
        ApplyPlayerAnimation(playerid, "RAPPING", "RAP_B_Loop", 4.1, 1, 1, 1, 1, 1, 1);
    }
    return 1;
}

CMD:tag(playerid, params[])
{
    if(sscanf(params, "d", params)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/tag [1-3]");
    if(!strcmp(params, "1", true))
    {
        ApplyPlayerAnimation(playerid, "GRAFFITI", "GRAFFITI_CHKOUT", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "2", true))
    {
        ApplyPlayerAnimation(playerid, "GRAFFITI", "SPRAYCAN_FIRE", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(params, "3", true))
    {
        ApplyPlayerAnimation(playerid, "SPRAYCAN", "SPRAYCAN_FULL", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:camera(playerid, params[])
{
    new
	give[5];

    if(sscanf(params, "s[5]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/camera [1-3]");
    if(!strcmp(give, "1", true))
    {
        ApplyPlayerAnimation(playerid, "CAMERA", "camcrch_cmon", 4.1, 0, 1, 1, 1, 1, 1);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid, "CAMERA", "camstnd_to_camcrch", 4.1, 0, 1, 1, 1, 1, 1);
    }
    else if(!strcmp(give, "3", true))
    {
        ApplyPlayerAnimation(playerid, "CAMERA", "PICCRCH_TAKE", 4.0, 1, 0, 0, 0, 0);
    }
    return 1;
}

CMD:rap(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"RAPPING","RAP_A_Loop",4.0,1,0,0,0,0,1);
	return 1;
}

CMD:think(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "COP_AMBIENT", "Coplook_think", 4.1, 0, 1, 1, 1, 1, 1);
	return 1;
}

CMD:box(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"GYMNASIUM","GYMshadowbox",4.0,1,1,1,1,0,1);
	return 1;
}

CMD:tired(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PED","IDLE_tired",3.0,1,0,0,0,0,1);
	return 1;
}

CMD:bar(playerid, params[])
{
    new
	give[3];

    if(sscanf(params, "s[3]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/bar [1-2]");
    if(!strcmp(give, "1", true))
    {
		ApplyPlayerAnimation(playerid, "BAR", "Barserve_bottle", 2.0, 0, 0, 0, 0, 0,1);
    }
	else if(!strcmp(give, "2", true))
    {
		ApplyPlayerAnimation(playerid, "BAR", "Barserve_give", 2.0, 0, 0, 0, 0, 0,1);
    }
	return 1;
}

CMD:bat(playerid, params[])
{
    new
	give[4];

    if(sscanf(params, "s[4]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/bat [1-3]");
    if(!strcmp(give, "1", true))
    {
		ApplyPlayerAnimation(playerid, "BASEBALL", "Bat_IDLE", 2.0, 0, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "2", true))
    {
		ApplyPlayerAnimation(playerid, "CRACK", "Bbalbat_Idle_01", 2.0, 0, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "3", true))
    {
		ApplyPlayerAnimation(playerid, "CRACK", "Bbalbat_Idle_02", 2.0, 0, 0, 0, 0, 0,1);
    }
	return 1;
}

CMD:lean(playerid, params[])
{
	new
	give[7];

    if(sscanf(params, "s[7]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/lean [1-2]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid,"GANGS","leanIDLE",4.0,0,1,1,1,0,1);
    }
    if(!strcmp(give, "2", true))
    {
   		ApplyPlayerAnimation(playerid,"MISC","Plyrlean_loop",4.1,1,0,0,0,0);
    }
	return 1;
}

CMD:dance(playerid, params[])
{
    new
	give[7];

    if(sscanf(params, "s[7]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/dance [1-5]");
    if(!strcmp(give, "1", true))
    {
   		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_DANCE1);
    }
    if(!strcmp(give, "2", true))
    {
   		ApplyPlayerAnimation(playerid, "DANCING", "DNCE_M_A", 4.0, 1, 0, 0, 0, 0, 1);
    }
    if(!strcmp(give, "3", true))
    {
   		ApplyPlayerAnimation(playerid, "DANCING", "DNCE_M_B", 4.0, 1, 0, 0, 0, 0, 1);
    }
    if(!strcmp(give, "4", true))
    {
   		ApplyPlayerAnimation(playerid, "DANCING", "DNCE_M_D", 4.0, 1, 0, 0, 0, 0, 1);
    }
    if(!strcmp(give, "5", true))
    {
   		ApplyPlayerAnimation(playerid, "DANCING", "DNCE_M_E", 4.0, 1, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:searchfiles(playerid, params[])
{
    new
	give[7];

    if(sscanf(params, "s[7]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/searchfiles [1-3]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid, "COP_AMBIENT", "COPBROWSE_IN", 4.0, 0, 1, 0, 1, 0, 1);
    }
    if(!strcmp(give, "2", true))
    {
   		ApplyPlayerAnimation(playerid, "COP_AMBIENT", "COPBROWSE_NOD", 4.0, 0, 1, 0, 1, 0, 1);
    }
    if(!strcmp(give, "3", true))
    {
   		ApplyPlayerAnimation(playerid, "COP_AMBIENT", "COPBROWSE_OUT", 4.0, 0, 1, 0, 0, 0, 1);
    }
    return 1;
}

CMD:kiss(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "BD_Fire", "grlfrd_kiss_03", 2.0, 0, 0, 0, 0, 0,1);
	return 1;
}

CMD:cpr(playerid, params[])
{
    ApplyPlayerAnimation(playerid, "MEDIC", "CPR", 4.0, 0, 0, 0, 0, 0, 1);
    return 1;
}

CMD:handsup(playerid, params[])
{
	SetPlayerSpecialAction(playerid,SPECIAL_ACTION_HANDSUP);
	return 1;
}

CMD:bomb(playerid, params[])
{
	ClearAnimations(playerid);
	ApplyPlayerAnimation(playerid, "BOMBER", "BOM_Plant", 4.0, 0, 0, 0, 0, 0,1); // Place Bomb
	return 1;
}

CMD:getarrested(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"ped", "ARRESTgun", 4.0, 0, 1, 1, 1, -1,1); // Gun Arrest
	return 1;
}

CMD:laugh(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "RAPPING", "Laugh_01", 4.0, 0, 0, 0, 0, 0,1); // Laugh
	return 1;
}

CMD:lookout(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "SHOP", "ROB_Shifty", 4.0, 0, 0, 0, 0, 0,1); // Rob Lookout
	return 1;
}

CMD:aim(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "SHOP", "ROB_Loop_Threat", 4.0, 1, 0, 0, 0, 0,1); // Rob
	return 1;
}

CMD:crossarms(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "COP_AMBIENT", "Coplook_loop", 4.0, 1, 0, 1, 1, -1,1); // Arms crossed
	return 1;
}

CMD:car(playerid, params[])
{
    new
	give[4];

    if(sscanf(params, "s[4]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/car [1-3]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid,"CAR","Fixn_Car_Loop", 4.0, 1, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid, "CAR", "Fixn_Car_Out", 4.1, 1, 1, 1, 1, 1, 1);
    }
    else if(!strcmp(give, "3", true))
    {
        ApplyPlayerAnimation(playerid, "CAR", "flag_drop", 4.1, 1, 1, 1, 1, 1, 1);
    }
    return 1;
}

CMD:lay(playerid, params[])
{
    new
	give[4];

    if(sscanf(params, "s[4]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/lay [1-4]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid,"BEACH","bather", 4.0, 1, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid,"BEACH","SitnWait_loop_W", 4.0, 1, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "3", true))
    {
        ApplyPlayerAnimation(playerid,"CRACK","crckidle4", 4.0, 1, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "4", true))
    {
        ApplyPlayerAnimation(playerid,"BEACH","PARKSIT_W_LOOP", 4.0, 1, 0, 0, 0, 0,1);
    }
    return 1;
}

CMD:what(playerid, params[])
{
    new
	give[3];

    if(sscanf(params, "s[3]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/what [1-2]");
    if(!strcmp(give, "1", true))
    {
        ApplyPlayerAnimation(playerid,"RIOT","RIOT_ANGRY", 4.0, 0, 0, 0, 0, 0, 0);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid,"benchpress","gym_bp_celebrate", 4.0, 0, 0, 0, 0, 0, 0);
    }
    return 1;
}

CMD:hide(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "ped", "cower", 3.0, 1, 0, 0, 0, 0,1);
	return 1;
}

CMD:vomit(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "FOOD", "EAT_Vomit_P", 3.0, 0, 0, 0, 0, 0,1); // Vomit BAH!
	return 1;
}

CMD:eat(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "FOOD", "EAT_PIZZA", 4.0, 0, 0, 0, 0, 0, 1);
	return 1;
}

CMD:wave(playerid, params[])
{
    new
	give[3];

    if(sscanf(params, "s[3]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/wave [1-3]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid, "ON_LOOKERS", "wave_loop", 4.0, 1, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid, "KISSING", "GFWAVE2", 4.0, 0, 0, 0, 0, 0, 1);
    }
    else if(!strcmp(give, "3", true))
    {
        ApplyPlayerAnimation(playerid, "KISSING", "BD_GF_WAVE", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:strip(playerid, params[])
{
    new
	give[3];

    if(sscanf(params, "s[4]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/strip [1-4]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid, "STRIP", "STRIP_A", 4.0, 1, 0, 0, 0, 0);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid, "STRIP", "STR_LOOP_A", 4.0, 1, 0, 0, 0, 0);
    }
    else if(!strcmp(give, "3", true))
    {
        ApplyPlayerAnimation(playerid, "STRIP", "STR_LOOP_B", 4.0, 1, 0, 0, 0, 0);
    }
    else if(!strcmp(give, "4", true))
    {
        ApplyPlayerAnimation(playerid, "STRIP", "STR_LOOP_C", 4.0, 1, 0, 0, 0, 0);
    }
    return 1;
}

CMD:chant(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"RIOT","RIOT_CHANT",4.0,1,1,1,1,0,1);
	return 1;
}

CMD:slapass(playerid, params[])
{
    new
	give[3];

    if(sscanf(params, "s[3]", give)) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/slap [1-2]");
    if(!strcmp(give, "1", true))
    {
   		ApplyPlayerAnimation(playerid, "SWEET", "sweet_ass_slap", 4.0, 0, 0, 0, 0, 0,1);
    }
    else if(!strcmp(give, "2", true))
    {
        ApplyPlayerAnimation(playerid, "FLOWERS", "FLOWER_ATTACK_M", 4.0, 0, 0, 0, 0, 0, 1);
    }
    return 1;
}

CMD:deal(playerid, params[])
{
	ApplyPlayerAnimation(playerid, "DEALER", "DEALER_DEAL", 4.0, 0, 0, 0, 0, 0,1); // Deal Drugs
 	return 1;
}

CMD:fucku(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PED","fucku",4.0,0,0,0,0,0,1);
	return 1;
}

CMD:taichi(playerid, params[])
{
	ApplyPlayerAnimation(playerid,"PARK","Tai_Chi_Loop",4.0,0,0,0,0,0,1);
	return 1;
}

alias:clearanimations("clearanim", "clearanims", "ca", "stopanim", "stopanimations", "stopanims", "sa");
CMD:clearanimations(playerid, params[])
{
    if(IsPlayerInAnyVehicle(playerid))
    {
        ApplyPlayerAnimation(playerid, "CAR_CHAT", "CAR_Sc1_FR", 4.1, 0, 0, 0, 1, 1, 1);
	}
	else
	{
	    ClearAnimations(playerid);
	    //if(PlayerInfo[playerid][pHandcuffed])
	    	//return 1;
		SetPlayerSpecialAction(playerid,SPECIAL_ACTION_NONE);
	}
	return 1;
}

alias:animations("anims");
CMD:animations(playerid, params[])
{
    SendClientMessage(playerid, COLOR_GREEN, "_______[VICE CITY EMERGENCY RESPONDERS ANIMATIONS]_______");
    SendClientMessage(playerid, COLOR_GREY, "/crack, /chat, /hike, /caract, /give, /liftup, /putdown, /cry, /mourn, /endchat");
    SendClientMessage(playerid, COLOR_GREY, "/show, /shoutanim, /look, /drunk, /play, /pee, /wank, /sit, /bball, /scratch");
    SendClientMessage(playerid, COLOR_GREY, "/reload, /injured, /gsign, /chill, /tag, /camera, /rap, /think, /box, /tired");
    SendClientMessage(playerid, COLOR_GREY, "/bar, /bat, /lean, /dance, /searchfiles, /kiss, /handsup, /bomb, /getarrested");
    SendClientMessage(playerid, COLOR_GREY, "/laugh, /lookout, /aim, /crossarms, /car, /lay, /what, /hide, /vomit, /eat, /wave, /strip");
    SendClientMessage(playerid, COLOR_GREY, "/chant, /slapass, /deal, /fucku, /taichi. /clearanimations > (clearanim, stopanim, ca, sa)");
    return 1;
}