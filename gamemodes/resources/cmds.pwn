//

CMD:startgame(playerid, params[]) {
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have sufficient permissions for this command.");

	if (gm_State == Waiting || gm_State == Lobby) {
		new count;
		foreach(new i : Player) {
			if(eUser[i][e_USER_LOBBY] == Main) count++;
		}

		if (count < PLAYERS_TO_START) 
			return SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}%d more %s required before the game can start!", PLAYERS_TO_START-count, (PLAYERS_TO_START-count == 1) ? ("player is") : ("players are"));
		
		StartGame();
		printf("[debug] /startgame used by %d.", playerid);
	}
	return 1;
}

CMD:forcestartgame(playerid, params[]) {
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 4)
		return 1;
	
	StartGame();
	printf("[debug] /forcestartgame used by %d.", playerid);
	return 1;
}

CMD:endgame(playerid, params[]) {
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have sufficient permissions for this command.");

	if (gm_State != InProgress)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: There is no game in progress.");

	EndGame();
	KillTimer(g_Timers[2]);

	SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}An admin has ended the game.");

	printf("[debug] admin ended game.");

	return 1;
}

CMD:stats(playerid, params[]) {
	if (eUser[playerid][e_USER_ADMIN_LEVEL] > 0)
		SendClientMessage(playerid, COLOR_GREY, "TIP: You can double click someone's name to view their stats aswell!");

	ShowStatsForPlayer(playerid, playerid);
	return 1;
}

alias:toggle("tog");
CMD:toggle(playerid, params[]) {

	new admin_level = eUser[playerid][e_USER_ADMIN_LEVEL];
	
	if (sscanf(params, "s[5]", params)) {
		SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/(tog)gle [tog]");
		
		switch (admin_level) {
			case 0: SendClientMessage(playerid, COLOR_YELLOW, "TOGGLES: pm, b, lo");
			default: SendClientMessage(playerid, COLOR_YELLOW, "TOGGLES: pm, b, lo, sc, o");
		}
		
		if (eUser[playerid][e_USER_VIP_LEVEL] >= 1) SendClientMessage(playerid, COLOR_YELLOW, "TOGGLES: donator");
		return 1;
	}
	
	if (!strcmp(params, "sc", true)) {
		if (admin_level < 1)
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /staffchat %s.", (eToggle[playerid][e_SC] == 1 ? ("on") : ("off")));
		eToggle[playerid][e_SC] = (eToggle[playerid][e_SC] == 1 ? 0 : 1);
	}
	else if (!strcmp(params, "donator", true)) {
		if (eUser[playerid][e_USER_VIP_LEVEL] < 1)
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /donatorchat %s.", (eToggle[playerid][e_DC] == 1 ? ("on") : ("off")));
		eToggle[playerid][e_DC] = (eToggle[playerid][e_DC] == 1 ? 0 : 1);
	}
	else if (!strcmp(params, "pm", true)) {
		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /pm %s.", (eToggle[playerid][e_PM] == 1 ? ("on") : ("off")));
		eToggle[playerid][e_PM] = (eToggle[playerid][e_PM] == 1 ? 0 : 1);
	}
	else if (!strcmp(params, "b", true)) {
		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /b %s.", (eToggle[playerid][e_B] == 1 ? ("on") : ("off")));
		eToggle[playerid][e_B] = (eToggle[playerid][e_B] == 1 ? 0 : 1);
	}
	else if (!strcmp(params, "o", true)) {
		if (admin_level < 1)
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /ooc %s for everyone.", (togglobal == 1 ? ("on") : ("off")));
		SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has disabled the Global OOC chat.", GetPlayerAdminRank(playerid));

		togglobal = (togglobal == 1 ? 0 : 1);
	}
	else if (!strcmp(params, "lo", true))
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled /o %s for yourself.", (eToggle[playerid][e_Global] == 1 ? ("on") : ("off")));
		eToggle[playerid][e_Global] = (eToggle[playerid][e_Global] == 1 ? 0 : 1);
	}
	return 1;
}

alias:staffchat("sc", "a");
CMD:staffchat(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be an administrator to use this command.");

	if (eToggle[playerid][e_SC])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Enable /sc first!");

	if (sscanf(params, "s[144]", params))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/(s)taff(c)hat [chat]");

	new string[144];

	format(string, sizeof string, "[Staff Chat] %s %s: %s", GetPlayerAdminRank(playerid), GetPlayerNameEx(playerid), params);
	SendAdminMessage(COLOR_TOMATO, string);
	return 1;
}

