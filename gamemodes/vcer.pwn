/*----------------------------------------------------------------------------------
						Vice City Emergency Responders
-----------------------------------------------------------------------------------*/

/*
	Notice:
	
	All non-player global variables must have "g_" as the prefix and must be named properly.
	All player global variables must have "p_" as the prefix and must be named properly.
*/

#include <a_samp>
#include <a_mysql>

#include <streamer>
#include <sscanf2>
#include <foreach>
//#include <YSI\y_hooks>
#include <evf>

#include <Pawn.CMD>
#include <easydialog>
#include <kickbanfix>
#include <redis>
#include <strlib>
#include <nex-ac>

#if !defined IsValidVehicle
	native IsValidVehicle(vehicleid);
#endif

#if !defined gpci
	native gpci(playerid, serial[], len);
#endif

forward OnPlayerRequestDownload(playerid, type, crc);
forward OnPlayerFinishedDownloading(playerid, virtualworld);

#define COLOR_WHITE		0xFFFFFFFF
#define COL_WHITE		"{FFFFFF}"

#define COLOR_TOMATO	0xFF6347FF
#define COL_TOMATO		"{FF6347}"

#define COLOR_LIGHTRED	COLOR_TOMATO
#define COL_LIGHTRED	COL_TOMATO

#define COLOR_YELLOW	0xFFDD00FF
#define COL_YELLOW		"{FFDD00}"

#define COLOR_GREEN		0x00FF00FF
#define COL_GREEN		"{00FF00}"

#define COLOR_DEFAULT	0xA9C4E4FF
#define COL_DEFAULT		"{A9C4E4}"

#define COLOR_GREY		0xAFAFAFFF
#define COL_GREY		"{AFAFAF}"

#define COLOR_BLUE		0x2641FEFF
#define COL_BLUE		"{2641FE}"

#define COLOR_PURPLE	0xD0AEEBFF
#define COL_PURPLE		"{D0AEEB}"

#define COLOR_ORANGE	0xFFA500FF
#define COL_ORANGE		"{FFA500}"

#define COLOR_DONATOR	0xBC681AFF
#define COL_DONATOR		"{BC681A}"

#define COLOR_SERVER	0xFFFF90FF
#define COL_SERVER		"{FFFF90}"

#define COLOR_PINK		0xF88EAEFF // Do not change these colors
#define COL_PINK		"{F88EAE}" // Do not change these colors

#define SQL_HOSTNAME			"127.0.0.1"
#define SQL_USERNAME			""
#define SQL_DATABASE			""
#define SQL_PASSWORD			""

#define MAX_LOGIN_ATTEMPTS		3
#define MAX_ACCOUNT_LOCKTIME	2 // Minutes

#define MIN_PASSWORD_LENGTH		4
#define MAX_PASSWORD_LENGTH		45

#define MAX_PING				400
#define MAX_PACKETLOSS			8
#define MAX_SPIKESTRIPS			20

#define MAX_GAME_TIME			300000 // 5 minutes, or 300000 milliseconds.
#define CRIMINAL_WEAPON_TIMER	30000 // 30 seconds
#define PLAYER_CHECK_TIMER		20000 // 20 seconds

#define MAX_GPCI_LEN			41
#define MAX_CHARGE_LEN			40

#define MAX_PLAYER_VEHICLES 	8
#define MAX_MAPS				16
#define MAX_MAP_SPAWNS			32
#define PLAYERS_TO_START		2

#define MOTD_TYPE_GLOBAL 		0
#define MOTD_TYPE_HELPER		1
#define MOTD_TYPE_STAFF			2
#define MOTD_TYPE_ADMIN			3

#define HOSTNAME				"> Vice City Emergency Responders [0.3-DL]"
#define HOSTNAME_FAIL			"> Vice City Emergency Responders [Maintenance]"
#define MODE					"VCER 0.5"
#define MODE_FAIL				"VCER [ERROR]"

#define TABLE_USERS				"`users`"
#define TABLE_BANS				"`bans`"
#define TABLE_MAPSPAWNS 		"`mapspawns`"
#define TABLE_MAPS				"`maps`"
#define TABLE_CHARGES			"`charges`"

#define MENU_PROCEED			"Proceed"
#define MENU_BACK				"Back"
#define MENU_EXIT				"Exit"

new Redis: g_Redis,
	MySQL: g_SQL,
	MODEL_DOWNLOAD_URL[] = "https://cdn.vcer.pw/downloads/models",
	LOGIN_MUSIC_URL[] = "https://cdn.vcer.pw/audio/login.mp3",
	g_Timers[4],
	g_Maps,
	p_RaceCheck[MAX_PLAYERS];

#define callback:%0(%1) \
	forward %0(%1);\
	public %0(%1)

#define HOLDING(%0) \
	((newkeys & (%0)) == (%0))

#define PRESSED(%0) \
	(((newkeys & (%0)) == (%0)) && ((oldkeys & (%0)) != (%0)))

#define RELEASED(%0) \
	(((newkeys & (%0)) != (%0)) && ((oldkeys & (%0)) == (%0)))

