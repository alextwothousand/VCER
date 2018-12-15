//new Text:TD_VCER;
new PlayerText:p_TD_VCER[MAX_PLAYERS];

//#include <YSI\y_hooks>

stock TDCreate_Vcer(playerid)
{
	p_TD_VCER[playerid] = CreatePlayerTextDraw(playerid, 6.333327, 403.889007, "mdl-12000:vcer");
	PlayerTextDrawTextSize(playerid, p_TD_VCER[playerid], 37.000000, 48.000000);
	PlayerTextDrawAlignment(playerid, p_TD_VCER[playerid], 1);
	PlayerTextDrawColor(playerid, p_TD_VCER[playerid], -1);
	PlayerTextDrawSetShadow(playerid, p_TD_VCER[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, p_TD_VCER[playerid], 255);
	PlayerTextDrawFont(playerid, p_TD_VCER[playerid], 4);
	PlayerTextDrawSetProportional(playerid, p_TD_VCER[playerid], 0);

	return 1;
}

stock TDHide_Vcer(playerid)
{
	PlayerTextDrawHide(playerid, p_TD_VCER[playerid]);
	return 1;
}

stock TDShow_Vcer(playerid)
{
	PlayerTextDrawShow(playerid, p_TD_VCER[playerid]);
	return 1;
}

stock TDDestroy_Vcer(type = 0)
{
	foreach(new i : Player)
	{
		if(type == 0) {
			PlayerTextDrawDestroy(i, p_TD_VCER[playerid]);
			return 1;
	}
	return 0;
}

/*hook OnPlayerConnect(playerid)
{
	TDCreate_Vcer();
	TDHide_Vcer(playerid);

	return 1;
}*/

/*hook OnPlayerDisconnect(playerid, reason)
{
	return TDDestroy_Vcer(1);
}*/

/*-hook OnGameModeExit()
{
	return TDDestroy_Vcer();
}*/