CMD:makeadmin(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, level;
	if (sscanf(params, "ud", targetid, level))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/makeadmin [playerid/partOfName] [level]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	if (level < 0 || level > 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: The valid ranges for this command are 0 and 4.");

	if (level > eUser[playerid][e_USER_ADMIN_LEVEL] && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You cannot set a admin rank higher than yours!");

	eUser[targetid][e_USER_ADMIN_LEVEL] = level;

	new string[144];

	mysql_format(g_SQL, string, sizeof string, "UPDATE "#TABLE_USERS" SET `adminlevel` = %d WHERE `id` = %d", level, eUser[targetid][e_USER_SQLID]);
	mysql_pquery(g_SQL, string);

	format(string, sizeof string, "AdmNotice: You have been assigned admin level %d by %s.", level, GetPlayerNameEx(playerid));
	SendClientMessage(targetid, COLOR_TOMATO, string);

	format(string, sizeof string, "AdmNotice: You have assigned %s (%d) admin level %d.", GetPlayerNameEx(targetid), targetid, level);
	SendClientMessage(playerid, COLOR_TOMATO, string);

	return 1;
}

alias:privatemessage("pm");
CMD:privatemessage(playerid, params[])
{
	new targetid, text[128];
	if (sscanf(params, "us[128]", targetid, text))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/pm [playerid/partOfName] [message]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	if (eToggle[playerid][e_PM])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Enable /pm first!");

	if (eToggle[targetid][e_PM])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: That player has /pm toggled.");

	SendClientMessageEx(playerid, COLOR_YELLOW, "[PM to %s (%d): %s]", GetPlayerNameEx(targetid), targetid, text);
	SendClientMessageEx(targetid, COLOR_YELLOW, "[PM from %s (%d): %s]", GetPlayerNameEx(playerid), playerid, text);

	PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0);
	PlayerPlaySound(targetid, 1085, 0.0, 0.0, 0.0);

	Log_Write("logs/chat/pm_log.txt", "[%s %s] [%s > %s] %s",
		GetDateEx(),
		GetTimeEx(),
		GetPlayerNameEx(playerid),
		GetPlayerNameEx(targetid),
		text
	);

	return 1;
}

CMD:b(playerid, params[])
{
	if (sscanf(params, "s[144]", params))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/b [text]");

	if (eToggle[playerid][e_B])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Enable /b first!");

	new string[144];

	format(string, sizeof string, "(( %s (%d): %s ))", GetPlayerNameEx(playerid), playerid, params);
	SendBMessage(playerid, COLOR_GREY, string);

	Log_Write("logs/chat/b_log.txt", "[%s %s] [%s] %s",
		GetDateEx(),
		GetTimeEx(),
		GetPlayerNameEx(playerid),
		string
	);

	return 1;
}

CMD:me(playerid, params[]) {
	new length = strlen(params);
	
	if (length < 1) return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/me [action]");
	if (length > 100) {
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %s %.100s", GetPlayerNameEx(playerid), params);
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* ... %s", params[100]);
	}
	else {
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %s %s", GetPlayerNameEx(playerid), params);
	}
	return 1;
}

CMD:do(playerid, params[])
{
	if (strlen(params) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/do [action]");

	if (strlen(params) > 100)
	{
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %.100s", params);
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* ... %s (( %s ))", params[100], GetPlayerNameEx(playerid));
	}
	else SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %s (( %s ))", params, GetPlayerNameEx(playerid));

	return 1;
}

CMD:my(playerid, params[])
{
	if (strlen(params) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/my [action]");

	if (strlen(params) > 100)
	{
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %s %.100s", GetPlayerNamePoss(playerid), params);
		SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* ... %s", params[100]);
	}
	else SendNearbyMessage(playerid, 15.0, COLOR_PINK, "* %s %s", GetPlayerNamePoss(playerid), params);
	return 1;
}

CMD:ame(playerid, params[])
{
	if (strlen(params) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/ame [action]");

	new string[144];

	format(string, sizeof string, "* %s %s", GetPlayerNameEx(playerid), params);
	SetPlayerChatBubbleEx(playerid, COLOR_PINK, string);

	if (strlen(params) > 100)
	{
		SendClientMessageEx(playerid, COLOR_PINK, "> %s %.100s", GetPlayerNameEx(playerid), params);
		SendClientMessageEx(playerid, COLOR_PINK, "> ... %s", params[100]);
	}
	else SendClientMessageEx(playerid, COLOR_PINK, "> %s %s", GetPlayerNameEx(playerid), params);

	return 1;
}

CMD:amy(playerid, params[])
{
	if (strlen(params) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/amy [action]");

	new string[144];

	format(string, sizeof string, "* %s's %s", GetPlayerNameEx(playerid), params);
	SetPlayerChatBubbleEx(playerid, COLOR_PINK, string);

	if (strlen(params) > 100)
	{
		SendClientMessageEx(playerid, COLOR_PINK, "> %s's %.100s", GetPlayerNameEx(playerid), params);
		SendClientMessageEx(playerid, COLOR_PINK, "> ... %s", params[100]);
	}
	else SendClientMessageEx(playerid, COLOR_PINK, "> %s's %s", GetPlayerNameEx(playerid), params);

	return 1;
}

CMD:ado(playerid, params[])
{
	if (strlen(params) < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/ado [action]");

	new string[144];

	format(string, sizeof string, "* %s (( %s ))", params, GetPlayerNameEx(playerid));
	SetPlayerChatBubbleEx(playerid, COLOR_PINK, string);

	if (strlen(params) > 100)
	{
		SendClientMessageEx(playerid, COLOR_PINK, "> %.100s (( %s ))", params, GetPlayerNameEx(playerid));
		SendClientMessageEx(playerid, COLOR_PINK, "> ... %s (( %s ))", params[100], GetPlayerNameEx(playerid));
	}
	else SendClientMessageEx(playerid, COLOR_PURPLE, "> %s (( %s ))", params, GetPlayerNameEx(playerid));

	return 1;
}

alias:help("cmds", "commands", "helpme");
CMD:help(playerid, params[])
{
	SendClientMessage(playerid, COLOR_WHITE, "_______[VICE CITY EMERGENCY RESPONDERS HELP]_______");
	SendClientMessage(playerid, COLOR_GREY, "GENERAL: {FFFFFF}/stats /toggle /afk /switch /anims");
	SendClientMessage(playerid, COLOR_GREY, "RP: {FFFFFF}/me /do /my /ame /amy /ado");
	SendClientMessage(playerid, COLOR_GREY, "CHAT: {FFFFFF}/pm /b /o(oc) /clearchat");
	SendClientMessage(playerid, COLOR_GREY, "GM: {FFFFFF}/createstrip /removestrip");
	if (eUser[playerid][e_USER_VIP_LEVEL] > 0) SendClientMessage(playerid, COLOR_DONATOR, "DONATOR: {FFFFFF}/(d)onator(c)hat");

	new admin_level = eUser[playerid][e_USER_ADMIN_LEVEL];
	if (admin_level >= 1) {
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/aduty /(s)taff(c)hat /kick /freeze /unfreeze /slap /removeallstrips");
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/goto /gotovc /gethere /disarm /startgame");
	}
	
	if (admin_level >= 2) {
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/spawncar /disarmall /clearchatall /giveweapon /sethealth /setarmour");
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/endgame /sban /ban");
	}
	
	if (admin_level >= 3) {
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/makeadmin /giveweapon /sethealth /setarmour /makedonator");
		SendClientMessage(playerid, COLOR_ORANGE, "DEVELOPER: {FFFFFF}/restart");
	}

	if(admin_level >= 4) {
		SendClientMessage(playerid, COLOR_TOMATO, "ADMIN: {FFFFFF}/donatorchat");
	}
	return 1;
}

alias:giveweapon("givewep", "givegun");
CMD:giveweapon(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, weaponid, ammo;
	if (sscanf(params, "udD(100)", targetid, weaponid, ammo))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/giveweapon [playerid/partOfName] [weaponid] [ammo, default: 100]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	if (weaponid <= 0 || weaponid > 46 || (weaponid >= 19 && weaponid <= 21))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You provided an invalid weapon ID!");

	new string[144];

	GivePlayerWeapon(targetid, weaponid, ammo);

	format(string, sizeof string, "AdmNotice: You have been given a %s with %i ammo by %s.", GetWeaponNameEx(weaponid), ammo, GetPlayerNameEx(playerid));
	SendClientMessage(targetid, COLOR_TOMATO, string);

	format(string, sizeof string, "AdmNotice: You have given a %s with %i ammo to %s.", GetWeaponNameEx(weaponid), ammo, GetPlayerNameEx(targetid));
	SendClientMessage(playerid, COLOR_TOMATO, string);
	return 1;
}

alias:sethealth("sethp");
CMD:sethealth(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, Float:health;
	if (sscanf(params, "uf", targetid, health))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/sethealth [playerid/partOfName] [health]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new string[144];

	SetPlayerHealth(targetid, health);

	format(string, sizeof string, "AdmNotice: %s has set your health to %.2f.", GetPlayerNameEx(playerid), health);
	SendClientMessage(targetid, COLOR_TOMATO, string);

	format(string, sizeof string, "AdmNotice: You have set %s health to %.2f.", GetPlayerNamePoss(targetid), health);
	SendClientMessage(playerid, COLOR_TOMATO, string);
	return 1;
}

CMD:setarmour(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, Float:armour;
	if (sscanf(params, "uf", targetid, armour))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/setarmour [playerid/partOfName] [armour]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new string[144];

	SetPlayerArmour(targetid, armour);

	format(string, sizeof string, "AdmNotice: %s has set your armour to %.2f.", GetPlayerNameEx(playerid), armour);
	SendClientMessage(targetid, COLOR_TOMATO, string);

	format(string, sizeof string, "AdmNotice: You have set %s armour to %.2f.", GetPlayerNamePoss(targetid), armour);
	SendClientMessage(playerid, COLOR_TOMATO, string);
	return 1;
}

CMD:kick(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, reason[64];
	if (sscanf(params, "us[64]", targetid, reason))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/kick [playerid/partOfName] [reason]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has been kicked by %s, reason: %s", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid), reason);
	Kick(targetid);
	return 1;
}

CMD:restart(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new time;
	if (sscanf(params, "d", time))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/restart [time in seconds]");

	if (time < 10)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: The minimum time for a restart is 10 seconds!");

	SendClientMessageToAllEx(COLOR_TOMATO, "DevCmd: %s has issued a server restart in %d seconds, accounts will save in %d seconds.", GetPlayerNameEx(playerid), time, time-5);
	SetTimer("restartsave", (time*1000)-5000, false);
	return 1;
}

CMD:freeze(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/freeze [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	TogglePlayerControllable(targetid, false);

	SendClientMessage(targetid, COLOR_TOMATO, "AdmNotice: You were frozen by an administrator.");
	SendClientMessageEx(playerid, COLOR_TOMATO, "AdmNotice: You have frozen %s.", GetPlayerNameEx(targetid));

	return 1;
}

CMD:unfreeze(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/unfreeze [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	TogglePlayerControllable(targetid, true);

	SendClientMessage(targetid, COLOR_TOMATO, "AdmNotice: You were unfrozen by an administrator.");
	SendClientMessageEx(playerid, COLOR_TOMATO, "AdmNotice: You have unfrozen %s.", GetPlayerNameEx(targetid));

	return 1;
}

CMD:goto(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/goto [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(playerid, x, y, z);

	SetPlayerInterior(playerid, GetPlayerInterior(targetid));
	SetPlayerVirtualWorld(playerid, GetPlayerVirtualWorld(targetid));

	SendClientMessageEx(targetid, COLOR_TOMATO, "AdmNotice: %s has teleported to you.", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_TOMATO, "AdmNotice: You have teleported to %s.", GetPlayerNameEx(targetid));

	return 1;
}

/*CMD:gotovc(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	SetPlayerPos(playerid, 5232.4399, -2228.6245, 11.5385);
	SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have teleported to Vice City.", GetPlayerNameEx(targetid));
}*/

CMD:gethere(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/gethere [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(playerid, x, y, z);
	SetPlayerPos(targetid, x, y, z);

	SetPlayerInterior(targetid, GetPlayerInterior(playerid));
	SetPlayerVirtualWorld(targetid, GetPlayerVirtualWorld(playerid));

	SendClientMessageEx(targetid, COLOR_TOMATO, "AdmNotice: %s has teleported you to themself.", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_TOMATO, "AdmNotice: You have teleported %s to you.", GetPlayerNameEx(targetid));

	return 1;
}

CMD:slap(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "u", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/slap [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new Float:x, Float:y, Float:z;

	GetPlayerPos(targetid, x, y, z);
	SetPlayerPos(targetid, x, y, z+5);

	SendClientMessageEx(targetid, COLOR_TOMATO, "AdmNotice: You were slapped by %s.", GetPlayerNameEx(playerid));
	SendClientMessageEx(playerid, COLOR_TOMATO, "AdmNotice: You have slapped %s.", GetPlayerNameEx(targetid));

	PlayerPlaySound(playerid, 1190, 0.0, 0.0, 0.0);
	PlayerPlaySound(targetid, 1190, 0.0, 0.0, 0.0);

	return 1;
}

alias:ooc("o");
CMD:ooc(playerid, params[])
{
	if (togglobal == 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Global chat was toggled by an administrator.");

	if (eToggle[playerid][e_Global])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Enable /ooc first.");

	if (sscanf(params, "s[128]", params))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/o(oc) [message]");

	new string[144];

	format(string, sizeof string, "(( [OOC] %s %s: %s ))", GetPlayerAdminRank(playerid), GetPlayerNameEx(playerid), params);
	SendOOCMessage(COLOR_WHITE, string);

	Log_Write("logs/chat/ooc_log.txt", "[%s %s] [%s] %s",
		GetDateEx(),
		GetTimeEx(),
		GetPlayerNameEx(playerid),
		string
	);

	//Log_Init(LOG_TYPE_CHAT, playerid, "[ooc] %s", params);

	return 1;
}

alias:makedonator("makedonor");
CMD:makedonator(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 2 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, level;
	if (sscanf(params, "ud", targetid, level))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/makedonator [playerid/partOfName] [level]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	if (level < 0 || level > 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: The valid ranges for this command are 0 and 2!");

	eUser[targetid][e_USER_VIP_LEVEL] = level;

	new string[144];

	mysql_format(g_SQL, string, sizeof string, "UPDATE "#TABLE_USERS" SET `viplevel` = %d WHERE `id` = %d", level, eUser[targetid][e_USER_SQLID]);
	mysql_pquery(g_SQL, string);

	format(string, sizeof string, "AdmNotice: You have been assigned donator level %s by %s %s.", GetPlayerDonatorRank(playerid), GetPlayerAdminRank(playerid), GetPlayerNameEx(playerid));
	SendClientMessage(targetid, COLOR_TOMATO, string);

	format(string, sizeof string, "AdmNotice: You have assigned %s (%d) %s donator.", GetPlayerNameEx(playerid), targetid, GetPlayerDonatorRank(playerid));
	SendClientMessage(playerid, COLOR_TOMATO, string);

	return 1;
}

alias:donatorchat("dc", "d");
CMD:donatorchat(playerid, params[])
{
	if (eUser[playerid][e_USER_VIP_LEVEL] <= 0 || eUser[playerid][e_USER_ADMIN_LEVEL] < 4)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be a donator or a level 4 administrator to use this command.");

	if (eToggle[playerid][e_DC])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Enable /donatorchat first!");

	if (sscanf(params, "s[144]", params))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/(d)onator(c)hat [chat]");

	new string[144];

	if (eUser[playerid][e_USER_ADMIN_LEVEL] == 4) format(string, sizeof string, "[Donator Chat] %s %s: %s", GetPlayerAdminRank(playerid), GetPlayerNameEx(playerid), params);
	else format(string, sizeof string, "[Donator Chat] %s %s: %s", GetPlayerDonatorRank(playerid), GetPlayerNameEx(playerid), params);

	SendDonatorMessage(COLOR_DONATOR, string);

	return 1;
}

CMD:toggold(playerid, params[])
{
	if (eUser[playerid][e_USER_VIP_LEVEL] <= 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be a donator to access this command.");

	SetPlayerColor(playerid, (eToggle[playerid][e_Gold] == 1 ? COLOR_WHITE : COLOR_DONATOR));

	eToggle[playerid][e_Gold] = (eToggle[playerid][e_Gold] == 1 ? 0 : 1);
	SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have toggled your gold tag %s.", (eToggle[playerid][e_Gold] == 1 ? ("on") : ("off")));
	return 1;
}

alias:afk("brb");
CMD:afk(playerid, params[])
{
	eUser[playerid][e_USER_AFK] = (eUser[playerid][e_USER_AFK] == true ? false : true);
	SendClientMessageToAllEx(COLOR_TOMATO, "[ ! ] {FFFFFF}%s is %s marked as AFK.", GetPlayerNameEx(playerid), (eUser[playerid][e_USER_AFK] == true ? ("now") : ("no longer")));

	if (eUser[playerid][e_USER_AFK] == true) Iter_Remove(gm_Players, playerid);
	else Iter_Add(gm_Players, playerid);
	return 1;
}

alias:aduty("adminduty", "admduty");
CMD:aduty(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1 && !IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	eUser[playerid][e_USER_ADUTY] = (eUser[playerid][e_USER_ADUTY] == true ? false : true);
	SendClientMessageToAllEx(COLOR_TOMATO, "ADMIN: {FFFFFF}%s is %s on admin duty.", GetPlayerNameEx(playerid), (eUser[playerid][e_USER_ADUTY] == true ? ("now") : ("no longer")));

	if (eUser[playerid][e_USER_ADUTY] == true) Iter_Remove(gm_Players, playerid);
	else Iter_Add(gm_Players, playerid);
	return 1;
}

CMD:gunrack(playerid, params[])
{
	return 1;
}

CMD:trunk(playerid, params[])
{
	new Float:vehPos[3], vehID = GetClosestVehicle(playerid);
	GetPosBehindVehicle(vehID, vehPos[0], vehPos[1], vehPos[2]);

	if (GetPlayerDistanceFromPoint(playerid, vehPos[0], vehPos[1], vehPos[2]) > 3.0)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}You're not near a trunk.");

	new slot, action[8], subparams[128];
	if (sscanf(params, "is[8]S()[128]", slot, action, subparams))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/trunk [slot id] [take/place]");

	if (slot < 1 && slot > 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}That slot doesn't exist. [valid: 1, 2]");

	if (!strcmp(action, "take"))
	{
		if (IsValidWeapon(gm_PlayerData[playerid][WeaponSling][WeaponID]))
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}You already have a weapon.");

		if ( ( slot == 1 && !IsValidWeapon(gm_VehicleData[vehID][Trunk1][WeaponID]) ) || ( slot == 2 && !IsValidWeapon(gm_VehicleData[vehID][Trunk2][WeaponID]) ) )
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}There is no weapon in that slot.");

		new empty_weapon[e_GM_WEAPONS];

		if (slot == 1)
		{
			GivePlayerWeapon(playerid, gm_VehicleData[vehID][Trunk1][WeaponID], gm_VehicleData[vehID][Trunk1][Ammo]);
			gm_PlayerData[playerid][WeaponSling][WeaponID] = gm_VehicleData[vehID][Trunk1][WeaponID];
			gm_PlayerData[playerid][WeaponSling][Ammo] = gm_VehicleData[vehID][Trunk1][Ammo];
			gm_PlayerData[playerid][WeaponSling][Specialty] = gm_VehicleData[vehID][Trunk1][Specialty];
			gm_VehicleData[vehID][Trunk1] = empty_weapon;
		}
		else if (slot == 2)
		{
			GivePlayerWeapon(playerid, gm_VehicleData[vehID][Trunk2][WeaponID], gm_VehicleData[vehID][Trunk2][Ammo]);
			gm_PlayerData[playerid][WeaponSling][WeaponID] = gm_VehicleData[vehID][Trunk2][WeaponID];
			gm_PlayerData[playerid][WeaponSling][Ammo] = gm_VehicleData[vehID][Trunk2][Ammo];
			gm_PlayerData[playerid][WeaponSling][Specialty] = gm_VehicleData[vehID][Trunk2][Specialty];
			gm_VehicleData[vehID][Trunk2] = empty_weapon;
		}
	}
	else if (!strcmp(action, "place"))
	{
		new wepid;
		if (sscanf(subparams, "i", wepid))
			return SendClientMessageEx(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/trunk %i place [weapon id]", slot);

		if ( ( slot == 1 && IsValidWeapon(gm_VehicleData[vehID][Trunk1][WeaponID]) ) || ( slot == 2 && IsValidWeapon(gm_VehicleData[vehID][Trunk2][WeaponID]) ) )
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}There is already a weapon in that slot.");

		if (gm_PlayerData[playerid][WeaponSling][WeaponID] != wepid)
			return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}You don't have that weapon.");

		new empty_weapon[e_GM_WEAPONS];

		SetPlayerAmmo(playerid, wepid, 0);

		if (slot == 1)
		{
			gm_VehicleData[vehID][Trunk1][WeaponID] = gm_PlayerData[playerid][WeaponSling][WeaponID];
			gm_VehicleData[vehID][Trunk1][Ammo] = gm_PlayerData[playerid][WeaponSling][Ammo];
			gm_VehicleData[vehID][Trunk1][Specialty] = gm_PlayerData[playerid][WeaponSling][Specialty];
			gm_PlayerData[playerid][WeaponSling] = empty_weapon;
		}
		else if (slot == 2)
		{
			gm_VehicleData[vehID][Trunk2][WeaponID] = gm_PlayerData[playerid][WeaponSling][WeaponID];
			gm_VehicleData[vehID][Trunk2][Ammo] = gm_PlayerData[playerid][WeaponSling][Ammo];
			gm_VehicleData[vehID][Trunk2][Specialty] = gm_PlayerData[playerid][WeaponSling][Specialty];
			gm_PlayerData[playerid][WeaponSling] = empty_weapon;
		}
	}
	return 1;
}

CMD:weapons(playerid, params[])
{
	new vehID = GetPlayerVehicleID(playerid);

	SendClientMessage(playerid, COLOR_TOMATO, "___Player Weapons___");

	if (IsValidWeapon(gm_PlayerData[playerid][WeaponHolster][WeaponID]))
		SendClientMessageEx(playerid, COLOR_DEFAULT, "Holster: %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_PlayerData[playerid][WeaponHolster][WeaponID]), gm_PlayerData[playerid][WeaponHolster][Ammo], gm_PlayerData[playerid][WeaponHolster][WeaponID]);

	if (IsValidWeapon(gm_PlayerData[playerid][WeaponSling][WeaponID]))
		SendClientMessageEx(playerid, COLOR_DEFAULT, "Sling: %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_PlayerData[playerid][WeaponSling][WeaponID]), gm_PlayerData[playerid][WeaponSling][Ammo], gm_PlayerData[playerid][WeaponSling][WeaponID]);

	if (IsValidVehicle(vehID) && gm_VehicleData[vehID][InGame])
	{
		SendClientMessage(playerid, COLOR_TOMATO, "___Vehicle Weapons___");

		if (IsValidWeapon(gm_VehicleData[vehID][GunRack1][WeaponID]))
			SendClientMessageEx(playerid, COLOR_DEFAULT, "Gunrack (1): %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_VehicleData[vehID][GunRack1][WeaponID]), gm_VehicleData[vehID][GunRack1][Ammo], gm_VehicleData[vehID][GunRack1][WeaponID]);

		if (IsValidWeapon(gm_VehicleData[vehID][GunRack2][WeaponID]))
			SendClientMessageEx(playerid, COLOR_DEFAULT, "Gunrack (2): %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_VehicleData[vehID][GunRack2][WeaponID]), gm_VehicleData[vehID][GunRack2][Ammo], gm_VehicleData[vehID][GunRack2][WeaponID]);

		if (IsValidWeapon(gm_VehicleData[vehID][Trunk1][WeaponID]))
			SendClientMessageEx(playerid, COLOR_DEFAULT, "Trunk (1): %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_VehicleData[vehID][Trunk1][WeaponID]), gm_VehicleData[vehID][Trunk1][Ammo], gm_VehicleData[vehID][Trunk1][WeaponID]);

		if (IsValidWeapon(gm_VehicleData[vehID][Trunk2][WeaponID]))
			SendClientMessageEx(playerid, COLOR_DEFAULT, "Trunk (2): %s with %i ammo [ID: %i]", GetWeaponNameEx(gm_VehicleData[vehID][Trunk2][WeaponID]), gm_VehicleData[vehID][Trunk2][Ammo], gm_VehicleData[vehID][Trunk2][WeaponID]);
	}
	return 1;
}

CMD:createstrip(playerid, params[])
{
	if (!Iter_Contains(gm_Responders, playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be a Responder to use this command!");

	if (IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You cannot be in a vehicle and lay down spike strips!");

	new Float:sX, Float:sY, Float:sZ, Float:sA;
	GetPlayerPos(playerid, sX, sY, sZ);
	GetPlayerFacingAngle(playerid, sA);

	if (CreateSpikeStrip(playerid, sX, sY, sZ, sA) == -1) return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: The spikestrip couldn't be created.");
	SendClientMessage(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have created a spike strip.");

	return 1;
}

CMD:removestrip(playerid, params[])
{
	if (!Iter_Contains(gm_Responders, playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be a Responder to use this command!");

	if (DeleteClosestSpikeStrip(playerid) == -1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You're not near any spikestrip.");

	return 1;
}

CMD:removeallstrips(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] <= 0)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be an administrator to use this command.");

	DeleteAllSpikeStrips();
	SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has deleted all spike strips.", GetPlayerNameEx(playerid));

	return 1;
}

CMD:engine(playerid, params[])
{
	new vehicleid = GetPlayerVehicleID(playerid), vehicle_model = GetVehicleModel(vehicleid) - 400;

	if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be the driver of a vehicle to use this command.");

	if (!GetVehicleParams(vehicleid, VEHICLE_TYPE_ENGINE)) {
		
		if (random(10)) {
			SetVehicleParams(vehicleid, VEHICLE_TYPE_ENGINE, true);
			SendNearbyMessage(playerid, 15.0, COLOR_PURPLE, "* %s switches the engine of the %s on.", GetPlayerNameEx(playerid), g_VehiclesName[vehicle_model]);
		}
		else {
			SendNearbyMessage(playerid, 15.0, COLOR_PURPLE, "* %s fails to switch the engine of the %s on.", GetPlayerNameEx(playerid), g_VehiclesName[vehicle_model]);
		}
	}
	else {
		SetVehicleParams(vehicleid, VEHICLE_TYPE_ENGINE, false);
		SendNearbyMessage(playerid, 15.0, COLOR_PURPLE, "* %s switches the engine of the %s off.", GetPlayerNameEx(playerid), g_VehiclesName[vehicle_model]);
	}
	return 1;
}

CMD:spawncar(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	if (IsPlayerInAnyVehicle(playerid))
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You cannot be in a vehicle while using this command.");

	new
		ID,
		c1 = -1,
		c2 = -1,
		s = 0;

	if (sscanf(params, "iiii", ID, c1, c2, s))
		return SendClientMessageEx(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/spawncar [vehicleid] [color1] [color2] (siren)");

	new
		Float:sX,
		Float:sY,
		Float:sZ,
		Float:sA;

	GetPlayerPos(playerid, sX, sY, sZ);
	GetPlayerFacingAngle(playerid, sA);

	PutPlayerInVehicle(playerid, CreateVehicle(ID, sX, sY, sZ, sA, c1, c2, 0, s), 0);
	SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have successfully spawned in a %d.", ID);

	return 1;
}

CMD:disarm(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;
	if (sscanf(params, "us[64]", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/disarm [playerid/partOfName]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has been disarmed by %s.", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid));
	ResetPlayerWeapons(targetid);

	return 1;
}

CMD:disarmall(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has disarmed all players.", GetPlayerNameEx(playerid));
	foreach (new i : gm_Players) {
		ResetPlayerWeapons(i);
	}

	return 1;
}

CMD:clearchat(playerid, params[])
{
	ClearPlayerChat(playerid);

	SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You've cleared your chat.");

	return 1;
}

CMD:clearchatall(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	ClearPlayerChat();

	SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have cleared everybody's chat.");

	return 1;
}

CMD:changepass(playerid, params[]) {
	if (eUser[playerid][e_USER_SQLID] != 1) {
		return SendClientMessage(playerid, COLOR_TOMATO, "Only registered users can use this command.");
	}

	Dialog_Show(playerid, CHANGE_PASSWORD, DIALOG_STYLE_PASSWORD, "Change account password...", COL_WHITE "Insert a new password for your account, Passwords are "COL_YELLOW"case sensitive"COL_WHITE".", "Confirm", "Cancel");
	SendClientMessage(playerid, COLOR_WHITE, "Enter your new password.");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
	return 1;
}

alias:addmap("createmap");
CMD:addmap(playerid, params[])
{
	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new mapname[32], min_crim, max_crim;
	if(sscanf(params, "s[32]dd", mapname, min_crim, max_crim))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/addmap [mapname] [min_criminals] [max_criminals]");

	if(min_crim < 1 || max_crim > 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Minimum Criminals cannot preceed 1 and Maximum Criminals cannot exceed 2.");

	if(g_Maps >= MAX_MAPS) {
		SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You cannot exceed the maximum maps of %d!", MAX_MAPS);
		return 1;
	}

	new string[144 + 32], Cache:result;
	mysql_format(g_SQL, string, sizeof string, "SELECT `name` FROM "#TABLE_MAPS" WHERE `name` = `%e`", mapname);
	result = mysql_query(g_SQL, string);
	cache_set_active(result);

	if(cache_num_rows()) {
		SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: That mapname '%s' is already in use, please pick another one!", mapname);
		cache_delete(result);
		return 1;
	}

	mysql_format(g_SQL, string, sizeof string, "INSERT INTO "#TABLE_MAPS"(`name`, `min_criminals`, `max_criminals`, `enabled`) \
		VALUES('%e', '%d', '%d', '0')", mapname, min_crim, max_crim);
	mysql_tquery(g_SQL, string);

	g_Maps ++;

	format(string, sizeof string, "[ ! ] {FFFFFF}%s has created a brand new map - '%s'.", GetPlayerNameEx(playerid), mapname);
	SendAdminMessage(COLOR_TOMATO, string);

	cache_delete(result);
	return 1;
}

alias:addspawn("createspawn");
CMD:addspawn(playerid, params[])
{
	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be in a vehicle or be a driver of a vehicle.");

	new mapid, team;
	if(sscanf(params, "dd", mapid, team))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/addspawn [mapid] [team]");

	if(team < 1 || team > 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Team cannot preceed 1 (Criminals) or exceed 2 (Responders).");

	new string[174], Cache:result;

	mysql_format(g_SQL, string, sizeof string, "SELECT 1 FROM "#TABLE_MAPS"");
	result = mysql_query(g_SQL, string);
	cache_set_active(result);

	if(cache_num_rows()) {
		for (new i = cache_num_rows(); i > 0; i--) {
			if(i >= MAX_MAP_SPAWNS) {
				SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You cannot exceed the maximum map spawns of %d!", MAX_MAP_SPAWNS);
				cache_delete(result);
				return 1;
			}
		}
	}

	new Float:x, 
		Float:y, 
		Float:z, 
		Float:a;

	GetVehiclePos(GetPlayerVehicleID(playerid), x, y, z);
	GetVehicleZAngle(GetPlayerVehicleID(playerid), a);

	mysql_format(g_SQL, string, sizeof string, "INSERT INTO "#TABLE_MAPSPAWNS"(`mapid`, `posx`, `posy`, `posz`, `posa`, `team`) \
		VALUES('%d', '%f', '%f', '%f', '%f', '%d')", mapid, x, y, z, a, team);
	mysql_tquery(g_SQL, string);

	format(string, sizeof string, "[ ! ] {FFFFFF}%s has created a brand new map spawn - for mapid '%d'.", GetPlayerNameEx(playerid), mapid);
	SendAdminMessage(COLOR_TOMATO, string);

	cache_delete(result);
	return 1;
}

/*alias:removemap("deletemap");
CMD:removemap(playerid, params[])
{
	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new mapid;
	if(sscanf(params, "d", mapid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/removemap [mapid]");

	new string[144], Cache:result;
	mysql_format(g_SQL, string, sizeof string, "SELECT * FROM "#TABLE_MAPS" WHERE `id` = %d", mapid);
	result = mysql_query(g_SQL, string);
	cache_set_active(result);

	if(cache_num_rows()) {
		new mapname[32];
		cache_get_value(0, "name", mapname, sizeof mapname);

		mysql_format(g_SQL, string, sizeof string, "DELETE FROM "#TABLE_MAPS" WHERE `id` = %d", mapid);
		mysql_tquery(g_SQL, string);

		format(string, sizeof string, "[ ! ] {FFFFFF}%s has removed a map - '%s'.", GetPlayerNameEx(playerid), mapname);
		SendAdminMessage(COLOR_TOMATO, string);

		SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have successfully deleted map ID %d (%s)!", mapid, mapname);

		g_Maps --;
	}
	else SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: Map ID %d does not exist!", mapid);

	cache_delete(result);
	return 1;
}

alias:removespawn("deletespawn");
CMD:removespawn(playerid, params[])
{
	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new spawnid;
	if(sscanf(params, "d", spawnid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/removespawn [spawnid]");

	new string[144], Cache:result;

	mysql_format(g_SQL, string, sizeof string, "SELECT * FROM "#TABLE_MAPSPAWNS" WHERE `id` = %d", spawnid);
	result = mysql_query(g_SQL, string);
	cache_set_active(result);

	if(cache_num_rows()) {
		new spawnmapid;
		cache_get_value_int(0, "mapid", spawnmapid);

		mysql_format(g_SQL, string, sizeof string, "DELETE FROM "#TABLE_MAPSPAWNS" WHERE `id` = %d", spawnid);
		mysql_tquery(g_SQL, string);

		format(string, sizeof string, "[ ! ] {FFFFFF}%s has removed a spawn - for mapid '%d'.", GetPlayerNameEx(playerid), spawnmapid);
		SendAdminMessage(COLOR_TOMATO, string);

		SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have successfully deleted spawn ID %d!", spawnid);
	}
	else SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: Spawn ID %d does not exist!", spawnid);

	cache_delete(result);
	return 1;
}*/

CMD:unban(playerid, params[]) {
	
	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "[ERROR]: You do not have sufficient permissions to use this command!");

	new targetname[MAX_PLAYER_NAME];
	if(sscanf(params, "s["#MAX_PLAYER_NAME"]", targetname))
		return SendClientMessage(playerid, COLOR_TOMATO, "[USAGE]: /unban [playerName]");

	new query[75];
	mysql_format(g_SQL, query, sizeof query, "DELETE * FROM "#TABLE_BANS" WHERE `name` = '%e'", targetname);
	mysql_pquery(g_SQL, query, "OnAdminUnban", "is", playerid, targetname);
	return 1;
}

CMD:ban(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, reason[32];
	if (sscanf(params, "us[32]", targetid, reason))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/ban [playerid/partOfName] [reason]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new string[320];

    mysql_format(g_SQL, string, sizeof string, "INSERT INTO "#TABLE_BANS"(`name`, `admin`, `ip`, `date`, `time`, `reason`, `gpci`)\
        VALUES('%e', '%e', '%s', '%s', '%s', '%e', '%e')", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid), GetPlayerIpEx(targetid),
        GetDateEx(), GetTimeEx(), reason, GetPlayerGPCI(targetid));
    mysql_pquery(g_SQL, string);

	SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has been banned by %s, reason: %s", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid), reason);
	Kick(targetid);

	return 1;
}

alias:silentban("sban");
CMD:silentban(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 2)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid, reason[32];
	if (sscanf(params, "us[32]", targetid, reason))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/silentban [playerid/partOfName] [reason]");

	if (!eUser[targetid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: This player is not logged in or connected!");

	new string[320];

    mysql_format(g_SQL, string, sizeof string, "INSERT INTO "#TABLE_BANS"(`name`, `admin`, `ip`, `date`, `time`, `reason`, `gpci`)\
        VALUES('%e', '%e', '%s', '%s', '%s', '%e', '%e')", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid), GetPlayerIpEx(targetid),
        GetDateEx(), GetTimeEx(), reason, GetPlayerGPCI(targetid));
    mysql_pquery(g_SQL, string);

    format(string, sizeof string, "AdmCmd: %s has been silent-banned by %s, reason: %s", GetPlayerNameEx(targetid), GetPlayerNameEx(playerid), reason);
	SendAdminMessage(COLOR_TOMATO, string);

	Kick(targetid);

	return 1;
}

alias:mcp("mappanel");
CMD:mcp(playerid) {

	if(eUser[playerid][e_USER_ADMIN_LEVEL] < 3)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");
	
	Dialog_Show(playerid, DIALOG_MCP, DIALOG_STYLE_TABLIST, "VCER - Map Panel", "Create Map\nDelete Map\nModify Map", "Proceed", "Cancel");
	return 1;
}

alias:repaircar("fixcar", "repairvehicle", "fixvehicle");
CMD:repaircar(playerid, params[])
{
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You do not have the required permissions to use this command.");

	new targetid;

	if(IsPlayerInAnyVehicle(playerid))
		targetid = GetPlayerVehicleID(playerid);

	if (sscanf(params, "d", targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "USAGE: {FFFFFF}/repaircar [vehicleid]");

	if(targetid == -1)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: That vehicleid is invalid and does not exist!");

	new Float:vh = GetVehicleHealth(targetid, vh);

	if(vh > 999.9)
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Your vehicle is already in mint condition.");

	RepairVehicle(targetid);
	SetVehicleHealth(targetid, 1000.0);

	SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have successfully repaired vehicle ID %d!", targetid);
	return 1;
}

CMD:switch(playerid, params[])
{
	if (!IsPlayerSpawned[playerid])
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be spawned in to use this command!");

	ShowLobbyDialog(playerid, 1);
	return 1;
}

/*CMD:mdc(playerid, params[])
{
	if (!Iter_Contains(gm_Responders, playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be a Responder to use this command!");

	if (IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must be in a vehicle to use this command!");

	Dialog_Show(playerid, DIALOG_MDC, DIALOG_STYLE_INPUT, "MDC", 
		"Please input the name or playerID of the player you are trying to look up:", "Search", "Close");

	return 1;
}*/