main() {
	SetGameModeText(MODE);
	SendRconCommand("hostname "#HOSTNAME"");
}

AntiDeAMX() {
	new const a[][] = {
		"Unarmed (Fist)",
		"Brass K"
	};
	#pragma unused a
}

enum { // Body parts
	BODY_PART_TORSO = 3,
	BODY_PART_GROIN,
	BODY_PART_LEFT_ARM,
	BODY_PART_RIGHT_ARM,
	BODY_PART_LEFT_LEG,
	BODY_PART_RIGHT_LEG,
	BODY_PART_HEAD,
};

/* Used Virtual Worlds:
	0 - Lobby
	1 - Game
	2 - DM
	256-512 - Freeroam
*/

enum {
	SERVER_WORLD_LOBBY,
	SERVER_WORLD_GAME,
	SERVER_WORLD_FREEROAM = 256,
}

new const g_VehiclesName[][] = {
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck",
	"Trashmaster", "Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah",
	"Ambulance", "Leviathan", "Moonbeam", "Esperanto", "Taxi", "Washington", "Bobcat", "Mr Whoopee",
	"BF Injection", "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Article Trailer", "Previon", "Coach", "Cabbie", "Stallion",
	"Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral", "Squallo", "Seasparrow",
	"Pizzaboy", "Tram", "Article Trailer 2", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed",
	"Yankee", "Caddy", "Solair", "Berkley's RC Van", "Skimmer", "PCJ-600", "Faggio", "Freeway",
	"RC Baron", "RC Raider", "Glendale", "Oceanic", "Sanchez", "Sparrow", "Patriot", "Quad",
	"Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina",
	"Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick",
	"SAN News Maverick", "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring Racer", "Sandking",
	"Blista Compact", "Police Maverick", "Boxville", "Banson", "Mesa", "RC Goblin", "Hotring Racer", "Hotring Racer",
	"Bloodring Banger", "Rancher", "Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle",
	"Cropduster", "Stuntplane", "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal",
	"Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Towtruck", "Fortune", "Cadrona",
	"FBI Truck", "Willard", "Forklift", "Tractor", "Combine Harvester", "Feltzer", "Remington", "Slamvan",
	"Blade", "Freight (Train)", "Brownstreak (Train)", "Vortex", "Vincent", "Bullet", "Clover", "Sadler",
	"Firetruck LA", "Hustler", "Intruder", "Primo", "Cargobob", "Tampa", "Sunrise", "Merit",
	"Utility Van", "Nevada", "Yosemite", "Windsor", "Monster A", "Monster B", "Uranus", "Jester",
	"Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna",
	"Bandito", "Freight Flat Trailer", "Brownstreak Trailer", "Kart", "Mower", "Dune", "Sweeper", "Broadway",
	"Tornado", "AT400", "DFT-30", "Huntley", "Stafford", "BF-400", "Newsvan", "Tug",
	"Petrol Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club", "Freight Box Trailer", "Article Trailer 3",
	"Andromada", "Dodo", "RC Cam", "Launch", "Police Cruiser (LSPD)", "Police Cruiser (SFPD)", "Police Cruiser (LVPD)", "Police Ranger",
	"Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale Shit", "Sadler Shit", "Baggage Trailer A", "Baggage Trailer B",
	"Tug Stairs Trailer", "Boxville", "Farm Trailer", "Utility Trailer"
};

enum e_USER
{
	e_USER_SQLID,

	e_USER_PASSWORD[64 + 1],
	e_USER_SALT[64 + 1],

	e_USER_KILLS,
	e_USER_DEATHS,

	e_USER_SCORE,
	e_USER_MONEY,

	e_USER_ADMIN_LEVEL,
	e_USER_VIP_LEVEL,
	e_USER_STREAMER_LEVEL,

	e_USER_REGISTER_TIMESTAMP,
	e_USER_LASTLOGIN_TIMESTAMP,

	bool:e_USER_AFK,
	bool:e_USER_ADUTY,

	e_USER_GPCI[MAX_GPCI_LEN],
	bool:e_USER_LOGGEDIN,

	Float:e_Packet,
	e_LOBBIES:e_USER_LOBBY,

	e_USER_VEHICLES[MAX_PLAYER_VEHICLES],
	bool:e_USER_VEHICLE_SPAWNED,
	e_USER_VEHICLE_SPAWNED_ID,

	e_USER_WINS,
	e_USER_LOSSES
};

enum e_USER_TOGGLE
{
	e_SC,
	e_PM,
	e_B,
	e_DC,
	e_Gold,
	e_Global
};

enum e_LOBBIES
{
	Main,
	Freeroam,
	DM
};

/*enum e_VEHICLE_SYSTEM
{
	e_VEHICLE_SQLID,
	bool:e_VEHICLE_EXISTS,

	e_VEHICLE_OWNER_SQLID,

	e_VEHICLE_MODEL,
	e_VEHICLE_COLOR_1,
	e_VEHICLE_COLOR_2,
	e_VEHICLE_COLOR_PAINTJOB,

	Float:e_VEHICLE_PARK_POS[4],
	e_VEHICLE_PARK_INTERIOR,
	e_VEHICLE_PARK_WORLD,

	e_VEHICLE_PLATES[32],
	bool:e_VEHICLE_LOCKED,
}*/

new eUser[MAX_PLAYERS][e_USER],
	//eVehicle[MAX_VEHICLES][e_VEHICLE_SYSTEM],
	eToggle[MAX_PLAYERS][e_USER_TOGGLE],

	iLoginAttempts[MAX_PLAYERS],
	iAnswerAttempts[MAX_PLAYERS],

	LegShots[MAX_PLAYERS] = {0, ...},

	togglobal = 0,

	PacketLossWarnings[MAX_PLAYERS] = 0,

	criminal = 0,

	p_SelectedPlayer[MAX_PLAYERS],

	bool:IsPlayerDownloading[MAX_PLAYERS],
	bool:IsPlayerSpawned[MAX_PLAYERS] = false;

//___ENUMERATORS___//
enum e_GM_STATE {
	Waiting, // waiting for players
	Lobby, // short time between games
	Starting, // setup time before a new game
	InProgress, // game in progress
	Ending, // destruct time after a game is finished
}

enum e_GM_TEAMS {
	PLAYER_TEAM_LOBBY = 0,
	PLAYER_TEAM_CRIMINAL,
	PLAYER_TEAM_RESPONDER
};

enum e_GM_WEAPON_SPECIALTY {
	Lethal,
	Beanbag,
}

enum e_GM_WEAPONS
{
	WeaponID,
	Ammo,
	e_GM_WEAPON_SPECIALTY:Specialty,
}

enum e_GM_VEHICLES
{
	// global
	bool:InGame,
	e_GM_TEAMS:Type,
	Float:MaxHealth,

	// responders
	Siren,
	GunRack1[e_GM_WEAPONS],
	GunRack2[e_GM_WEAPONS],
	Trunk1[e_GM_WEAPONS],
	Trunk2[e_GM_WEAPONS],
}

enum e_GM_PLAYERS
{
	WeaponHolster[e_GM_WEAPONS],
	WeaponSling[e_GM_WEAPONS],
}

enum e_GM_SPIKES
{
	Existing,
	Float:X,
	Float:Y,
	Float:Z,
	Object,
	Text3D:Text,
}

enum e_GM_TEMP_INFO
{
	VehicleID,
}

enum e_GM_MAPS
{
	SQLID,
	Name[32],
	MinCriminals,
	MaxCriminals,
	bool:Enabled
}

enum e_GM_MAP_SPAWNS
{
	SQLID,
	MapID,
	Float:X,
	Float:Y,
	Float:Z,
	Float:A,
	e_GM_TEAMS:Team
}

//___VARIABLES___//
new Iterator:gm_Players<MAX_PLAYERS>,
	Iterator:gm_CurrPlayers<MAX_PLAYERS>,
	Iterator:gm_SelectionPool<MAX_PLAYERS>,
	Iterator:gm_VehiclePool<MAX_VEHICLES>,
	Iterator:gm_Criminals<MAX_PLAYERS>,
	Iterator:gm_Responders<MAX_PLAYERS>,
	Iterator:gm_Map_Spawns[MAX_MAPS]<MAX_MAP_SPAWNS>;

new
	e_GM_STATE:gm_State,
	gm_VehicleData[MAX_VEHICLES][e_GM_VEHICLES],
	gm_PlayerData[MAX_PLAYERS][e_GM_PLAYERS],
	gm_Spikes[MAX_SPIKESTRIPS][e_GM_SPIKES],
	gm_TempInfo[MAX_PLAYERS][e_GM_TEMP_INFO],
	gm_Maps[MAX_MAPS][e_GM_MAPS],
	gm_Spawns[MAX_MAP_SPAWNS][e_GM_MAP_SPAWNS];

IpToLong(const address[]) {
	new parts[4];
	sscanf(address, "p<.>a<i>[4]", parts);
	return ((parts[0] << 24) | (parts[1] << 16) | (parts[2] << 8) | parts[3]);
}

ReturnTimelapse(start, till) {
	new ret[32], seconds = till - start;

	const
		MINUTE = 60,
		HOUR = 60 * MINUTE,
		DAY = 24 * HOUR,
		MONTH = 30 * DAY;

	if (seconds == 1)
		format(ret, sizeof(ret), "a second");
	if (seconds < (1 * MINUTE))
		format(ret, sizeof(ret), "%i seconds", seconds);
	else if (seconds < (2 * MINUTE))
		format(ret, sizeof(ret), "a minute");
	else if (seconds < (45 * MINUTE))
		format(ret, sizeof(ret), "%i minutes", (seconds / MINUTE));
	else if (seconds < (90 * MINUTE))
		format(ret, sizeof(ret), "an hour");
	else if (seconds < (24 * HOUR))
		format(ret, sizeof(ret), "%i hours", (seconds / HOUR));
	else if (seconds < (48 * HOUR))
		format(ret, sizeof(ret), "a day");
	else if (seconds < (30 * DAY))
		format(ret, sizeof(ret), "%i days", (seconds / DAY));
	else if (seconds < (12 * MONTH))
	{
		new months = floatround(seconds / DAY / 30);
		if (months <= 1)
			format(ret, sizeof(ret), "a month");
		else
			format(ret, sizeof(ret), "%i months", months);
	}
	else
	{
		new years = floatround(seconds / DAY / 365);
		if (years <= 1)
			format(ret, sizeof(ret), "a year");
		else
			format(ret, sizeof(ret), "%i years", years);
	}
	return ret;
}

public OnGameModeInit()
{
	AntiDeAMX();

	print("[OnGameModeInit] Initiating script...");
	print("[OnGameModeInit] Initiating database.");

	new MySQLOpt:options = mysql_init_options();
	mysql_set_option(options, SERVER_PORT, 3306);

	mysql_log(ALL);

	g_SQL = mysql_connect(SQL_HOSTNAME, SQL_USERNAME, SQL_PASSWORD, SQL_DATABASE, options);

	print("[OnGameModeInit] Checking database status.");

	if (g_SQL == MYSQL_INVALID_HANDLE || mysql_errno(g_SQL) != 0)
	{
		print("> [SQL] Failed to initiate the connection with the database.");
		print("> Server unloading...");
		SendRconCommand("exit");

		Log_Write("logs/sql_log.txt", "Server exiting due to failed database connection...");
	}

	else print("> [SQL] Connection with the database successful!");

	OnVCModeInit(); // vc.pwn
	CreateVCPlayerModels(); // misc.pwn

	InitializeMapping();

	new string[2048];
	string = "CREATE TABLE IF NOT EXISTS "#TABLE_USERS"(\
		`id` INT UNSIGNED NOT NULL AUTO_INCREMENT, \
		`name` VARCHAR(24) DEFAULT NULL, \
		`ip` VARCHAR(18) DEFAULT NULL, \
		`longip` INT DEFAULT NULL, \
		`password` VARCHAR(64) DEFAULT NULL, \
		`salt` VARCHAR(64) DEFAULT NULL, ";
	strcat(string, "`register_timestamp` INT, \
		`lastlogin_timestamp` INT DEFAULT NULL, \
		`kills` INT DEFAULT '0', \
		`deaths` INT DEFAULT '0', \
		`score` INT DEFAULT '0', \
		`money` INT DEFAULT '0', \
		`adminlevel` INT DEFAULT '0', \
		`viplevel` INT DEFAULT '0', \
		`streamerlevel` INT DEFAULT '0', ");
	strcat(string, "`gpci` VARCHAR("#MAX_GPCI_LEN") DEFAULT NULL, \
		`wins` INT DEFAULT '0', \
		`losses` INT DEFAULT '0', \
		`lock_ip` VARCHAR(18) DEFAULT NULL, \
		`lock_timestamp` INT DEFAULT '0', \
		PRIMARY KEY(`id`), \
		UNIQUE KEY `name` (`name`))");
	mysql_query(g_SQL, string);

	/*string = "CREATE TABLE IF NOT EXISTS `temp_blocked_users` (\
		`ip` VARCHAR(18) DEFAULT NULL, \
		`lock_timestamp` INT DEFAULT '0', \
		`user_id` INT)";
	mysql_query(g_SQL, string);*/

	string = "CREATE TABLE IF NOT EXISTS "#TABLE_BANS"(\
		`id` INT NOT NULL AUTO_INCREMENT, \
		`name` VARCHAR(24), \
		`admin` VARCHAR(24), \
		`ip` VARCHAR(18), \
		`date` VARCHAR(10), \
		`time` VARCHAR(10), \
		`reason` VARCHAR(32), \
		`gpci` VARCHAR("#MAX_GPCI_LEN"), \
		PRIMARY KEY(`id`), \
		UNIQUE KEY `name` (`name`))";
	mysql_query(g_SQL, string);

	string = "CREATE TABLE IF NOT EXISTS "#TABLE_MAPSPAWNS"(\
		`id` INT NOT NULL AUTO_INCREMENT, \
		`mapid` INT DEFAULT '0', \
		`posx` FLOAT DEFAULT '0.0', \
		`posy` FLOAT DEFAULT '0.0', \
		`posz` FLOAT DEFAULT '0.0', \
		`posa` FLOAT DEFAULT '0.0', \
		`team` INT DEFAULT '0', \
		PRIMARY KEY (`id`))";
	mysql_query(g_SQL, string);

	string = "CREATE TABLE IF NOT EXISTS "#TABLE_MAPS"(\
		`id` INT NOT NULL AUTO_INCREMENT, \
		`name` VARCHAR(32), \
		`min_criminals` INT DEFAULT '1', \
		`max_criminals` INT DEFAULT '1', \
		`enabled` BOOLEAN DEFAULT '1', \
		PRIMARY KEY (`id`))";
	mysql_query(g_SQL, string);

	string = "CREATE TABLE IF NOT EXISTS "#TABLE_CHARGES"(\
		`id` INT NOT NULL AUTO_INCREMENT, \
		`criminalid` INT NOT NULL, \
		`date` VARCHAR(10), \
		`time` VARCHAR(10), \
		`charge` VARCHAR("#MAX_CHARGE_LEN"), \
		PRIMARY KEY (`id`))";
	mysql_query(g_SQL, string);

	mysql_tquery(g_SQL, "SELECT * FROM "#TABLE_MAPS"", "OnServerLoadMaps");
	mysql_tquery(g_SQL, "SELECT * FROM "#TABLE_MAPSPAWNS"", "OnServerLoadMapSpawns");

	EnableVehicleFriendlyFire();
	DisableInteriorEnterExits();
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	//UsePlayerPedAnims();

	g_Timers[0] = SetTimer("OnPlayerUpdateEx", 1000, true);
	g_Timers[1] = SetTimer("OneSecondUpdate", 1000, true);

	return 1;
}

callback:OnServerLoadMaps() {
	print("[mysql debug] OnServerLoadMaps called.");
	for (new i = 0; i < cache_num_rows(); i++) {
		if(i >= MAX_MAPS) {
			printf("> There are more maps in the database than the server can handle! Loaded as much as it could. (%i/%i)", cache_num_rows(), MAX_MAPS);
			break;
		}
		
		printf("[mysql debug] MAP id %d loaded.", i);

		cache_get_value_name_int(i, "id", gm_Maps[i][SQLID]);
		cache_get_value_name(i, "name", gm_Maps[i][Name], 32);
		cache_get_value_name_int(i, "min_criminals", gm_Maps[i][MinCriminals]);
		cache_get_value_name_int(i, "max_criminals", gm_Maps[i][MaxCriminals]);
		cache_get_value_name_bool(i, "enabled", gm_Maps[i][Enabled]);

		printf("[mysql debug] MAP id %d loaded with assignments.", i);

		g_Maps ++;
	}
	printf("[mysql debug] g_Maps ended up being a count of: %d.", g_Maps);
	return 1;
}

callback:OnServerLoadMapSpawns() {
	print("[mysql debug] OnServerLoadMapSpawns called.");
	for (new i = 0; i < cache_num_rows(); i++) {		
		if(i >= MAX_MAP_SPAWNS) {
			printf("> There are more map spawns in the database than the server can handle! (%i/%i)", cache_num_rows(), MAX_MAP_SPAWNS);
			break;
		}

		//new id = i - 1;

		printf("[mysql debug] map spawn id %d loaded.", i);
		
		cache_get_value_name_int(i, "id", gm_Spawns[i][SQLID]);
		cache_get_value_name_int(i, "mapid", gm_Spawns[i][MapID]);
		cache_get_value_name_float(i, "posx", gm_Spawns[i][X]);
		cache_get_value_name_float(i, "posy", gm_Spawns[i][Y]);
		cache_get_value_name_float(i, "posz", gm_Spawns[i][Z]);
		cache_get_value_name_float(i, "posa", gm_Spawns[i][A]);
		cache_get_value_name_int(i, "team", gm_Spawns[i][Team]);

		printf("[mysql debug] map spawn id %d (sqlid: %d - should be %d)...", i, gm_Spawns[i][SQLID], i);
		printf("[mysql debug] ... assigned to map id %d.", i);
		
		Iter_Add(gm_Map_Spawns[gm_Spawns[i][MapID]], i);
	}
	return 1;
}

public OnGameModeExit() {
	mysql_close(g_SQL);

	for (new i; i < sizeof g_Timers; i++) {
		KillTimer(g_Timers[i]);
	}

	OnVCModeExit();
	//TDDestroy_Login(0, 1);

	//TDDestroy_Vcer(); // td-vcer.pwn
	return 1;
}

public OnPlayerConnect(playerid) {
	if (++p_RaceCheck[playerid] > 512) {
		p_RaceCheck[playerid] = 1;
	}
	
	PreloadAnimations(playerid);
	TogglePlayerSpectating(playerid, true);
	SetPlayerColor(playerid, COLOR_WHITE); //

	SendClientMessageToAllEx(COLOR_SERVER, "> {FFFFFF}%s has connected to the server.", GetPlayerNameEx(playerid));

	OnVCPlayerConnect(playerid); // vc.pwn
	//CreateTextdraws(playerid); // td-login.pwn

	//TDCreate_Vcer(playerid); // td-vcer.pwn
	//TDHide_Vcer(playerid); // td-vcer.pwn

	// moved to onplayerfinisheddownloading
	/*new string[150];
	mysql_format(g_SQL, string, sizeof string, "SELECT id, password, salt, lock_ip, lock_timestamp FROM "#TABLE_USERS" WHERE `name` = '%e' LIMIT 1", GetPlayerNameEx(playerid));
	mysql_pquery(g_SQL, string, "OnPlayerJoin", "i", playerid);*/

	return 1;
}

public OnPlayerRequestDownload(playerid, type, crc) {

	if (!IsPlayerDownloading[playerid]) {

		IsPlayerDownloading[playerid] = true;

		ClearPlayerChat(playerid);

		SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}Please wait while the server downloads files for you...");

		if (!strcmp(GetPlayerIpEx(playerid), "127.0.0.1")) return 1;
	}

	new
		//fullurl[256+1],
		dlfilename[64+1],
		foundfilename = 0;

	if (type == DOWNLOAD_REQUEST_TEXTURE_FILE)
		foundfilename = FindTextureFileNameFromCRC(crc, dlfilename, sizeof dlfilename);

	else if (type == DOWNLOAD_REQUEST_MODEL_FILE)
		foundfilename = FindModelFileNameFromCRC(crc, dlfilename, sizeof dlfilename);

	if (foundfilename) {
		//format(fullurl, sizeof fullurl, "%s/%s", MODEL_DOWNLOAD_URL, dlfilename);
		RedirectDownload(playerid, sprintf("%s/%s", MODEL_DOWNLOAD_URL, dlfilename));
		Log_Write("logs/download_log.txt", "[requesting download] [%s] %s (%d) redirecting download to %s/%s.",
			GetTimeEx(),
			GetPlayerNameEx(playerid),
			playerid,
			MODEL_DOWNLOAD_URL,
			dlfilename
		);
	}
	
	return 1;
}

