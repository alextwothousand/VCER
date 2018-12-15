/*------------------------------[IMPROVED AUDIO STREAMS BY INFINITY]---------------------------

					Credits go to Kar and y_less for their foreach include
	This adds new features and gives more possibilities with what you can do in regards to Audio Streams.

					NOTE: Using Foreach is recommended however not necessary.
	You must be using the latest update of foreach created by Kar, it is available here: 
					http://forum.sa-mp.com/showthread.php?t=570868

--------------------------------------------------------------------------------------------*/

#if !defined function
	#define function:%0(%1) forward %0(%1); public %0(%1)
#endif

enum e_STREAM_DATA
{
	bool:e_STREAMING
};

new e_USER_STREAM_DATA[MAX_PLAYERS][e_USER_STREAM_DATA];

stock iIsPlayerStreamingAudio(playerid)
{
	return e_USER_STREAM_DATA[playerid][e_STREAMING];
}

stock iPlayAudioStreamForPlayer(playerid, url[], Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:d = 0.0, usepos = 0)
{
	PlayAudioStreamForPlayer(playerid, url, x, y, z, d, usepos);
	CallLocalFunction("OnAudioStreamToggledForPlayer", "i", playerid);

	return 1;
}

stock iStopAudioStreamForPlayer(playerid)
{
	StopAudioStreamForPlayer(playerid);
	CallLocalFunction("OnAudioStreamToggledForPlayer", "i", playerid);

	return 1;
}

stock iPlayAudioStreamForAll(url[], Float:x = 0.0, Float:y = 0.0, Float:z = 0.0, Float:d = 0.0, usepos = 0)
{
	#if defined foreach
    foreach(new i : Player) {
    #else
    for(new i = 0, k = GetPlayerPoolSize(); i <= k; i++) {
    #endif

    	iPlayAudioStreamForPlayer(i, x, y, z, d, usepos);
    }

    return 1;
}

stock iStopAudioStreamForAll()
{
	#if defined foreach
    foreach(new i : Player) {
    #else
    for(new i = 0, k = GetPlayerPoolSize(); i <= k; i++) {
    #endif

    	iStopAudioStreamForPlayer(i);
    }

    return 1;
}

function:OnAudioStreamToggledForPlayer(playerid)
{
	switch(e_USER_STREAM_DATA[playerid][e_STREAMING])
	{
		case 1: e_USER_STREAM_DATA[playerid][e_STREAMING] = false;
		case 0: e_USER_STREAM_DATA[playerid][e_STREAMING] = true;
	}

	return 1;
}