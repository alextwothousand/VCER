Dialog:DIALOG_LOGIN(playerid, response, listitem, inputtext[])
{
	if (!response) {
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);

		SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have opted to quit!");
		Kick(playerid);
		return 1;
	}

	new string[256], hash[64];
	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], hash, sizeof hash);

	if (strcmp(hash, eUser[playerid][e_USER_PASSWORD]))
	{
		if (++iLoginAttempts[playerid] == MAX_LOGIN_ATTEMPTS)
		{
			new lock_timestamp = gettime() + (MAX_ACCOUNT_LOCKTIME * 60);
			new ip[18];
			GetPlayerIp(playerid, ip, 18);

			mysql_format(g_SQL, string, sizeof string, "UPDATE `users` SET `lock_ip` = '%e', `lock_timestamp` = %i WHERE `id` = %i", ip, lock_timestamp, eUser[playerid][e_USER_SQLID]);
			mysql_pquery(g_SQL, string);

			SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have tried to log in too many times. Your IP has been temporarily blocked from use-");
			SendClientMessageEx(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}due to succeeding your maximum login attempts (%i/%i). This will last %i minutes.", MAX_LOGIN_ATTEMPTS, MAX_LOGIN_ATTEMPTS, MAX_ACCOUNT_LOCKTIME);

			return Kick(playerid);
		}
		ShowLoginDialog(playerid, 1);
		return 1;
	}

	mysql_format(g_SQL, string, sizeof string, "SELECT * FROM `users` WHERE `id` = %i", eUser[playerid][e_USER_SQLID]);
	mysql_pquery(g_SQL, string, "OnPlayerLogin", "ii", playerid, p_RaceCheck[playerid]);

	return 1;
}

Dialog:DIALOG_REGISTER(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);

		SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have opted to quit!");
		Kick(playerid);
		return 1;
	}

	if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
		return ShowRegisterDialog(playerid, 1);

	for (new i; i < 64; i++)
	{
		eUser[playerid][e_USER_SALT][i] = (random('z' - 'A') + 'A');
	}

	eUser[playerid][e_USER_SALT][64] = EOS;
	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_PASSWORD], 64);

	new string[1600];

	mysql_format(g_SQL, string, sizeof string,
		"INSERT INTO `users`(`name`, `ip`, `longip`, `password`, `salt`, `register_timestamp`, `lastlogin_timestamp`, `gpci`) \
		VALUES('%e', '%s', %i, '%e', '%e', '%i', '%i', '%s')",
		GetPlayerNameEx(playerid),
		GetPlayerIpEx(playerid),
		IpToLong(GetPlayerIpEx(playerid)),
		eUser[playerid][e_USER_PASSWORD],
		eUser[playerid][e_USER_SALT],
		gettime(),
		gettime(),
		GetPlayerGPCI(playerid)
	);
	mysql_tquery(g_SQL, string, "OnPlayerRegister", "ii", playerid, p_RaceCheck[playerid]);

	printf("ID inserted for %s is %d.", GetPlayerNameEx(playerid), eUser[playerid][e_USER_SQLID]);
	Log_Write("logs/queries.txt", "%s", string);

	SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have successfully registered, welcome to Vice City Emergency Responders!");
	eUser[playerid][e_USER_LOGGEDIN] = true;

	SetTimerEx("pingtimer", 6000, true, "i", playerid);
	ShowLobbyDialog(playerid, 0);

	/*new list[2 + (sizeof(SECURITY_QUESTIONS) * MAX_SECURITY_QUESTION_SIZE)];
	for (new i; i < sizeof(SECURITY_QUESTIONS); i++)
	{
		strcat(list, SECURITY_QUESTIONS[i]);
		strcat(list, "\n");
	}
	Dialog_Show(playerid, SEC_QUESTION, DIALOG_STYLE_LIST, "Account Registeration... [Step: 2/3]", list, "Continue", "Back");
	SendClientMessage(playerid, COLOR_WHITE, "[Step: 2/3] Select a security question. This will help you retrieve your password in case you forget it any time soon!");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);*/
	return 1;
}