public OnPlayerFinishedDownloading(playerid, virtualworld)
{
	IsPlayerDownloading[playerid] = false;
	
	new string[128 + MAX_GPCI_LEN];

	printf("[1] onplayerfinisheddownloading called, going through initial ban detection layer 1.");

	mysql_format(g_SQL, string, sizeof string, "SELECT * FROM "#TABLE_BANS" WHERE `name` = '%e' OR `ip` = '%s' OR `gpci` = '%e'", GetPlayerNameEx(playerid), GetPlayerIpEx(playerid), GetPlayerGPCI(playerid));
	mysql_tquery(g_SQL, string, "OnPlayerBanCheck", "ii", playerid, p_RaceCheck[playerid]);
	return 1;
}

callback:OnPlayerBanCheck(playerid, race_check) {

	if (race_check != p_RaceCheck[playerid])
		return 1;

    print("[2] onplayerbancheck called.");
    if(cache_num_rows() > 0) {
        new name[MAX_PLAYER_NAME],
            admin[MAX_PLAYER_NAME],
            ip[18],
            date[12],
            time[12],
            reason[32],
            serial[MAX_GPCI_LEN];

        cache_get_value(0, "name", name, MAX_PLAYER_NAME);
        cache_get_value(0, "admin", admin, MAX_PLAYER_NAME);
        cache_get_value(0, "ip", ip, 18);
        cache_get_value(0, "date", date, 12);
        cache_get_value(0, "time", time, 12);
        cache_get_value(0, "reason", reason, 32);
        cache_get_value(0, "gpci", serial, MAX_GPCI_LEN);

        printf("[3] rows found.");

        if(!strcmp(name, "null", true) || !name[0]) {
            Dialog_Show(playerid, DIALOG_SHOWONLY, DIALOG_STYLE_MSGBOX, "You are banned from Vice City Emergency Responders",
                ""COL_GREY"Unfortunately, you are (c2) banned from Vice City Emergency Responders! Ban Information:\n\n\
                "COL_TOMATO"Database Name: "COL_GREY"%s\n\
                "COL_TOMATO"IP: "COL_GREY"%s\n\
                "COL_TOMATO"Time and Date: "COL_GREY"%s %s\n\
                "COL_TOMATO"Banning Admin: "COL_GREY"%s\n\
                "COL_TOMATO"Ban Reason: "COL_GREY"%s\n\n\
                "COL_GREY"You may take a screenshot of this notification and use it to appeal to one of our Administrators via Discord.",
                "Okay", "",
                name, ip, time, date, admin, reason);

            printf("[4] null name found.");
        }
        else if((!strcmp(name, "null", true) || !name[0]) && (strcmp(serial, "null", true) || serial[0])) {
        	new string[256];

	        format(string, sizeof string, "AdmWarn: %s may be ban evading! (Name: %s | Admin: %s | Date: %s | Via GPCI)", 
	        	GetPlayerNameEx(playerid), name, admin, date);
	        SendAdminMessage(COLOR_YELLOW, string);

	        format(string, sizeof string, "Ban Reason: %s", reason);
	        SendAdminMessage(COLOR_YELLOW, string);

	        printf("[8] name %s found using gpci (%s)", name, serial);
	            
			mysql_format(g_SQL, string, sizeof string, "SELECT id, password, salt, lock_ip, lock_timestamp FROM "#TABLE_USERS" WHERE `name` = '%e' LIMIT 1", GetPlayerNameEx(playerid));
			mysql_pquery(g_SQL, string, "OnPlayerJoin", "ii", playerid, p_RaceCheck[playerid]);  
        }
        else {
            Dialog_Show(playerid, DIALOG_SHOWONLY, DIALOG_STYLE_MSGBOX, "You are banned from Vice City Emergency Responders",
                ""COL_GREY"Unfortunately, you are (c1) banned from Vice City Emergency Responders! Ban Information:\n\n\
                "COL_TOMATO"Database Name: "COL_GREY"%s\n\
                "COL_TOMATO"IP: "COL_GREY"%s\n\
                "COL_TOMATO"Time and Date: "COL_GREY"%s %s\n\
                "COL_TOMATO"Banning Admin: "COL_GREY"%s\n\
                "COL_TOMATO"Ban Reason: "COL_GREY"%s\n\n\
                "COL_GREY"You may take a screenshot of this notification and use it to appeal to one of our Administrators via Discord.",
                "Okay", "",
                name, ip, time, date, admin, reason);

            printf("[4] name %s found", name);
        }
        Kick(playerid);
    }
    else {
        /*printf("[5] player banned not found, calling onplayerbancheckgpci.");

        new string[256];
            
        mysql_format(g_SQL, string, sizeof string, "SELECT * FROM "#TABLE_BANS" WHERE `gpci` = '%e'", GetPlayerGPCI(playerid));
        mysql_pquery(g_SQL, string, "OnPlayerBanCheckGpci", "ii", playerid, p_RaceCheck[playerid]);*/
        printf("[9] player banned not found 100 percent, calling onplayerjoin.");

        new string[256];
            
		mysql_format(g_SQL, string, sizeof string, "SELECT id, password, salt, lock_ip, lock_timestamp FROM "#TABLE_USERS" WHERE `name` = '%e' LIMIT 1", GetPlayerNameEx(playerid));
		mysql_pquery(g_SQL, string, "OnPlayerJoin", "ii", playerid, p_RaceCheck[playerid]);    
    }
    return 1;
}

/*callback:OnPlayerBanCheckGpci(playerid, race_check) {

	if (race_check != p_RaceCheck[playerid])
		return 1;

    print("[6] onplayerbancheckgpci called.");
    if(cache_num_rows() > 0) {
        new name[MAX_PLAYER_NAME],
            admin[MAX_PLAYER_NAME],
            ip[18],
            date[12],
            time[12],
            reason[32],
            serial[MAX_GPCI_LEN],
            string[256];

        cache_get_value(0, "name", name, MAX_PLAYER_NAME);
        cache_get_value(0, "admin", admin, MAX_PLAYER_NAME);
        cache_get_value(0, "ip", ip, 18);
        cache_get_value(0, "date", date, 12);
        cache_get_value(0, "time", time, 12);
        cache_get_value(0, "reason", reason, 32);
        cache_get_value(0, "gpci", serial, MAX_GPCI_LEN);

        printf("[7] rows found.");

        format(string, sizeof string, "AdmWarn: %s may be ban evading! (Name: %s | Admin: %s | Date: %s | Via GPCI)", 
        	GetPlayerNameEx(playerid), name, admin, date);
        SendAdminMessage(COLOR_YELLOW, string);

        format(string, sizeof string, "Ban Reason: %s", reason);
        SendAdminMessage(COLOR_YELLOW, string);

        printf("[8] name %s found using gpci (%s)", name, serial);

		mysql_format(g_SQL, string, sizeof string, "SELECT id, password, salt, lock_ip, lock_timestamp FROM "#TABLE_USERS" WHERE `name` = '%e' LIMIT 1", GetPlayerNameEx(playerid));
		mysql_pquery(g_SQL, string, "OnPlayerJoin", "ii", playerid, p_RaceCheck[playerid]);
    }
    else {
        printf("[9] player banned not found 100 percent, calling onplayerjoin.");

        new string[256];
            
		mysql_format(g_SQL, string, sizeof string, "SELECT id, password, salt, lock_ip, lock_timestamp FROM "#TABLE_USERS" WHERE `name` = '%e' LIMIT 1", GetPlayerNameEx(playerid));
		mysql_pquery(g_SQL, string, "OnPlayerJoin", "ii", playerid, p_RaceCheck[playerid]);      
    }
    return 1;
}*/

public OnPlayerDisconnect(playerid, reason) {
	
	//Log_Init(LOG_TYPE_DISCONNECT, playerid, "%s has disconnected from the server.", GetPlayerNameEx(playerid));
	SaveAccount(playerid);

	new DisconnectReason[3][] = {
		"Timeout/Crashed",
		"Quit",
		"Kick/Ban"
	};

	SendClientMessageToAllEx(COLOR_SERVER, "> {FFFFFF}%s has left Vice City Emergency Responders. (%s)",
		GetPlayerNameEx(playerid),
		DisconnectReason[reason]);

	if (Iter_Contains(gm_Criminals, playerid)) {
		EndGame();
		KillTimer(g_Timers[2]);

		SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}The criminal, %s, has disconnected meaning the Responders have won!",
			GetPlayerNameEx(playerid));

		foreach (new i : gm_Players) {
			if (Iter_Contains(gm_Responders, i)) {
				eUser[i][e_USER_WINS]++;
			}
		}

		eUser[playerid][e_USER_LOSSES]++;
	}

	if (Iter_Count(gm_Responders) < 2 && gm_State == InProgress) {
		EndGame();
		KillTimer(g_Timers[2]);

		SendClientMessageToAll(COLOR_GREEN, "> {FFFFFF}There are not enough Responders, therefore nobody won!");
	}

	Iter_Remove(gm_Players, playerid);
	eUser[playerid][e_Packet] = 0.0;

	//TDDestroy_Login(playerid, 0);
	return 1;
}

public OnPlayerRequestClass(playerid, classid) {
	
	if (!eUser[playerid][e_USER_LOGGEDIN]) return 1;

	/*SetPlayerPos(playerid, -314.7314, 1052.8170, 20.3403);
	SetPlayerFacingAngle(playerid, 357.8575);
	SetPlayerCameraPos(playerid, -312.2127, 1055.5232, 20.5785);
	SetPlayerCameraLookAt(playerid, -313.0236, 1054.9427, 20.5334, CAMERA_MOVE);*/
	
	/*SetPlayerPos(playerid, 5232.4399,- 2228.6245, 11.5385);
	SetPlayerFacingAngle(playerid, 258.0844);

	SetPlayerCameraPos(playerid, 5234.3262, -2231.9744, 11.2885);
	SetPlayerCameraLookAt(playerid, 5232.4399,- 2228.6245, 11.5385, CAMERA_MOVE);*/
	
	return 1;
}

public OnPlayerRequestSpawn(playerid) {
	
	if (!eUser[playerid][e_USER_LOGGEDIN]) {
		return GameTextForPlayer(playerid, "~n~~n~~n~~n~~r~Login/Register first before spawning!", 3000, 3), 0;
	}
	return 1;
}

public OnPlayerSpawn(playerid) {
	
	IsPlayerSpawned[playerid] = true;
	StopAudioStreamForPlayer(playerid);
	//SetPlayerPos(playerid, -314.7314, 1052.8170, 20.3403);
	//SetPlayerFacingAngle(playerid, 357.8575);

	//SetPlayerPos(playerid, 5232.4399,- 2228.6245, 11.5385);
	//SetPlayerFacingAngle(playerid, 258.0844);

	if (eUser[playerid][e_USER_LOBBY] == Main) {
		if(!Iter_Contains(gm_Players, playerid))  {
			Iter_Add(gm_Players, playerid);
			SendClientMessage(playerid, -1, "[debug] added to gm_Players! (onplayerspawn)");
		}
	}

	/*if (gm_State == Waiting) {
		new count;
		foreach (new i : gm_Players) count++;

		if (count >= PLAYERS_TO_START) StartGame();
		else SendClientMessageToAllEx(COLOR_DEFAULT, "SERVER: {FFFFFF}We need %d more %s to start the game.", PLAYERS_TO_START-count, (PLAYERS_TO_START-count == 1) ? ("player") : ("players"));
	}*/
	return 1;
}

/*
enum e_GM_VEHICLES
{
	// global
	bool:InGame,
	e_GM_TEAMS:Type,
	float:MaxHealth,

	// responders
	Siren,
	GunRack1[e_GM_WEAPONS],
	GunRack2[e_GM_WEAPONS],
	Trunk1[e_GM_WEAPONS],
	Trunk2[e_GM_WEAPONS],
}
*/

enum e_GM_TEMPVEHSPAWNS {
	Float:X,
	Float:Y,
	Float:Z,
	Float:R
};

new gm_TempVehSpawns[][e_GM_TEMPVEHSPAWNS] = {
	{5478.9829, -467.9077, 10.7988, 90.0},
	{5458.7871, -389.1929, 10.7557, 270.0},
	{5538.5864, -481.7362, 10.1042, 0.0},
	{5529.7842, -334.9284, 10.1016, 180.0},
	{5520.3916, -296.7488, 10.2581, 270.0},
	{5374.3560, -294.7873, 10.1709, 180.0}
};

callback:StartGame()
{
	printf("[debug] startgame called.");

	gm_State = InProgress;
	printf("[debug] gm state set to inprogress.");

	KillTimer(g_Timers[3]);
	printf("[debug] 3 timers killed.");

	foreach (new i : gm_Players) {
		printf("[debug] checking if playerid %d (%s) is logged in.", i, GetPlayerNameEx(i));
		if (!eUser[i][e_USER_LOGGEDIN]) {
			printf("[debug] checking if playerid %d (%s) is not logged in.", i, GetPlayerNameEx(i));
			continue;
		}
		printf("[debug] playerid %d (%s) is logged in. [GOOD]", i, GetPlayerNameEx(i));

		printf("[debug] checking if playerid %d (%s) is in freeroam.", i, GetPlayerNameEx(i));
		if (eUser[i][e_USER_LOBBY] == Freeroam) {
			printf("[debug] playerid %d (%s) is in freeroam. [GOOD]", i, GetPlayerNameEx(i));
			continue;
		} 
		printf("[debug] playerid %d (%s) is not in freeroam. [GOOD]", i, GetPlayerNameEx(i));

		Iter_Add(gm_SelectionPool, i);
		printf("[debug] playerid %d (%s) added to selection pool. [GOOD]", i, GetPlayerNameEx(i));
		Iter_Add(gm_CurrPlayers, i);
		printf("[debug] playerid %d (%s) added to CurrPlayers pool.", i, GetPlayerNameEx(i));
	}

	/*	
		Beta Spawn Code
	*/

	new crim_vehid;
		//random_map = Iter_Random(gm_Maps);

	foreach (new i : gm_Map_Spawns[gm_Spawns[i][MapID]]) {
		printf("[debug] map id %d selected.", gm_Spawns[i][MapID]);
		Iter_Add(gm_VehiclePool, i);
		printf("[debug] %d added to the vehicle pool.", i);
		printf("[debug] map spawn %d selected.", i);

		if (gm_Spawns[i][Team] == PLAYER_TEAM_CRIMINAL) {
			crim_vehid = CreateVehicle(542, gm_Spawns[i][X], gm_Spawns[i][Y], gm_Spawns[i][Z], gm_Spawns[i][A], 1, 1, -1, 0);
			SetPlayerPos(criminal, gm_Spawns[i][X], gm_Spawns[i][Y], gm_Spawns[i][Z] + 5.0);
			printf("[debug] map spawn id %d loaded for player.", i);
		}
	}

	criminal = Iter_Random(gm_SelectionPool);
	Iter_Remove(gm_SelectionPool, criminal);
	Iter_Add(gm_Criminals, criminal);

	printf("[debug] %d selected as criminal.", criminal);

	SetPlayerTeam(criminal, PLAYER_TEAM_CRIMINAL);

	printf("[debug] criminal %d's team set to %d (should be 1)", PLAYER_TEAM_CRIMINAL);

	SetPlayerInterior(criminal, 0);
	SetPlayerVirtualWorld(criminal, 0);

	TogglePlayerControllable(criminal, false);

	SetTimerEx("freeze", 600, false, "d", criminal);

	gm_TempInfo[criminal][VehicleID] = crim_vehid;

	printf("[debug] criminal %d's vehicle id is %d.", criminal, crim_vehid);

	gm_VehicleData[crim_vehid][InGame] = true;
	gm_VehicleData[crim_vehid][Type] = PLAYER_TEAM_CRIMINAL;
	gm_VehicleData[crim_vehid][MaxHealth] = 1000.0;

	SetTimerEx("criminalweapons", CRIMINAL_WEAPON_TIMER, false, "d", criminal);

	PutPlayerInVehicle(criminal, crim_vehid, 0);

	printf("[debug] criminal %d placed into vehicle %d.", criminal, crim_vehid);

	new temp_vehid,
		vehspawn,
		selected,
		charge[MAX_CHARGE_LEN],
		string[144 + MAX_CHARGE_LEN];
		//selection_count = Iter_Count(gm_SelectionPool);

	switch(random(12)) {
		case 0: charge = "Attempted Murder";
		case 1: charge = "Vehicular Murder";
		case 2: charge = "Burglary";
		case 3: charge = "Hit and Run";
		case 4: charge = "Prisoner Breakout";
		case 5: charge = "Eluding a Peace Officer";
		case 6: charge = "Driving with a Suspended License";
		case 7: charge = "Driving without a License";
		case 8: charge = "Driving without Insurance";
		case 9: charge = "Disturbing the Peace";
		case 10: charge = "Possession of a Unlicensed Firearm";
		case 11: charge = "Driving Under the Influence";
		case 12: charge = "Failure to Identify to a Peace Officer";
	}

	mysql_format(g_SQL, string, sizeof string, "INSERT INTO "#TABLE_CHARGES"(`criminalid`, `date`, `time`, `charge`) \
		VALUES('%d', '%s', '%s', '%e')", eUser[criminal][e_USER_SQLID], GetDateEx(), GetTimeEx(), charge);
	mysql_pquery(g_SQL, string);

	SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}%s has been selected as the Criminal, they have %d minutes to escape!",
		GetPlayerNameEx(criminal),
		((MAX_GAME_TIME / 1000) / 60)
	);

	foreach (new i : gm_SelectionPool) {
		vehspawn = Iter_Random(gm_VehiclePool);
		Iter_Remove(gm_VehiclePool, vehspawn);

		printf("[debug] everyone else's interior set.");

		SetPlayerInterior(selected, 0);
		SetPlayerVirtualWorld(selected, 0);

		SetPlayerPos(selected, gm_TempVehSpawns[vehspawn][X], gm_TempVehSpawns[vehspawn][Y], gm_TempVehSpawns[vehspawn][Z]+5.0);
		TogglePlayerControllable(selected, false);

		SetTimerEx("freeze", 600, false, "d", selected);

		/*temp_vehid = CreateVehicle(597,
			gm_TempVehSpawns[vehspawn][X],
			gm_TempVehSpawns[vehspawn][Y],
			gm_TempVehSpawns[vehspawn][Z],
			gm_TempVehSpawns[vehspawn][R],
			1, 0, -1, 1);*/

		selected = Iter_Random(gm_SelectionPool);
		Iter_Remove(gm_SelectionPool, selected);
		Iter_Add(gm_Responders, selected);

		printf("[debug] selected responder: %d", selected);

		gm_TempInfo[selected][VehicleID] = temp_vehid;

		gm_VehicleData[temp_vehid][InGame] = true;
		gm_VehicleData[temp_vehid][Type] = PLAYER_TEAM_RESPONDER;
		gm_VehicleData[temp_vehid][MaxHealth] = 1000.0;

		gm_VehicleData[temp_vehid][GunRack1][WeaponID] = 25;
		gm_VehicleData[temp_vehid][GunRack1][Ammo] = 50;
		gm_VehicleData[temp_vehid][GunRack1][Specialty] = Lethal;
		gm_VehicleData[temp_vehid][GunRack2][WeaponID] = 31;
		gm_VehicleData[temp_vehid][GunRack2][Ammo] = 150;
		gm_VehicleData[temp_vehid][GunRack2][Specialty] = Lethal;

		gm_VehicleData[temp_vehid][Trunk1][WeaponID] = 25;
		gm_VehicleData[temp_vehid][Trunk1][Ammo] = 50;
		gm_VehicleData[temp_vehid][Trunk1][Specialty] = Lethal;
		gm_VehicleData[temp_vehid][Trunk2][WeaponID] = 31;
		gm_VehicleData[temp_vehid][Trunk2][Ammo] = 150;
		gm_VehicleData[temp_vehid][Trunk2][Specialty] = Lethal;

		PutPlayerInVehicle(selected, temp_vehid, 0);
		SetPlayerTeam(selected, PLAYER_TEAM_RESPONDER);

		printf("[debug] responder %d placed in vehicle %d, team id set to %d (should be 2).", selected, temp_vehid, PLAYER_TEAM_RESPONDER);
	}

	g_Timers[2] = SetTimer("GameTimerEnd", MAX_GAME_TIME, false);

	SendClientMessageEx(selected, COLOR_GREEN,
		"> {FFFFFF}The criminal, %s, has been charged with: %s.",
		GetPlayerNameEx(criminal),
		charge
	);

	SendClientMessage(selected, COLOR_GREEN,
		"> {FFFFFF}You are able to grab a weapon of your choice using /trunk.");

	SendClientMessage(selected, COLOR_GREEN,
		"> {FFFFFF}You are also able to use /mdc to view the criminals previous charges!");

	SendClientMessageEx(criminal, COLOR_GREEN,
		"> {FFFFFF}You will be given weapons after %d seconds, when the timer is complete.",
		(CRIMINAL_WEAPON_TIMER / 1000)
	);

	SetPlayerMarkerForPlayer(criminal, selected, 0xFF0000);

	/*
		Old Spawn Code
	*/
	/*for(new i; i < sizeof gm_TempVehSpawns[]; i++) Iter_Add(gm_VehiclePool, i);

	criminal = Iter_Random(gm_SelectionPool);
	Iter_Remove(gm_SelectionPool, criminal);
	Iter_Add(gm_Criminals, criminal);

	SetPlayerTeam(criminal, PLAYER_TEAM_CRIMINAL);

	SetPlayerInterior(criminal, 0);
	SetPlayerVirtualWorld(criminal, 0);

	SetPlayerPos(criminal, 5481.8599, -426.5546, 10.8404+5.0);
	TogglePlayerControllable(criminal, false);

	SetTimerEx("freeze", 600, false, "d", criminal);

	new crim_vehid = CreateVehicle(542, 5481.8599, -426.5546, 10.8404, 134.8043, 1, 1, -1, 0);

	gm_TempInfo[criminal][VehicleID] = crim_vehid;

	gm_VehicleData[crim_vehid][InGame] = true;
	gm_VehicleData[crim_vehid][Type] = PLAYER_TEAM_CRIMINAL;
	gm_VehicleData[crim_vehid][MaxHealth] = 1000.0;

	SetTimerEx("criminalweapons", CRIMINAL_WEAPON_TIMER, false, "d", criminal);

	PutPlayerInVehicle(criminal, crim_vehid, 0);

	new
		temp_vehid,
		vehspawn,
		selected,
		selection_count = Iter_Count(gm_SelectionPool);

	SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}%s has been selected as the Criminal, they have %d minutes to escape!",
		GetPlayerNameEx(criminal),
		((MAX_GAME_TIME / 1000) / 60)
	);

	for(new i; i < selection_count; i++)
	{
		vehspawn = Iter_Random(gm_VehiclePool);
		Iter_Remove(gm_VehiclePool, vehspawn);

		SetPlayerInterior(selected, 0);
		SetPlayerVirtualWorld(selected, 0);

		SetPlayerPos(selected, gm_TempVehSpawns[vehspawn][X], gm_TempVehSpawns[vehspawn][Y], gm_TempVehSpawns[vehspawn][Z]+5.0);
		TogglePlayerControllable(selected, false);

		SetTimerEx("freeze", 600, false, "d", selected);

		temp_vehid = CreateVehicle(597,
			gm_TempVehSpawns[vehspawn][X],
			gm_TempVehSpawns[vehspawn][Y],
			gm_TempVehSpawns[vehspawn][Z],
			gm_TempVehSpawns[vehspawn][R],
			1, 0, -1, 1);

		selected = Iter_Random(gm_SelectionPool);
		Iter_Remove(gm_SelectionPool, selected);
		Iter_Add(gm_Responders, selected);

		gm_TempInfo[selected][VehicleID] = temp_vehid;

		gm_VehicleData[temp_vehid][InGame] = true;
		gm_VehicleData[temp_vehid][Type] = PLAYER_TEAM_RESPONDER;
		gm_VehicleData[temp_vehid][MaxHealth] = 1000.0;

		gm_VehicleData[temp_vehid][GunRack1][WeaponID] = 25;
		gm_VehicleData[temp_vehid][GunRack1][Ammo] = 50;
		gm_VehicleData[temp_vehid][GunRack1][Specialty] = Lethal;
		gm_VehicleData[temp_vehid][GunRack2][WeaponID] = 31;
		gm_VehicleData[temp_vehid][GunRack2][Ammo] = 150;
		gm_VehicleData[temp_vehid][GunRack2][Specialty] = Lethal;

		gm_VehicleData[temp_vehid][Trunk1][WeaponID] = 25;
		gm_VehicleData[temp_vehid][Trunk1][Ammo] = 50;
		gm_VehicleData[temp_vehid][Trunk1][Specialty] = Lethal;
		gm_VehicleData[temp_vehid][Trunk2][WeaponID] = 31;
		gm_VehicleData[temp_vehid][Trunk2][Ammo] = 150;
		gm_VehicleData[temp_vehid][Trunk2][Specialty] = Lethal;

		PutPlayerInVehicle(selected, temp_vehid, 0);
		SetPlayerTeam(selected, PLAYER_TEAM_RESPONDER);
	}

	foreach (new i : gm_Players) SetPlayerMarkerForPlayer(criminal, selected, 0xFF0000);

	g_Timers[2] = SetTimer("GameTimerEnd", MAX_GAME_TIME, false);

	SendClientMessage(selected, COLOR_GREEN,
		"> {FFFFFF}You are able to grab a weapon of your choice using /trunk.");

	SendClientMessageEx(criminal, COLOR_GREEN,
		"> {FFFFFF}You will be given weapons after %d seconds, when the timer is complete.",
		(CRIMINAL_WEAPON_TIMER / 1000)
	);*/

	return 1;
}

