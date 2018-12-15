enum e_LOG_TYPES {
	LOG_TYPE_CONNECT,
	LOG_TYPE_DISCONNECT,
	
	LOG_TYPE_COMMAND_SUCCESS,
	LOG_TYPE_COMMAND_FAILURE,

	LOG_TYPE_CHAT,
}

callback:Log_Init(e_LOG_TYPES:type, playerid, const data[], {Float,_}:...) {
	static
		args,
		str[144];

	/*
	 *  Custom function that uses #emit to format variables into a string.
	 *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 3) {
		Log_Forward(type, playerid, data);
	}
	else {
		while (--args >= 3) {
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S data
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		Log_Forward(type, playerid, str);

		#emit RETN
	}
	return 1;
}

callback:Log_Forward(e_LOG_TYPES:type, playerid, const data[]) {
	new title[MAX_PLAYER_NAME + 8];
	format(title, sizeof title, "%s (%i)", GetPlayerNameEx(playerid), playerid);

	switch(type) {
		case LOG_TYPE_CONNECT: {
			Log_ToDiscord("log.connections", title, COLOR_GREEN, data);
		}
		case LOG_TYPE_DISCONNECT: {
			Log_ToDiscord("log.connections", title, COLOR_TOMATO, data);
		}
	
		case LOG_TYPE_COMMAND_SUCCESS: {
			Log_ToDiscord("log.commands", title, COLOR_GREEN, data);
		}
		case LOG_TYPE_COMMAND_FAILURE: {
			Log_ToDiscord("log.commands", title, COLOR_TOMATO, data);
		}

		case LOG_TYPE_CHAT: {
			Log_ToDiscord("log.chat", title, COLOR_DEFAULT, data);
		}
	}
	return 1;
}

callback:Log_ToDiscord(channel[], title[], color, const data[]) {
	new message[MAX_PLAYER_NAME + 8 + 144], channelex[64];
	format(message, sizeof message, "%x|%s|%s", color, title, data);
	format(channelex, sizeof channelex, "saer.rediscord.%s.outgoing", channel);
	//Redis_SendMessage(g_Redis, channelex, message);
	//Redis_Publish(g_Redis, channelex, message);
	return 1;
}
