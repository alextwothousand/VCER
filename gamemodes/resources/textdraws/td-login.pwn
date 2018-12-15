/*-new
	Text:TD_LOGIN,
	Text:TD_LOGIN_BOX;*/

new PlayerText:p_TD_LOGIN[MAX_PLAYERS];
new PlayerText:p_TD_LOGIN_BOX[MAX_PLAYERS];

//#include <YSI\y_hooks>

forward TDCreate_Login(playerid);
public TDCreate_Login(playerid)
{
	/*TD_LOGIN = TextDrawCreate(277.999969, 108.955520, "mdl-12000:vcer");
	TextDrawTextSize(TD_LOGIN, 90.000000, 90.000000);
	TextDrawAlignment(TD_LOGIN, 1);
	TextDrawColor(TD_LOGIN, -1);
	TextDrawSetShadow(TD_LOGIN, 0);
	TextDrawBackgroundColor(TD_LOGIN, 255);
	TextDrawFont(TD_LOGIN, 4);
	TextDrawSetProportional(TD_LOGIN, 0);*/

	p_TD_LOGIN[playerid] = CreatePlayerTextDraw(playerid, 224.999954, 61.666656, "mdl-12000:VCER-2");
	PlayerTextDrawTextSize(playerid, p_TD_LOGIN[playerid], 194.000000, 90.000000);
	PlayerTextDrawAlignment(playerid, p_TD_LOGIN[playerid], 1);
	PlayerTextDrawColor(playerid, p_TD_LOGIN[playerid], -1);
	PlayerTextDrawSetShadow(playerid, p_TD_LOGIN[playerid], 0);
	PlayerTextDrawBackgroundColor(playerid, p_TD_LOGIN[playerid], 255);
	PlayerTextDrawFont(playerid, p_TD_LOGIN[playerid], 4);
	PlayerTextDrawSetProportional(playerid, p_TD_LOGIN[playerid], 0);

	p_TD_LOGIN_BOX[playerid] = CreatePlayerTextDraw(playerid, 3.000008, 54.355560, "box");
	PlayerTextDrawLetterSize(playerid, p_TD_LOGIN_BOX[playerid], 0.000000, 11.733332);
	PlayerTextDrawTextSize(playerid, p_TD_LOGIN_BOX[playerid], 641.000000, 0.000000);
	PlayerTextDrawAlignment(playerid, p_TD_LOGIN_BOX[playerid], 1);
	PlayerTextDrawColor(playerid, p_TD_LOGIN_BOX[playerid], 0x00000022);
	PlayerTextDrawUseBox(playerid, p_TD_LOGIN_BOX[playerid], 1);
	PlayerTextDrawSetShadow(playerid, p_TD_LOGIN_BOX[playerid], 0);
	PlayerTextDrawFont(playerid, p_TD_LOGIN_BOX[playerid], 1);
	PlayerTextDrawSetProportional(playerid, p_TD_LOGIN_BOX[playerid], 1);

	return 1;

}

stock TDHide_Login(playerid)
{
	PlayerTextDrawHide(playerid, p_TD_LOGIN[playerid]);
	PlayerTextDrawHide(playerid, p_TD_LOGIN_BOX[playerid])
	return 1;
}

stock TDShow_Login(playerid)
{
	PlayerTextDrawShow(playerid, p_TD_LOGIN[playerid]);
	PlayerTextDrawShow(playerid, p_TD_LOGIN_BOX[playerid]);
	return 1;
}

stock TDDestroy_Login(playerid, type = 0)
{
	foreach(new i : Player)
	{
		if(type == 0)
		{
			PlayerTextDrawHide(playerid, p_TD_LOGIN[playerid]);
			PlayerTextDrawHide(playerid, p_TD_LOGIN_BOX[playerid])
		}
		else if(type == 1)
		{
			PlayerTextDrawDestroy(i, p_TD_LOGIN[i]);
			PlayerTextDrawDestroy(i, p_TD_LOGIN_BOX[i])
			break;
		}
		else
		{
			//#error "td-login.pwn: you've selected an impossible type!"
			break;
		}

		/*else if(type == 1)
		{
			PlayerTextDrawDestroy(i, TD_LOGIN);
		}*/
	}
	return 1;
}

forward CreateTextdraws(playerid);
public CreateTextdraws(playerid)
{
	TDCreate_Login(playerid);
	TDHide_Login(playerid);

	return 1;
}

/*hook OnPlayerDisconnect(playerid, reason)
{
	return TDDestroy_Login(1);
}

hook OnGameModeExit()
{
	return TDDestroy_Login();
}*/