callback:EndGame()
{
	printf("[debug] endgame called.");

	gm_State = Ending;
	g_Timers[3] = SetTimer("PlayerChecker", PLAYER_CHECK_TIMER, true);

	for(new i; i < sizeof gm_TempVehSpawns[]; i++)
		Iter_Remove(gm_VehiclePool, i);

	foreach (new i : gm_Players)
	{
		if (Iter_Contains(gm_Responders, i)) Iter_Remove(gm_Responders, i);
		if (Iter_Contains(gm_Criminals, i)) Iter_Remove(gm_Criminals, i);

		Iter_Remove(gm_SelectionPool, i);
		Iter_Remove(gm_CurrPlayers, i);

		if (!Iter_Contains(gm_Players, i))  {
			Iter_Add(gm_Players, i);
			SendClientMessage(i, -1, "[debug] added to gm_Players! (endgame)");
		}

		if (IsPlayerInAnyVehicle(i)) RemovePlayerFromVehicle(i);
		if (gm_TempInfo[i][VehicleID] != INVALID_VEHICLE_ID) DestroyVehicle(gm_TempInfo[i][VehicleID]);

		SetPlayerMarkerForPlayer(i, i, 0xFFFFFF00);

		SetPlayerPos(i, 246.783996, 64.2, 1003.640625);
		SetPlayerInterior(i, 6);
		SetPlayerVirtualWorld(i, 0);

		ResetPlayerWeapons(i);
		SetPlayerTeam(i, PLAYER_TEAM_LOBBY);
	}

	gm_State = Lobby;
}

callback:GameTimerEnd()
{
	EndGame();
	SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}%s has managed to escape the Responders!", GetPlayerNameEx(criminal));

	return 1;
}

callback:freeze(playerid) {
	TogglePlayerControllable(playerid, true);
	return 1;
}

GetPlayerNameEx(playerid) {
	new name[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	return name;
}

GetPlayerGPCI(playerid) {
	new szgpci[MAX_GPCI_LEN];
	gpci(playerid, szgpci, sizeof szgpci);
	return szgpci;
}

GetPlayerNamePoss(playerid) {
	new playerName[MAX_PLAYER_NAME], len;
	strcat(playerName, GetPlayerNameEx(playerid));
	len = (strlen(playerName) - 1);

	if (playerName[len] == 's' || playerName[len] == 'z') {
		strcat(playerName, "'");
	}
	else {
		strcat(playerName, "'s");
	}
	return playerName;
}

GetWeaponNameEx(weaponid)
{
	new gunname[32];
	GetWeaponName(weaponid, gunname, sizeof gunname);
	return gunname;
}

SendAdminMessage(color, string[]) {
	
	foreach (new i : Player) {
		if (eUser[i][e_USER_ADMIN_LEVEL] > 0 && eToggle[i][e_SC] == 0) {
			SendClientMessage(i, color, string);
		}
	}
	return 1;
}

SendDonatorMessage(color, string[])
{
	foreach (new i : Player)
	{
		if ((eUser[i][e_USER_VIP_LEVEL] > 0 || eUser[i][e_USER_ADMIN_LEVEL] > 3) && eToggle[i][e_DC] == 0)
		{
			SendClientMessage(i, color, string);
			return 1;
		}
	}
	return 0;
}

GetPlayerAdminRank(playerid)
{
	new str[15] = "None";
	switch (eUser[playerid][e_USER_ADMIN_LEVEL]) {
		case 0: str = "Player";
		case 1: str = "Moderator";
		case 2: str = "Administrator";
		case 3: str = "Developer";
		case 4: str = "Manager";
	}
	return str;
}

GetPlayerDonatorRank(playerid)
{
	new str[15] = "None";
	switch (eUser[playerid][e_USER_VIP_LEVEL]) {
		case 0: str = "Player";
		case 1: str = "Basic";
		case 2: str = "Premium";
	}
	return str;
}

SendClientMessageEx(playerid, color, const text[], {Float, _}:...)
{
	static
		args,
		str[144];

	/*
	 *  Custom function that uses #emit to format variables into a string.
	 *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 3)
	{
		SendClientMessage(playerid, color, text);
	}
	else
	{
		while (--args >= 3)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit PUSH.S 8
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessage(playerid, color, str);

		#emit RETN
	}
	return 1;
}

SendClientMessageToAllEx(color, const text[], {Float, _}:...)
{
	static
		args,
		str[144];

	/*
	 *  Custom function that uses #emit to format variables into a string.
	 *  This code is very fragile; touching any code here will cause crashing!
	*/
	if ((args = numargs()) == 2)
	{
		SendClientMessageToAll(color, text);
	}
	else
	{
		while (--args >= 2)
		{
			#emit LCTRL 5
			#emit LOAD.alt args
			#emit SHL.C.alt 2
			#emit ADD.C 12
			#emit ADD
			#emit LOAD.I
			#emit PUSH.pri
		}
		#emit PUSH.S text
		#emit PUSH.C 144
		#emit PUSH.C str
		#emit LOAD.S.pri 8
		#emit ADD.C 4
		#emit PUSH.pri
		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		SendClientMessageToAll(color, str);

		#emit RETN
	}
	return 1;
}

SendNearbyMessage(playerid, Float:radius, color, const str[], {Float,_}:...)
{
	static
		args,
		start,
		end,
		string[144];
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	if (args > 16)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

		for (end = start + (args - 16); end > start; end -= 4)
		{
			#emit LREF.pri end
			#emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 144
		#emit PUSH.C string

		#emit LOAD.S.pri 8
		#emit CONST.alt 4
		#emit SUB
		#emit PUSH.pri

		#emit SYSREQ.C format
		#emit LCTRL 5
		#emit SCTRL 4

		foreach (new i : Player)
		{
			if (IsPlayerNearPlayer(i, playerid, radius)) {
				SendClientMessage(i, color, string);
			}
		}
		return 1;
	}
	foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, radius)) {
			SendClientMessage(i, color, str);
		}
	}
	return 1;
}