Dialog:CHANGE_PASSWORD(playerid, response, listitem, inputtext[])
{
	if (!response)
		return 1;

	if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
	{
		Dialog_Show(playerid, CHANGE_PASSWORD, DIALOG_STYLE_PASSWORD, "Change account password...", COL_WHITE "Insert a new password for your account, Passwords are "COL_YELLOW"case sensitive"COL_WHITE".", "Confirm", "Cancel");
		SendClientMessage(playerid, COLOR_TOMATO, "Invalid password length, must be between "#MIN_PASSWORD_LENGTH" - "#MAX_PASSWORD_LENGTH" characters.");
		return 1;
	}

	#if defined SECURE_PASSWORD_ONLY
		new bool:contain_number,
			bool:contain_highercase,
			bool:contain_lowercase;
		for (new i, j = strlen(inputtext); i < j; i++)
		{
			switch (inputtext[i])
			{
				case '0'..'9':
					contain_number = true;
				case 'A'..'Z':
					contain_highercase = true;
				case 'a'..'z':
					contain_lowercase = true;
			}

			if (contain_number && contain_highercase && contain_lowercase)
				break;
		}

		if (!contain_number || !contain_highercase || !contain_lowercase)
		{
			Dialog_Show(playerid, CHANGE_PASSWORD, DIALOG_STYLE_INPUT, "Change account password...", COL_WHITE "Insert a new password for your account, Passwords are "COL_YELLOW"case sensitive"COL_WHITE".", "Confirm", "Cancel");
			SendClientMessage(playerid, COLOR_TOMATO, "Password must contain atleast a Highercase, a Lowercase and a Number.");
			return 1;
		}
	#endif

	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_PASSWORD], 64);

	new string[256];
	for (new i, j = strlen(inputtext); i < j; i++)
	{
		inputtext[i] = '*';
	}
	format(string, sizeof(string), "Successfully changed your password. [P: %s]", inputtext);
	SendClientMessage(playerid, COLOR_GREEN, string);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

Dialog:DIALOG_LOBBY_SELECTION(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		PlayerPlaySound(playerid, 1085, 0.0, 0.0, 0.0);

		SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have opted to quit!");
		Kick(playerid);
		return 1;
	}

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have selected the 'Main' lobby! You will now be spawned in...");

			eUser[playerid][e_USER_LOBBY] = Main;
			eUser[playerid][e_USER_LOGGEDIN] = true;

			//SpawnPlayer(playerid);

			//SetPlayerPos(playerid, 246.783996, 63.900199, 1003.640625);

			SetSpawnInfo(
				playerid,
				PLAYER_TEAM_LOBBY,
				1,
				246.783996, 64.2, 1003.640625, 0.0,
				0, 0,
				0, 0,
				0, 0
			);

			SetPlayerInterior(playerid, 6);
			SetPlayerVirtualWorld(playerid, 0);

			TogglePlayerSpectating(playerid, false);

			TogglePlayerControllable(playerid, false);
			SetTimerEx("freeze", 600, false, "d", playerid);

			dgone(playerid);
		}
		case 1:
		{
			SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have selected the 'Freeroam' lobby! You will now be spawned in...");

			eUser[playerid][e_USER_LOBBY] = Freeroam;
			eUser[playerid][e_USER_LOGGEDIN] = true;

			//SpawnPlayer(playerid);

			//SetPlayerPos(playerid, 5232.4399, -2228.6245, 11.5385);
			//SetPlayerFacingAngle(playerid, 258.0844);
			SetSpawnInfo(
				playerid,
				PLAYER_TEAM_LOBBY,
				1,
				5232.4399, -2228.6245, 11.5385, 258.0844,
				0, 0,
				0, 0,
				0, 0
			);

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			TogglePlayerSpectating(playerid, false);

			TogglePlayerControllable(playerid, false);
			SetTimerEx("freeze", 1500, false, "d", playerid);

			dgtwo(playerid);
		}
	}

	OnPlayerRequestClass(playerid, 0);

	//TDHide_Login(playerid);
	//TDShow_Vcer(playerid);

	return 1;
}

Dialog:DIALOG_LOBBY_SWITCH(playerid, response, listitem, inputtext[])
{
	if (!response) return 1;

	switch(listitem)
	{
		case 0:
		{
			SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have selected the 'Main' lobby! You will now be spawned in...");

			eUser[playerid][e_USER_LOBBY] = Main;

			SetPlayerInterior(playerid, 6);
			SetPlayerVirtualWorld(playerid, 0);

			SetPlayerPos(playerid, 246.783996, 64.2, 1003.640625);
			SetPlayerTeam(playerid, PLAYER_TEAM_LOBBY);

			TogglePlayerSpectating(playerid, false);

			TogglePlayerControllable(playerid, false);
			SetTimerEx("freeze", 600, false, "d", playerid);

			dgthree(playerid);

		}
		case 1:
		{
			SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have selected the 'Freeroam' lobby! You will now be spawned in...");

			eUser[playerid][e_USER_LOBBY] = Freeroam;

			SetPlayerInterior(playerid, 0);
			SetPlayerVirtualWorld(playerid, 0);

			SetPlayerPos(playerid, 5232.4399, -2228.6245, 11.5385);
			SetPlayerFacingAngle(playerid, 258.0844);
			SetPlayerTeam(playerid, PLAYER_TEAM_LOBBY);

			TogglePlayerSpectating(playerid, false);

			TogglePlayerControllable(playerid, false);
			SetTimerEx("freeze", 600, false, "d", playerid);

			dgfour(playerid);
		}
	}

	OnPlayerRequestClass(playerid, 0);

	//TDHide_Login(playerid);
	//TDShow_Vcer(playerid);

	return 1;
}

callback:dgone(playerid) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(!Iter_Contains(gm_Players, playerid)) {
		Iter_Add(gm_Players, playerid);
		SendClientMessage(playerid, -1, "[debug] added to gm_Players! (dialogs 1)");
	}
	return 1;
}