SendBMessage(playerid, color, string[])
{
	foreach (new i : Player)
	{
		if (IsPlayerNearPlayer(i, playerid, 15.0) && eToggle[i][e_B] == 0)
		{
			SendClientMessage(i, color, string);
			return 1;
		}
	}
	return 0;
}

SendOOCMessage(color, string[])
{
	foreach (new i : Player)
	{
		if (eToggle[i][e_Global] == 0)
		{
			SendClientMessage(i, color, string);
			return 1;
		}
	}
	return 0;
}

IsPlayerNearPlayer(playerid, targetid, Float:radius)
{
	static
		Float:fX,
		Float:fY,
		Float:fZ;

	GetPlayerPos(targetid, fX, fY, fZ);

	return (GetPlayerInterior(playerid) == GetPlayerInterior(targetid) && GetPlayerVirtualWorld(playerid) == GetPlayerVirtualWorld(targetid)) && IsPlayerInRangeOfPoint(playerid, radius, fX, fY, fZ);
}

SetPlayerChatBubbleEx(playerid, color, string[])
{
	return SetPlayerChatBubble(playerid, string, color, 6.0, 6000);
}

SaveAccount(playerid)
{
	if (eUser[playerid][e_USER_LOGGEDIN])
	{
		new string[1024];

		mysql_format(g_SQL, string, sizeof string, "UPDATE "#TABLE_USERS" SET `name` = '%e', `password` = '%e', `salt` = '%e', \
			`kills` = %i, `deaths` = %i, `score` = %i, `money` = %i, `adminlevel` = %i, `viplevel` = %i, \
			`gpci` = '%e', `wins` = %i, `losses` = %i, `streamerlevel` = %i WHERE `id` = %i",
			GetPlayerNameEx(playerid),
			eUser[playerid][e_USER_PASSWORD],
			eUser[playerid][e_USER_SALT],
			eUser[playerid][e_USER_KILLS],
			eUser[playerid][e_USER_DEATHS],
			GetPlayerScore(playerid),
			GetPlayerMoney(playerid),
			eUser[playerid][e_USER_ADMIN_LEVEL],
			eUser[playerid][e_USER_VIP_LEVEL],
			GetPlayerGPCI(playerid),
			eUser[playerid][e_USER_WINS],
			eUser[playerid][e_USER_LOSSES],
			eUser[playerid][e_USER_STREAMER_LEVEL],
			eUser[playerid][e_USER_SQLID]
		);
		mysql_pquery(g_SQL, string);

		eToggle[playerid][e_PM] = false;
		eToggle[playerid][e_SC] = false;
		eToggle[playerid][e_B] = false;
		LegShots[playerid] = 0;
	}
	return 1;
}

/*callback:InitializeScript(playerid) { // Commented by Gravityfalls and Infinity
	new count;
	for(new i; i < 50; i++)
		SendClientMessage(playerid, COLOR_WHITE, "");

	foreach (new i : Player)
	{
		count++;
		if (count >= PLAYERS_TO_START) g_Timers[3] = SetTimer("PlayerChecker", PLAYER_CHECK_TIMER, true);
	}

	SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have connected to Vice City Emergency Responders!");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);

	PlayAudioStreamForPlayer(playerid, "https://vcer.infinityy.pw/audio/login.mp3");
	//spectating

	SetPlayerColor(playerid, COLOR_WHITE);

	new string[150];

	if (cache_num_rows() > 0) {
		iLoginAttempts[playerid] = 0;
		iAnswerAttempts[playerid] = 0;

		cache_get_value_name_int(0, "id", eUser[playerid][e_USER_SQLID]);
		cache_get_value_name(0, "password", eUser[playerid][e_USER_PASSWORD], 64);
		cache_get_value_name(0, "salt", eUser[playerid][e_USER_SALT], 64);
		cache_get_value_name(0, "gpci", eUser[playerid][e_USER_GPCI], MAX_GPCI_LEN);
		eUser[playerid][e_USER_SALT][64] = EOS;
		cache_get_value_name_int(0, "kills", eUser[playerid][e_USER_KILLS]);
		cache_get_value_name_int(0, "deaths", eUser[playerid][e_USER_DEATHS]);
		cache_get_value_name_int(0, "score", eUser[playerid][e_USER_SCORE]);
		cache_get_value_name_int(0, "money", eUser[playerid][e_USER_MONEY]);
		cache_get_value_name_int(0, "adminlevel", eUser[playerid][e_USER_ADMIN_LEVEL]);
		cache_get_value_name_int(0, "viplevel", eUser[playerid][e_USER_VIP_LEVEL]);
		cache_get_value_name_int(0, "register_timestamp", eUser[playerid][e_USER_REGISTER_TIMESTAMP]);
		cache_get_value_name_int(0, "lastlogin_timestamp", eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP]);
		cache_get_value_name_int(0, "wins", eUser[playerid][e_USER_WINS]);
		cache_get_value_name_int(0, "losses", eUser[playerid][e_USER_WINS]);
		cache_unset_active();
	}
	else
	{
		eUser[playerid][e_USER_SQLID] = -1;
		eUser[playerid][e_USER_PASSWORD][0] = EOS;
		eUser[playerid][e_USER_SALT][0] = EOS;
		eUser[playerid][e_USER_KILLS] = 0;
		eUser[playerid][e_USER_DEATHS] = 0;
		eUser[playerid][e_USER_SCORE] = 0;
		eUser[playerid][e_USER_MONEY] = 0;
		eUser[playerid][e_USER_ADMIN_LEVEL] = 0;
		eUser[playerid][e_USER_VIP_LEVEL] = 0;
		eUser[playerid][e_USER_REGISTER_TIMESTAMP] = 0;
		eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP] = 0;
		eUser[playerid][e_USER_WINS] = 0;
		eUser[playerid][e_USER_LOSSES] = 0;
		//eUser[playerid][e_USER_SECURITY_QUESTION][0] = EOS;
		//eUser[playerid][e_USER_SECURITY_ANSWER][0] = EOS;

		ShowRegisterDialog(playerid, 0);
	}
	return 1;
}*/

callback:OnPlayerJoin(playerid, race_check) {

	if (race_check != p_RaceCheck[playerid])
		return 1;

	printf("[10] onplayerjoin called.");
	printf("[10] ban check successful!");

	if (IsPlayerDownloading[playerid] == true) return 1;

	if (cache_num_rows())
	{
		iLoginAttempts[playerid] = 0;
		iAnswerAttempts[playerid] = 0;

		cache_get_value_name_int(0, "id", eUser[playerid][e_USER_SQLID]);
		cache_get_value_name(0, "password", eUser[playerid][e_USER_PASSWORD]);
		cache_get_value_name(0, "salt", eUser[playerid][e_USER_SALT]);

		new ip[18], timestamp;
		cache_get_value_name(0, "lock_ip", ip);
		cache_get_value_name_int(0, "lock_timestamp", timestamp);

		if (((gettime() - timestamp) < 0) && (!strcmp(GetPlayerIpEx(playerid), ip)))
		{
			new string[128];
			SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}You have been blocked due to too many login attempts.");
			format(string, sizeof string, "> {FFFFFF}You will be able to try again in %s.", ReturnTimelapse(gettime(), timestamp));
			SendClientMessage(playerid, COLOR_TOMATO, string);

			Kick(playerid);
		}

		PlayAudioStreamForPlayer(playerid, LOGIN_MUSIC_URL);
		ShowLoginDialog(playerid);
	}
	else
	{
		PlayAudioStreamForPlayer(playerid, LOGIN_MUSIC_URL);
		ShowRegisterDialog(playerid);
	}
	return 1;
}

callback:OnPlayerLogin(playerid)
{
	cache_get_value_name(0, "gpci", eUser[playerid][e_USER_GPCI], MAX_GPCI_LEN);
	cache_get_value_name_int(0, "kills", eUser[playerid][e_USER_KILLS]);
	cache_get_value_name_int(0, "deaths", eUser[playerid][e_USER_DEATHS]);
	cache_get_value_name_int(0, "score", eUser[playerid][e_USER_SCORE]);
	cache_get_value_name_int(0, "money", eUser[playerid][e_USER_MONEY]);
	cache_get_value_name_int(0, "adminlevel", eUser[playerid][e_USER_ADMIN_LEVEL]);
	cache_get_value_name_int(0, "viplevel", eUser[playerid][e_USER_VIP_LEVEL]);
	cache_get_value_name_int(0, "streamerlevel", eUser[playerid][e_USER_STREAMER_LEVEL]);
	cache_get_value_name_int(0, "register_timestamp", eUser[playerid][e_USER_REGISTER_TIMESTAMP]);
	cache_get_value_name_int(0, "lastlogin_timestamp", eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP]);
	cache_get_value_name_int(0, "wins", eUser[playerid][e_USER_WINS]);
	cache_get_value_name_int(0, "losses", eUser[playerid][e_USER_WINS]);
	cache_unset_active();

	new string[256];
	SendClientMessage(playerid, COLOR_TOMATO, "> {FFFFFF}You have successfully logged in, welcome back to Vice City Emergency Responders!");
	SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}Last logged in: %s ago.", ReturnTimelapse(eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP], gettime()));

	mysql_format(g_SQL, string, sizeof string, "UPDATE "#TABLE_USERS" SET `lastlogin_timestamp` = %i, `ip` = '%s', `longip` = %i WHERE `id` = %i", gettime(), GetPlayerIpEx(playerid), IpToLong(GetPlayerIpEx(playerid)), eUser[playerid][e_USER_SQLID]);
	mysql_pquery(g_SQL, string);

	SetTimerEx("pingtimer", 6000, true, "i", playerid);
	ShowLobbyDialog(playerid, 0);

	return 1;
}

callback:pingtimer(playerid)
{
	if (GetPlayerPing(playerid) > MAX_PING)
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "Your ping has exceeded the limit ("#MAX_PING") and you are being kicked.");
		Kick(playerid);
	}
	return 1;
}

callback:restartsave()
{
	foreach (new i : Player)
	{
		SaveAccount(i);
	}
	SendClientMessageToAll(COLOR_TOMATO, "AdmCmd: All accounts have been saved.");
	SetTimer("restart", 5000, false);
	return 1;
}

callback:restart()
{
	SendClientMessageToAll(COLOR_TOMATO, "AdmCmd: Server restarting.");
	SendRconCommand("gmx");
	return 1;
}

public OnPlayerCommandReceived(playerid, cmd[], params[], flags)
{
	if (!eUser[playerid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_GREY, "You need to be logged in to use commands.");

	return 1;
}

public OnPlayerCommandPerformed(playerid, cmd[], params[], result, flags)
{
	//Log_Init((result == 1 ? (LOG_TYPE_COMMAND_SUCCESS) : (LOG_TYPE_COMMAND_FAILURE)), playerid, "/%s %s", cmd, params);
	if (result == -1)
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: {FFFFFF}'%s' is an invalid command, use /help for more info.", cmd);
		return 0;
	}
	return 1;
}

public OnPlayerText(playerid, text[])
{
	if (!eUser[playerid][e_USER_LOGGEDIN])
		return SendClientMessage(playerid, COLOR_GREY, "You need to be logged in to use commands."), 0;

	if (!Iter_Contains(gm_Criminals, playerid) && !Iter_Contains(gm_Responders, playerid))
		return SendClientMessage(playerid, COLOR_GREY, "You must be in a game to use the IC chat."), 0;

	if (strlen(text) > 120)
	{
		SendNearbyMessage(playerid, 15.0, COLOR_WHITE, "%s says: %s..", GetPlayerNameEx(playerid), text);
		SendNearbyMessage(playerid, 15.0, COLOR_WHITE, "%s says: ..%s", GetPlayerNameEx(playerid), text[120]);
	}
	else SendNearbyMessage(playerid, 15.0, COLOR_WHITE, "%s says: %s", GetPlayerNameEx(playerid), text);

	//Log_Init(LOG_TYPE_CHAT, playerid, "[says] %s", text);
	return 0;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart)
{
	if (GetPlayerSkin(playerid) == 285) return 1;
	switch (bodypart) {
		case BODY_PART_LEFT_LEG, BODY_PART_RIGHT_LEG: {
			if (++ LegShots[playerid] > 1) {
				LegShots[playerid] = 2;
				SendClientMessage(playerid, COLOR_YELLOW, "> You were shot in the leg, your ability to run and jump has been affected.");
			}
		}
	}
	return 1;
}

public OnUnoccupiedVehicleUpdate(vehicleid, playerid, passenger_seat, Float:new_x, Float:new_y, Float:new_z, Float:vel_x, Float:vel_y, Float:vel_z)
{
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	LegShots[playerid] = 0;

	if (Iter_Contains(gm_Criminals, playerid) && gm_State == InProgress)
	{
		EndGame();
		KillTimer(g_Timers[2]);

		SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}The criminal, %s, has lost to the Responders!", GetPlayerNameEx(playerid));

		foreach (new i : gm_Players)
		{
			if (Iter_Contains(gm_Responders, i)) eUser[i][e_USER_WINS]++;
		}

		eUser[playerid][e_USER_LOSSES]++;
	}

	if (Iter_Contains(gm_Responders, playerid) && gm_State == InProgress)
	{
		Iter_Remove(gm_Responders, playerid);

		Iter_Remove(gm_SelectionPool, playerid);
		Iter_Remove(gm_CurrPlayers, playerid);

		if (IsPlayerInAnyVehicle(playerid)) RemovePlayerFromVehicle(playerid);
		if (gm_TempInfo[playerid][VehicleID] != INVALID_VEHICLE_ID) DestroyVehicle(gm_TempInfo[playerid][VehicleID]);

		SetPlayerMarkerForPlayer(playerid, criminal, 0xFFFFFF00);

		SetPlayerPos(playerid, 246.783996, 63.900199, 1003.640625);
		SetPlayerInterior(playerid, 6);
		SetPlayerVirtualWorld(playerid, 0);

		SendClientMessageToAll(COLOR_GREEN, "> {FFFFFF}The criminal has managed to eliminate a Responder!");

		eUser[playerid][e_USER_LOSSES]++;
	}

	if (Iter_Count(gm_Responders) < 1)
	{
		EndGame();
		KillTimer(g_Timers[2]);

		SendClientMessageToAllEx(COLOR_GREEN, "> {FFFFFF}The criminal, %s, has managed to eliminate all Responders and has won!",
			GetPlayerNameEx(playerid));

		foreach (new i : gm_Players)
		{
			if (Iter_Contains(gm_Responders, i)) eUser[i][e_USER_LOSSES]++;
		}

		eUser[playerid][e_USER_WINS]++;
	}
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys) {
	if (!IsPlayerInAnyVehicle(playerid) && LegShots[playerid] == 2 && (HOLDING( KEY_SPRINT) || HOLDING(KEY_JUMP) || PRESSED( KEY_SPRINT) || PRESSED(KEY_JUMP))) {
		ApplyAnimation(playerid, "PED", "FALL_collapse", 4.1, 0, 1, 1, 0, 1100, 1);
	}

	OnVCKeyStateChange(playerid, newkeys, oldkeys);
	return 1;
}

public OnPlayerUpdate(playerid) {
	/* EMPTIED */
	return 1;
}

callback:OnPlayerUpdateEx() { // Updated by Logic_
	new
		packet, i, panels, doors, lights, tires, carid;

	foreach (new playerid : Player) {
		if (!eUser[playerid][e_USER_LOGGEDIN]) continue;

		packet = floatround(NetStats_PacketLossPercent(playerid));

		if (packet != 0 && packet != eUser[playerid][e_Packet]) {
			CallLocalFunction("OnPlayerPacketLoss", "iff", playerid, eUser[playerid][e_Packet], float(packet));
			eUser[playerid][e_Packet] = packet;
		}

		if (GetPlayerState(playerid) != PLAYER_STATE_DRIVER) {
			for (i = 0; i < sizeof gm_Spikes; i++) {

				if (IsPlayerInRangeOfPoint(playerid, 3.0, gm_Spikes[i][X], gm_Spikes[i][Y], gm_Spikes[i][Z])) {

					if (gm_Spikes[i][Existing] == 1) {

						carid = GetPlayerVehicleID(playerid);

						GetVehicleDamageStatus(carid, panels, doors, lights, tires);
						tires = encode_tires(1, 1, 1, 1);

						UpdateVehicleDamageStatus(carid, panels, doors, lights, tires);
					}
				}
			}
		}
	}

	return 1;
}

CreateSpikeStrip(playerid, Float:sX, Float:sY, Float:sZ, Float:sA) { // Updated by Logic_
	new string[64], i;

	for (i = 0; i < sizeof gm_Spikes; i++) {

		if (gm_Spikes[i][Existing] == 1) continue;

		gm_Spikes[i][Existing] = 1;
		gm_Spikes[i][X] = sX;
		gm_Spikes[i][Y] = sY;
		gm_Spikes[i][Z] = sZ-0.7;
		gm_Spikes[i][Object] = CreateDynamicObject(2899, sX, sY, sZ-0.9, 0, 0, sA-90);

		format(string, sizeof string, "Spike Strip\n"COL_BLUE"Created by: {FFFFFF}%s", GetPlayerNameEx(playerid));

		gm_Spikes[i][Text] = CreateDynamic3DTextLabel(string, COLOR_BLUE, sX, sY, sZ, 15.0, 0, 1);

		return i;
	}

	return -1;
}

DeleteClosestSpikeStrip(playerid)
{
	for(new i = 0; i < sizeof gm_Spikes; i++) {

		if (!gm_Spikes[i][Existing]) continue;
		
		if (IsPlayerInRangeOfPoint(playerid, 2.0, gm_Spikes[i][X], gm_Spikes[i][Y], gm_Spikes[i][Z])) {

			gm_Spikes[i][Existing] = 0;
			gm_Spikes[i][X] = 0.0;
			gm_Spikes[i][Y] = 0.0;
			gm_Spikes[i][Z] = 0.0;
			DestroyDynamic3DTextLabel(gm_Spikes[i][Text]);

			DestroyObject(gm_Spikes[i][Object]);
			SendClientMessage(playerid, COLOR_TOMATO, "[ ! ] {FFFFFF}You have deleted the closest spike strip to you.");
			return i;
		}
	}
	
	return -1; // Invalid spike strip
}

DeleteAllSpikeStrips()
{
	for(new i = 0; i < sizeof gm_Spikes; i++)
	{
		if (gm_Spikes[i][Existing] == 1)
		{
			gm_Spikes[i][Existing] = 0;
			gm_Spikes[i][X] = 0.0;
			gm_Spikes[i][Y] = 0.0;
			gm_Spikes[i][Z] = 0.0;
			DestroyDynamic3DTextLabel(gm_Spikes[i][Text]);

			DestroyObject(gm_Spikes[i][Object]);
			return 1;
		}
	}
	return 0;
}

randomEx(min, max)
{
	//Credits to y_less
	new rand = random(max-min)+min;
	return rand;
}

encode_tires(tires1, tires2, tires3, tires4) return tires1 | (tires2 << 1) | (tires3 << 2) | (tires4 << 3);

callback:OnPlayerPacketLoss(playerid, Float:newpacket, Float:oldpacket)
{
	if (newpacket < MAX_PACKETLOSS) return 1;

	/*if (PacketLossWarnings[playerid] >= 3)
	{
		SendClientMessageEx(playerid, COLOR_YELLOW,
			"After receiving %d warnings, you are being kicked for having packet loss issues.", PacketLossWarnings[playerid]);

		PacketLossWarnings[playerid] = 0;
		Kick(playerid);
	}
	else
	{
		SendClientMessageEx(playerid, COLOR_YELLOW,
			"You are experiencing packetloss! Please try and sort out the issue. [%d/3] (oldpackets: %.2f, newpackets: %.2f)", PacketLossWarnings[playerid], oldpacket, newpacket);
		PacketLossWarnings[playerid]++;
	}*/
	return 1;
}

/*public OnPlayerPause(playerid)
{
	eUser[playerid][e_USER_AFK] = true;
	SendClientMessageToAllEx(COLOR_TOMATO, "[ ! ] {FFFFFF}%s is now marked as AFK (tabbed).", GetPlayerNameEx(playerid));

	Iter_Remove(gm_Players, playerid);
	return 1;
}

public OnPlayerResume(playerid, time)
{
	eUser[playerid][e_USER_AFK] = false;
	SendClientMessageToAllEx(COLOR_TOMATO, "[ ! ] {FFFFFF}%s is no longer marked as AFK (tabbed) - %d minutes.", GetPlayerNameEx(playerid), time);

	Iter_Add(gm_Players, playerid);
	return 1;
}

public OnPlayerHideCursor(playerid, hovercolor)
{
	return SendClientMessage(playerid, COLOR_YELLOW, "You have cancelled textdraw selection!");
}*/

GetTimeEx()
{
	new hours, minutes, seconds, string[24];
	gettime(hours, minutes, seconds);

	format(string, sizeof string, "%d:%d:%d", hours, minutes, seconds);
	return string;
}

GetDateEx()
{
	new year, month, day, string[24];
	getdate(year, month, day);

	format(string, sizeof string, "%d/%d/%d", year, month, day);
	return string;
}

GetPlayerIpEx(playerid)
{
	new IP[24];
	GetPlayerIp(playerid, IP, sizeof IP);

	return IP;
}