callback:dgthree(playerid) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(!Iter_Contains(gm_Players, playerid)) {
		Iter_Add(gm_Players, playerid);
		SendClientMessage(playerid, -1, "[debug] added to gm_Players! (dialogs 3)");
	}
	return 1;
}

callback:dgtwo(playerid) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(Iter_Contains(gm_Players, playerid)) {
		Iter_Remove(gm_Players, playerid);
		SendClientMessage(playerid, -1, "[debug] removed from gm_Players! (dialogs 2)");
	}
	return 1;
}

callback:dgfour(playerid) {
	if(!IsPlayerConnected(playerid)) return 1;
	if(Iter_Contains(gm_Players, playerid)) {
		Iter_Remove(gm_Players, playerid);
		SendClientMessage(playerid, -1, "[debug] removed from gm_Players! (dialogs 4)");
	}
	return 1;
}

Dialog:DIALOG_ADMINPANEL_MAIN(playerid, response, listitem, inputtext[]) {
	if (!response) {
		p_SelectedPlayer[playerid] = INVALID_PLAYER_ID;
		return 1;
	}

	new
		lookupid;
	if ((lookupid = p_SelectedPlayer[playerid]) == INVALID_PLAYER_ID) {
		SendClientMessage(playerid, COLOR_TOMATO, "ERROR: An error occured.");
		return 1;
	}

	switch (listitem) {
		case 0: {
			// Ban statement
		}

		case 1: {
			Dialog_Show(playerid, DIALOG_KICKPANEL_CONFIRM, DIALOG_STYLE_MSGBOX, "Kick Player",
			""COL_WHITE"Are you sure you would like to proceed with kicking this player?",
			MENU_PROCEED, MENU_BACK);
		}

		case 2: {
			ShowStatsForPlayer(playerid, lookupid);
			
			p_SelectedPlayer[playerid] = INVALID_PLAYER_ID;
		}
	}
	return 1;
}

Dialog:DIALOG_KICKPANEL_CONFIRM(playerid, response, listitem, inputtext[])
{
	if(!response) return ShowAdminPanelDialog(playerid);

	else
	{
		Dialog_Show(playerid, DIALOG_KICKPANEL, DIALOG_STYLE_INPUT, "Input Reason for Player Kick",
			""COL_WHITE"Please input the reason for kicking this player.",
			MENU_PROCEED, MENU_BACK
		);
	}

	return 1;
}

Dialog:DIALOG_KICKPANEL(playerid, response, listitem, inputtext[])
{
	if(!response) return ShowAdminPanelDialog(playerid);

	if(strlen(inputtext) < 3)
	{
		Dialog_Show(playerid, DIALOG_KICKPANEL, DIALOG_STYLE_INPUT, "Input Reason for Player Kick",
			""COL_WHITE"Please input the reason for kicking this player.",
			MENU_PROCEED, MENU_BACK
		);

		SendClientMessage(playerid, COLOR_TOMATO, "ERROR: Your kick reason is too short, try again.");
	}

	else
	{
		SendClientMessageToAllEx(COLOR_TOMATO, "AdmCmd: %s has been kicked by %s, reason: %s", GetPlayerNameEx(p_SelectedPlayer[playerid]), GetPlayerNameEx(playerid), inputtext);
		Kick(p_SelectedPlayer[playerid]);

		p_SelectedPlayer[playerid] = INVALID_PLAYER_ID;
	}

	return 1;
}

Dialog:DIALOG_MCP(playerid, response, listitem, inputtext[]) {

	if (!response) return 1;

	SendClientMessage(playerid, -1, "Coming soon.");
	return 1;
}

/*Dialog:DIALOG_MDC(playerid, response, listitem, inputtext[]) {
	if (!response) return 1;

	if (isnull(inputtext)) {
		SendClientMessage(playerid, COLOR_TOMATO, "ERROR: You must input something!");

		Dialog_Show(playerid, DIALOG_MDC, DIALOG_STYLE_INPUT, "MDC", 
			"Please input the name or playerID of the player you are trying to look up:", "Search", "Close");

		return 1;
	}

	if (!sscanf(inputtext, "d", inputtext)) 
	{
		new lookupid = inputtext;
		if (!IsPlayerConnected(lookupid)) 
		{
			SendClientMessage(playerid, COLOR_TOMATO, "ERROR: That player is not connected!");

			Dialog_Show(playerid, DIALOG_MDC, DIALOG_STYLE_INPUT, "MDC", 
				"Please input the name or playerID of the player you are trying to look up:", "Search", "Close");

			return 1;			
		}
		new string[144];

		mysql_format(g_SQL, string, sizeof string, "SELECT * FROM "#TABLE_CHARGES" WHERE `criminalid` = %d", 
			eUser[lookupid][e_USER_SQLID]);
		mysql_pquery(g_SQL, string, "OnPlayerMDCCheck", "i", playerid);
		return 1;
	}
}*/