/*Dialog:SEC_QUESTION(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		Dialog_Show(playerid, REGISTER, DIALOG_STYLE_PASSWORD, "Account Registeration... [Step: 1/3]", COL_WHITE "Welcome to our server. We will take you through "COL_GREEN"3 simple steps "COL_WHITE"to register your account with a backup option in case you forgot your password!\nPlease enter a password, "COL_TOMATO"case sensitivity"COL_WHITE" is on.", "Continue", "Options");
		SendClientMessage(playerid, COLOR_WHITE, "[Step: 1/3] Enter your new account's password.");
		return 1;
	}

	format(eUser[playerid][e_USER_SECURITY_QUESTION], MAX_SECURITY_QUESTION_SIZE, SECURITY_QUESTIONS[listitem]);

	new string[256];
	format(string, sizeof(string), COL_TOMATO "%s\n"COL_WHITE"Insert your answer below in the box. (don't worry about CAPS, answers are NOT case sensitive).", SECURITY_QUESTIONS[listitem]);
	Dialog_Show(playerid, SEC_ANSWER, DIALOG_STYLE_INPUT, "Account Registeration... [Step: 3/3]", string, "Confirm", "Back");
	SendClientMessage(playerid, COLOR_WHITE, "[Step: 3/3] Write the answer to your secuirty question and you'll be done :)");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
	return 1;
}

Dialog:SEC_ANSWER(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		new list[2 + (sizeof(SECURITY_QUESTIONS) * MAX_SECURITY_QUESTION_SIZE)];
		for (new i; i < sizeof(SECURITY_QUESTIONS); i++)
		{
			strcat(list, SECURITY_QUESTIONS[i]);
			strcat(list, "\n");
		}
		Dialog_Show(playerid, SEC_QUESTION, DIALOG_STYLE_LIST, "Account Registeration... [Step: 2/3]", list, "Continue", "Back");
		SendClientMessage(playerid, COLOR_WHITE, "[Step: 2/3] Select a security question. This will help you retrieve your password in case you forget it any time soon!");
		return 1;
	}

	new string[512];

	if (strlen(inputtext) < MIN_PASSWORD_LENGTH || inputtext[0] == ' ')
	{
		format(string, sizeof(string), COL_TOMATO "%s\n"COL_WHITE"Insert your answer below in the box. (don't worry about CAPS, answers are NOT case sensitive).", SECURITY_QUESTIONS[listitem]);
		Dialog_Show(playerid, SEC_ANSWER, DIALOG_STYLE_INPUT, "Account Registeration... [Step: 3/3]", string, "Confirm", "Back");
		SendClientMessage(playerid, COLOR_TOMATO, "Security answer cannot be an less than "#MIN_PASSWORD_LENGTH" characters.");
		return 1;
	}

	for (new i, j = strlen(inputtext); i < j; i++)
	{
		inputtext[i] = tolower(inputtext[i]);
	}
	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_SECURITY_ANSWER], 64);

	new name[MAX_PLAYER_NAME],
		ip[18];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, ip, 18);
	format(string, sizeof(string), "INSERT INTO "#TABLE_USERS"(`name`, `ip`, `longip`, `password`, `salt`, `sec_question`, `sec_answer`, `register_timestamp`, `lastlogin_timestamp`) VALUES('%s', '%s', %i, '%q', '%q', '%q', '%q', %i, %i)", name, ip, IpToLong(ip), eUser[playerid][e_USER_PASSWORD], eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_SECURITY_QUESTION], eUser[playerid][e_USER_SECURITY_ANSWER], gettime(), gettime());
	db_free_result(db_query(db, string));

	format(string, sizeof(string), "SELECT `id` FROM "#TABLE_USERS" WHERE `name` = '%q' LIMIT 1", name);
	new DBResult:result = db_free_result(db_query(db, string));
	eUser[playerid][e_USER_SQLID] = db_get_field_int(result, 0);
	db_free_result(result);

	format(string, sizeof(string), "Successfully registered! Welcome to our server %s, we hope you enjoy your stay. [IP: %s]", name, ip);
	SendClientMessage(playerid, COLOR_GREEN, string);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	SetPVarInt(playerid, "LoggedIn", 1);
	OnPlayerRequestClass(playerid, 0);
	return 1;
}

Dialog:OPTIONS(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		if (eUser[playerid][e_USER_SQLID] != -1)
			Dialog_Show(playerid, LOGIN, DIALOG_STYLE_PASSWORD, "Account Login...", COL_WHITE "Insert your secret password to access this account. If you failed in "COL_YELLOW""#MAX_LOGIN_ATTEMPTS" "COL_WHITE"attempts, account will be locked for "COL_YELLOW""#MAX_ACCOUNT_LOCKTIME" "COL_WHITE"minutes.", "Continue", "Options");
		else
			Dialog_Show(playerid, REGISTER, DIALOG_STYLE_PASSWORD, "Account Registeration... [Step: 1/3]", COL_WHITE "Welcome to our server. We will take you through "COL_GREEN"3 simple steps "COL_WHITE"to register your account with a backup option in case you forgot your password!\nPlease enter a password, "COL_TOMATO"case sensitivity"COL_WHITE" is on.", "Continue", "Options");
		return 1;
	}

	switch (listitem)
	{
		case 0:
		{
			if (eUser[playerid][e_USER_SQLID] == -1)
			{
				SendClientMessage(playerid, COLOR_TOMATO, "This account isn't registered, try 'Forgot Username' or change your name and connect.");
				Dialog_Show(playerid, OPTIONS, DIALOG_STYLE_LIST, "Account Options...", "Forgot password\nForgot username\nExit to desktop", "Select", "Back");
				return 1;
			}

			new string[64 + MAX_SECURITY_QUESTION_SIZE];
			format(string, sizeof(string), COL_WHITE "Answer your security question to reset password.\n\n"COL_TOMATO"%s", eUser[playerid][e_USER_SECURITY_QUESTION]);
			Dialog_Show(playerid, FORGOT_PASSWORD, DIALOG_STYLE_INPUT, "Forgot Password:", string, "Next", "Cancel");
		}
		case 1:
		{
			const MASK = (-1 << (32 - 36));
			new string[256],
				ip[18];
			GetPlayerIp(playerid, ip, 18);
			format(string, sizeof(string), "SELECT `name`, `lastlogin_timestamp` FROM "#TABLE_USERS" WHERE ((`longip` & %i) = %i) LIMIT 1", MASK, (IpToLong(ip) & MASK));
			new DBResult:result = db_free_result(db_query(db, string));
			if (db_num_rows(result) == 0)
			{
				SendClientMessage(playerid, COLOR_TOMATO, "There are no accounts realted to this ip, this seems to be your first join!");
				Dialog_Show(playerid, OPTIONS, DIALOG_STYLE_LIST, "Account Options...", "Forgot password\nForgot username\nExit to desktop", "Select", "Back");
				return 1;
			}

			new list[25 * (MAX_PLAYER_NAME + 32)],
				name[MAX_PLAYER_NAME],
				lastlogin_timestamp,
				i,
				j = ((db_num_rows(result) > 10) ? (10) : (db_num_rows(result)));

			do
			{
				db_get_field_assoc(result, "name", name, MAX_PLAYER_NAME);
				lastlogin_timestamp = db_get_field_assoc_int(result, "lastlogin_timestamp");
				format(list, sizeof(list), "%s"COL_TOMATO"%s "COL_WHITE"|| Last login: %s ago\n", list, name, ReturnTimelapse(lastlogin_timestamp, gettime()));
			}
			while (db_next_row(result) && i > j);
			db_free_result(result);

			Dialog_Show(playerid, FORGOT_USERNAME, DIALOG_STYLE_LIST, "Your username history...", list, "Ok", "");
			PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
		}
		case 2:
		{
			return Kick(playerid);
		}
	}
	return 1;
}

Dialog:FORGOT_PASSWORD(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		Dialog_Show(playerid, OPTIONS, DIALOG_STYLE_LIST, "Account Options...", "Forgot password\nForgot username\nExit to desktop", "Select", "Back");
		return 1;
	}

	new string[256],
		hash[64];
	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], hash, sizeof(hash));
	if (strcmp(hash, eUser[playerid][e_USER_SECURITY_ANSWER]))
	{
		if (++iAnswerAttempts[playerid] == MAX_LOGIN_ATTEMPTS)
		{
			new lock_timestamp = gettime() + (MAX_ACCOUNT_LOCKTIME * 60);
			new ip[18];
			GetPlayerIp(playerid, ip, 18);
			format(string, sizeof(string), "INSERT INTO `temp_blocked_users` VALUES('%s', %i, %i)", ip, lock_timestamp, eUser[playerid][e_USER_SQLID]);
			db_free_result(db_query(db, string));

			SendClientMessage(playerid, COLOR_TOMATO, "Sorry! The account has been temporarily locked on your IP. due to "#MAX_LOGIN_ATTEMPTS"/"#MAX_LOGIN_ATTEMPTS" failed login attempts.");
			format(string, sizeof(string), "If you forgot your password/username, click on 'Options' in login window next time (you may retry in %s).", ReturnTimelapse(gettime(), lock_timestamp));
			SendClientMessage(playerid, COLOR_TOMATO, string);
			return Kick(playerid);
		}

		format(string, sizeof(string), COL_WHITE "Answer your security question to reset password.\n\n"COL_TOMATO"%s", eUser[playerid][e_USER_SECURITY_QUESTION]);
		Dialog_Show(playerid, FORGOT_PASSWORD, DIALOG_STYLE_INPUT, "Forgot Password:", string, "Next", "Cancel");
		format(string, sizeof(string), "Incorrect answer! Your tries left: %i/"#MAX_LOGIN_ATTEMPTS" attempts.", iAnswerAttempts[playerid]);
		SendClientMessage(playerid, COLOR_TOMATO, string);
		return 1;
	}

	Dialog_Show(playerid, RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password:", COL_WHITE "Insert a new password for your account. Also in case you want to change security question for later, use /ucp.", "Confirm", "");
	SendClientMessage(playerid, COLOR_GREEN, "Successfully answered your security question! You shall now reset your password.");
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}

Dialog:RESET_PASSWORD(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		Dialog_Show(playerid, RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password:", COL_WHITE "Insert a new password for your account. Also in case you want to change security question for later, use /ucp.", "Confirm", "");
		return 1;
	}

	new string[256];

	if (!(MIN_PASSWORD_LENGTH <= strlen(inputtext) <= MAX_PASSWORD_LENGTH))
	{
		Dialog_Show(playerid, RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password:", COL_WHITE "Insert a new password for your account. Also in case you want to change security question for later, use /ucp.", "Confirm", "");
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
			Dialog_Show(playerid, RESET_PASSWORD, DIALOG_STYLE_PASSWORD, "Reset Password:", COL_WHITE "Insert a new password for your account. Also in case you want to change security question for later, use /ucp.", "Confirm", "");
			SendClientMessage(playerid, COLOR_TOMATO, "Password must contain atleast a Highercase, a Lowercase and a Number.");
			return 1;
		}
	#endif

	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_PASSWORD], 64);

	new name[MAX_PLAYER_NAME],
		ip[18];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	GetPlayerIp(playerid, ip, 18);
	format(string, sizeof(string), "UPDATE "#TABLE_USERS" SET `password` = '%q', `ip` = '%s', `longip` = %i, `lastlogin_timestamp` = %i WHERE `id` = %i", eUser[playerid][e_USER_PASSWORD], ip, IpToLong(ip), gettime(), eUser[playerid][e_USER_SQLID]);
	db_free_result(db_query(db, string));

	format(string, sizeof(string), "Successfully logged in with new password! Welcome back to our server %s, we hope you enjoy your stay. [Last login: %s ago]", name, ReturnTimelapse(eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP], gettime()));
	SendClientMessage(playerid, COLOR_GREEN, string);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	SetPVarInt(playerid, "LoggedIn", 1);
	OnPlayerRequestClass(playerid, 0);
	return 1;
}

Dialog:FORGOT_USERNAME(playerid, response, listitem, inputtext[])
{
	Dialog_Show(playerid, OPTIONS, DIALOG_STYLE_LIST, "Account Options...", "Forgot password\nForgot username\nExit to desktop", "Select", "Back");
	return 1;
}*/



/*CMD:changeques(playerid, params[])
{
	if (eUser[playerid][e_USER_SQLID] != 1)
	{
		SendClientMessage(playerid, COLOR_TOMATO, "Only registered users can use this command.");
		return 1;
	}

	new list[2 + (sizeof(SECURITY_QUESTIONS) * MAX_SECURITY_QUESTION_SIZE)];
	for (new i; i < sizeof(SECURITY_QUESTIONS); i++)
	{
		strcat(list, SECURITY_QUESTIONS[i]);
		strcat(list, "\n");
	}
	Dialog_Show(playerid, CHANGE_SEC_QUESTION, DIALOG_STYLE_LIST, "Change account security question... [Step: 1/2]", list, "Continue", "Cancel");
	SendClientMessage(playerid, COLOR_WHITE, "[Step: 1/2] Select a security question. This will help you retrieve your password in case you forget it any time soon!");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
	return 1;
}*/

/*Dialog:CHANGE_SEC_QUESTION(playerid, response, listitem, inputext[])
{
	if (!response)
		return 1;

	SetPVarInt(playerid, "Question", listitem);

	new string[256];
	format(string, sizeof(string), COL_YELLOW "%s\n"COL_WHITE"Insert your answer below in the box. (don't worry about CAPS, answers are NOT case sensitive).", SECURITY_QUESTIONS[listitem]);
	Dialog_Show(playerid, CHANGE_SEC_ANSWER, DIALOG_STYLE_INPUT, "Change account security question... [Step: 2/2]", string, "Confirm", "Back");
	SendClientMessage(playerid, COLOR_WHITE, "[Step: 2/2] Write the answer to your secuirty question.");
	PlayerPlaySound(playerid, 1054, 0.0, 0.0, 0.0);
	return 1;
}

Dialog:CHANGE_SEC_ANSWER(playerid, response, listitem, inputtext[])
{
	if (!response)
	{
		new list[2 + (sizeof(SECURITY_QUESTIONS) * MAX_SECURITY_QUESTION_SIZE)];
		for (new i; i < sizeof(SECURITY_QUESTIONS); i++)
		{
			strcat(list, SECURITY_QUESTIONS[i]);
			strcat(list, "\n");
		}
		Dialog_Show(playerid, CHANGE_SEC_QUESTION, DIALOG_STYLE_LIST, "Change account security question... [Step: 1/2]", list, "Continue", "Cancel");
		SendClientMessage(playerid, COLOR_WHITE, "[Step: 1/2] Select a security question. This will help you retrieve your password in case you forget it any time soon!");
		return 1;
	}

	new string[512];

	if (strlen(inputtext) < MIN_PASSWORD_LENGTH || inputtext[0] == ' ')
	{
		format(string, sizeof(string), COL_YELLOW "%s\n"COL_WHITE"Insert your answer below in the box. (don't worry about CAPS, answers are NOT case sensitive).", SECURITY_QUESTIONS[listitem]);
		Dialog_Show(playerid, CHANGE_SEC_ANSWER, DIALOG_STYLE_INPUT, "Change account security question... [Step: 2/2]", string, "Confirm", "Back");
		SendClientMessage(playerid, COLOR_TOMATO, "Security answer cannot be an less than "#MIN_PASSWORD_LENGTH" characters.");
		return 1;
	}

	format(eUser[playerid][e_USER_SECURITY_QUESTION], MAX_SECURITY_QUESTION_SIZE, SECURITY_QUESTIONS[GetPVarInt(playerid, "Question")]);
	DeletePVar(playerid, "Question");

	for (new i, j = strlen(inputtext); i < j; i++)
	{
		inputtext[i] = tolower(inputtext[i]);
	}
	SHA256_PassHash(inputtext, eUser[playerid][e_USER_SALT], eUser[playerid][e_USER_SECURITY_ANSWER], 64);
	format(string, sizeof(string), "Successfully changed your security answer and question [Q: %s].", eUser[playerid][e_USER_SECURITY_QUESTION]);
	SendClientMessage(playerid, COLOR_GREEN, string);
	PlayerPlaySound(playerid, 1057, 0.0, 0.0, 0.0);
	return 1;
}*/

/*CMD:stats(playerid, params[])
{
	new targetid;
	if (sscanf(params, "u", targetid))
	{
		targetid = playerid;
		SendClientMessage(playerid, COLOR_DEFAULT, "Tip: You can also view other players stats by /stats [player]");
	}

	if (!IsPlayerConnected(targetid))
		return SendClientMessage(playerid, COLOR_TOMATO, "The player is not connected.");

	new name[MAX_PLAYER_NAME];
	GetPlayerName(targetid, name, MAX_PLAYER_NAME);

	new string[150];
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	SendClientMessage(playerid, COLOR_GREEN, "");
	format(string, sizeof(string), "%s[%i]'s stats: (AccountId: %i)", name, targetid, eUser[targetid][e_USER_SQLID]);
	SendClientMessage(playerid, COLOR_GREEN, string);

	new Float:ratio = ((eUser[targetid][e_USER_DEATHS] < 0) ? (0.0) : (floatdiv(eUser[targetid][e_USER_KILLS], eUser[targetid][e_USER_DEATHS])));

	format(string, sizeof (string), "Score: %i || Money: $%i || Kills: %i || Deaths: %i || Ratio: %0.2f || Admin Level: %i - %s || Vip Level: %i",
		GetPlayerScore(targetid), GetPlayerMoney(targetid), eUser[targetid][e_USER_KILLS], eUser[targetid][e_USER_DEATHS], ratio, eUser[targetid][e_USER_ADMIN_LEVEL], GetPlayerAdminRank(playerid), eUser[targetid][e_USER_VIP_LEVEL]);
	SendClientMessage(playerid, COLOR_GREEN, string);

	format(string, sizeof (string), "Registaration On: %s || Last Seen: %s",
		ReturnTimelapse(eUser[playerid][e_USER_REGISTER_TIMESTAMP], gettime()), ReturnTimelapse(eUser[playerid][e_USER_LASTLOGIN_TIMESTAMP], gettime()));
	SendClientMessage(playerid, COLOR_GREEN, string);

	SendClientMessage(playerid, COLOR_GREEN, "");
	SendClientMessage(playerid, COLOR_GREEN, "_______________________________________________");
	return 1;
}*/

ClearPlayerChat(playerid = INVALID_PLAYER_ID, number = 50) {
	if (playerid == INVALID_PLAYER_ID) {
		for (; number > 0; --number) {
			SendClientMessageToAll(COLOR_WHITE, "");
		}
	}
	else {
		for (; number > 0; --number) {
			SendClientMessage(playerid, COLOR_WHITE, "");
		}
	}
	return 1;
}

GetPosBehindVehicle(vehicleid, &Float:x, &Float:y, &Float:z, Float:offset=0.5)
{
	new Float:vehicleSize[3], Float:vehiclePos[3];
	GetVehiclePos(vehicleid, vehiclePos[0], vehiclePos[1], vehiclePos[2]);
	GetVehicleModelInfo(GetVehicleModel(vehicleid), VEHICLE_MODEL_INFO_SIZE, vehicleSize[0], vehicleSize[1], vehicleSize[2]);
	GetXYBehindVehicle(vehicleid, vehiclePos[0], vehiclePos[1], (vehicleSize[1]/2)+offset);
	x = vehiclePos[0];
	y = vehiclePos[1];
	z = vehiclePos[2];
	return 1;
}

GetXYBehindVehicle(vehicleid, &Float:q, &Float:w, Float:distance)
{
	new Float:a;
	GetVehiclePos(vehicleid, q, w, a);
	GetVehicleZAngle(vehicleid, a);
	q += (distance * -floatsin(-a, degrees));
	w += (distance * -floatcos(-a, degrees));
}

GetClosestVehicle(playerid)
{
	new curr_vehid, Float:curr_dist = -1, Float:playerPos[3], Float:dist;
	GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);

	for(new i; i < MAX_VEHICLES; i++)
	{
		if (!gm_VehicleData[i][InGame]) continue;

		dist = GetVehicleDistanceFromPoint(i, playerPos[0], playerPos[1], playerPos[2]);

		if (curr_dist == -1)
		{
			curr_dist = dist;
			curr_vehid = i;
		}

		if (dist < curr_dist)
		{
			curr_dist = dist;
			curr_vehid = i;
		}
	}
	return curr_vehid;
}

IsValidWeapon(weaponid)
{
	if (weaponid < 1 || weaponid > 46 || (weaponid > 18 && weaponid < 22)) return false;

	return true;
}

public OnPlayerWeaponShot(playerid, weaponid, hittype, hitid, Float:fX, Float:fY, Float:fZ)
{
	if (gm_PlayerData[playerid][WeaponHolster][WeaponID] == weaponid)
	{
		gm_PlayerData[playerid][WeaponHolster][Ammo]--;
		if (gm_PlayerData[playerid][WeaponHolster][Ammo] < 1)
		{
			new empty_weapon[e_GM_WEAPONS];
			gm_PlayerData[playerid][WeaponHolster] = empty_weapon;
		}
	}
	if (gm_PlayerData[playerid][WeaponSling][WeaponID] == weaponid)
	{
		gm_PlayerData[playerid][WeaponSling][Ammo]--;
		if (gm_PlayerData[playerid][WeaponSling][Ammo] < 1)
		{
			new empty_weapon[e_GM_WEAPONS];
			gm_PlayerData[playerid][WeaponSling] = empty_weapon;
		}
	}
	return 1;
}

ShowRegisterDialog(playerid, type = 0)
{
	printf("[debug] ShowRegisterDialog(%i, %i)", playerid, type);
	switch (type)
	{
		case 0:
		{
			//TDShow_Login(playerid);

			Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, \
				"Vice City Emergency Responders", "Welcome to Vice City Emergency Responders!\nYour account was not found in our database, meaning that you'll have to register if you wish to play.", \
				MENU_PROCEED, MENU_EXIT);
		}
		case 1:
		{
			//TDShow_Login(playerid);

			Dialog_Show(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, \
				"Vice City Emergency Responders", "Welcome to Vice City Emergency Responders!\nYour account was not found in our database, meaning that you'll have to register if you wish to play.", \
				MENU_PROCEED, MENU_EXIT);

			SendClientMessage(playerid, COLOR_TOMATO, \
				"[ ! ]{FFFFFF} The password length entered is insufficient. The minimum is "#MIN_PASSWORD_LENGTH" and the maximum is "#MAX_PASSWORD_LENGTH".");
		}
	}
	return 1;
}

ShowLoginDialog(playerid, type = 0)
{
	printf("[debug] ShowLoginDialog(%i, %i)", playerid, type);
	switch (type)
	{
		case 0:
		{
			//TDShow_Login(playerid);

			Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, \
				"Vice City Emergency Responders", "Welcome back to Vice City Emergency Responders!\nYour account was found in our database, meaning that you'll have to login.", \
				MENU_PROCEED, MENU_EXIT);
		}
		case 1:
		{
			//TDShow_Login(playerid);

			Dialog_Show(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, \
				"Vice City Emergency Responders", "Welcome back to Vice City Emergency Responders!\nYour account was found in our database, meaning that you'll have to login.", \
				MENU_PROCEED, MENU_EXIT);

			SendClientMessageEx(playerid, COLOR_TOMATO, \
				"[ ! ]{FFFFFF} The password you have entered is incorrect. Please try again. (%i/%i attempts)",
				iLoginAttempts[playerid],
				MAX_LOGIN_ATTEMPTS
			);
		}
	}
	return 1;
}

ShowLobbyDialog(playerid, type = 0)
{
	switch (type)
	{
		case 0:
		{
			Dialog_Show(playerid, DIALOG_LOBBY_SELECTION, DIALOG_STYLE_LIST, \
				"Select a Lobby", "Main\nFreeroam", MENU_PROCEED, MENU_EXIT);

			SendClientMessage(playerid, COLOR_TOMATO, \
				"> {FFFFFF}You are now required to select a lobby to join!");
		}
		case 1:
		{
			Dialog_Show(playerid, DIALOG_LOBBY_SWITCH, DIALOG_STYLE_LIST, \
				"Select a Lobby", "Main\nFreeroam", MENU_PROCEED, "Cancel");

			SendClientMessage(playerid, COLOR_TOMATO, \
				"> {FFFFFF}You are now required to select a lobby to join!");
		}
	}
	return 1;
}

/*LoginMusicEnd(playerid)
{
	return PlayerPlaySound(playerid, 1062, 0.0, 0.0, 0.0);
}*/

Float:GetPlayerPacketLoss(playerid)
{
	return eUser[playerid][e_Packet];
}

callback:criminalweapons(playerid)
{
	return GivePlayerWeapon(playerid, 24, 50), GivePlayerWeapon(playerid, 30, 150);
}

callback:PlayerChecker()
{
	new count;
		//player_count = Iter_Count(gm_Players);

	foreach(new i : Player) {
		if(eUser[i][e_USER_LOBBY] == Main) count++;
	}
	
	if (count >= PLAYERS_TO_START) {
		StartGame();
	}
	else {
		SendClientMessageToAllEx(COLOR_GREEN,
			"> {FFFFFF}%d more %s required before the game can start!",
			PLAYERS_TO_START - count,
			(PLAYERS_TO_START - count == 1) ? ("player is") : ("players are"));
	}

	return 1;
}

ShowStatsForPlayer(playerid, targetid)
{
	new
		Float: WinRatio,
		Float: KD;

	KD = ((eUser[targetid][e_USER_DEATHS] < 0) ? (0.0) : (floatdiv(eUser[targetid][e_USER_KILLS], eUser[targetid][e_USER_DEATHS])));
	WinRatio = ((eUser[targetid][e_USER_WINS] < 0) ? (0.0) : (floatdiv(eUser[targetid][e_USER_LOSSES], eUser[targetid][e_USER_WINS])));

	SendClientMessageEx(playerid, COLOR_GREEN, "|__________________Statistics of %s [%s]__________________|",
		GetPlayerNameEx(targetid),
		GetDateEx()
	);

	SendClientMessageEx(playerid, COLOR_GREY, "CHARACTER: Name:[%s] MaID:[%d] Cash:[%d] Score:[%d]",
		GetPlayerNameEx(targetid),
		eUser[targetid][e_USER_SQLID],
		eUser[targetid][e_USER_MONEY],
		eUser[targetid][e_USER_SCORE]
	);

	SendClientMessageEx(playerid, COLOR_GREY, "GAME STATS: Wins:[%d] Losses:[%d] Kills:[%d] Deaths:[%d]",
		eUser[targetid][e_USER_WINS],
		eUser[targetid][e_USER_LOSSES],
		eUser[targetid][e_USER_KILLS],
		eUser[targetid][e_USER_DEATHS]
	);

	SendClientMessageEx(playerid, COLOR_GREY, "GAME STATS: Win Ratio:[%0.2f] K/D:[%0.2f]",
		WinRatio,
		KD
	);

	SendClientMessageEx(playerid, COLOR_GREY, "MISC: Ping:[%d] Packetloss:[%1.f%%]",
		GetPlayerPing(targetid),
		NetStats_PacketLossPercent(targetid)
	);

	if (eUser[targetid][e_USER_VIP_LEVEL] > 0)
	{
		SendClientMessageEx(playerid, COLOR_DONATOR, "DONATOR: Level:[%d (%s)]",
			eUser[targetid][e_USER_VIP_LEVEL],
			GetPlayerDonatorRank(targetid)
		);
	}

	if (eUser[targetid][e_USER_ADMIN_LEVEL] > 0)
	{
		SendClientMessageEx(playerid, COLOR_TOMATO, "ADMIN: Level:[%d (%s)] Int:[%d] VW:[%d] IP:[%s]",
			eUser[targetid][e_USER_ADMIN_LEVEL],
			GetPlayerAdminRank(targetid),
			GetPlayerInterior(targetid),
			GetPlayerVirtualWorld(targetid),
			GetPlayerIpEx(targetid)
		);
	}

	SendClientMessageEx(playerid, COLOR_GREEN, "|__________________Statistics of %s [%s]__________________|",
		GetPlayerNameEx(targetid),
		GetDateEx()
	);

	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	if (source != 0)
		return 1;
	
	if (clickedplayerid == playerid)
		return 1;
	
	if (eUser[playerid][e_USER_ADMIN_LEVEL] < 1)
		return 1;

	if (!IsPlayerConnected(clickedplayerid))
		return SendClientMessageEx(playerid, COLOR_TOMATO, "ERROR: You cannot select a player that is not connected.");

	p_SelectedPlayer[playerid] = clickedplayerid;

	SendClientMessageEx(playerid, COLOR_TOMATO, "> {FFFFFF}Select what you wish to do with %s.", GetPlayerNameEx(clickedplayerid));
	ShowAdminPanelDialog(playerid);

	return 1;
}

ShowAdminPanelDialog(playerid)
{
	new string[128];
	format(string, sizeof string, "Admin Panel (%s)", GetPlayerNameEx(p_SelectedPlayer[playerid]));

	Dialog_Show(playerid, DIALOG_ADMINPANEL_MAIN, DIALOG_STYLE_LIST, string,
		"Ban\nKick\nView Statistics",
		MENU_PROCEED, MENU_EXIT
	);

	return 1;
}

callback:Log_Write(const path[], const str[], {Float,_}:...)
{
	static
		args,
		start,
		end,
		File:file,
		string[1024]
	;
	if ((start = strfind(path, "/")) != -1) {
		strmid(string, path, 0, start + 1);

		if (!fexist(string))
			return printf("** Warning: Directory \"%s\" doesn't exist. Create it in your scriptfiles folder.", string);
	}
	#emit LOAD.S.pri 8
	#emit STOR.pri args

	file = fopen(path, io_append);

	if (!file)
		return 0;

	if (args > 8)
	{
		#emit ADDR.pri str
		#emit STOR.pri start

		for (end = start + (args - 8); end > start; end -= 4)
		{
			#emit LREF.pri end
			#emit PUSH.pri
		}
		#emit PUSH.S str
		#emit PUSH.C 1024
		#emit PUSH.C string
		#emit PUSH.C args
		#emit SYSREQ.C format

		fwrite(file, string);
		fwrite(file, "\r\n");
		fclose(file);

		#emit LCTRL 5
		#emit SCTRL 4
		#emit RETN
	}
	fwrite(file, str);
	fwrite(file, "\r\n");
	fclose(file);

	return 1;
}

public OnQueryError(errorid, const error[], const callback[], const query[], MySQL:handle) {
	printf("** [MySQL - %i]: %s (in callback %s)", errorid, error, callback);
	printf("** [MySQL - %i - query]: %s", query);
	Log_Write("logs/mysql_log.txt", "[%s] %s: %s", GetDateEx(), (callback[0]) ? (callback) : ("n/a"), error);

	return 1;
}

/*callback:OnPlayerMDCCheck(playerid, lookupid) {
	SendClientMessage(playerid, -1, "Feature yet to be completed.");
	return 1;
	if(cache_num_rows())
	{
		new id,
			date[10],
			time[10],
			charge[MAX_CHARGE_LEN];

		cache_get_value_name_int(0, "id", id);
		cache_get_value_name(0, "date", date, sizeof date);
		cache_get_value_name(0, "time", time, sizeof time);
		cache_get_value_name(0, "charge", charge, sizeof charge);

		Dialog_Show(playerid, DIALOG_MDC_SUCCESS, DIALOG_STYLE_TABLIST_HEADERS, "MDC Results for %s", 
			"Charge ID\tDate\tTime\tCharge\n\
			%d", 
			"Close", "", 
			...);
	}
}*/

callback:OnCheatDetected(playerid, ip_address[], type, code) {
	if(code == 39) return 1;
	else return 1;
}

#include "resources/cmds.pwn"
#include "resources/anims.pwn"
#include "resources/dialogs.pwn"
#include "resources/logs.pwn"
#include "resources/vicecity/vc.pwn"
//#include "resources/vicecity/skins.pwn"
#include "resources/vicecity/misc.pwn"

//#include "resources/textdraws/td-vcer.pwn"
//#include "resources/textdraws/td-login.pwn"

#include "resources/mapping.pwn"