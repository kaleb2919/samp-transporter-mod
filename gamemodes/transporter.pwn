//----------------------------------------------------------
//
//  The Transporter 0.0.1
//  A freeroam gamemode for SA-MP 0.3
//
//----------------------------------------------------------

#include <a_samp>
#include <core>
#include <float>
#include "../include/tr_spike_strip.inc"
#include "../include/tr_common.inc"
#include "../include/tr_spawns.inc"

#pragma tabsize 0

//----------------------------------------------------------

#define COLOR_WHITE 			 0xFFFFFFFF
#define COLOR_GREEN 			 0x10AA10FF

#define COLOR_DEA_PLAYER    	 0x2A52BEFF
#define COLOR_TRANSPORTER_PLAYER 0x92000AFF

#define ALERT_COLOR 0xB57900FF

#define STAGE_ZERO -1
#define STAGE_FIND_VEHICLE 0
#define STAGE_TRANSIT 1

#define DEA_ROLE 0
#define TRANSPORTER_ROLE 1

new current_stage = STAGE_ZERO;
new total_vehicles_from_files=0;
new round_is_runing = 0;
new target_vehicle = -1;
new vehicle_captured  = 0;

// Coord
new Float:vehicle_x;
new Float:vehicle_y;
new Float:vehicle_z;
new Float:vehicle_r;

new Float:target_x;
new Float:target_y;
new Float:target_z;

// Class selection globals
new gPlayerRoleSelection[MAX_PLAYERS];
new gTableScore[MAX_PLAYERS];

new Text:txtDEA;
new Text:txtTransporter;

forward EndGame();

//----------------------------------------------------------

main()
{
	print("\n---------------------------------------");
	print("Running The Transporter - by Aunmag.\n");
	print("---------------------------------------\n");

}

//----------------------------------------------------------

ClassSel_InitTextDraws()
{
    // Init our observer helper text display
	txtDEA = TextDrawCreate(10.0, 380.0, "DEA");
	ClassSel_InitRoleText(txtDEA, COLOR_DEA_PLAYER);
	txtTransporter = TextDrawCreate(10.0, 380.0, "Transporter");
	ClassSel_InitRoleText(txtTransporter, COLOR_TRANSPORTER_PLAYER);
}

//----------------------------------------------------------

ClassSel_InitRoleText(Text:txtInit, color)
{
  	TextDrawUseBox(txtInit, 0);
	TextDrawLetterSize(txtInit,1.25,3.0);
	TextDrawFont(txtInit, 1);
	TextDrawSetShadow(txtInit,0);
    TextDrawSetOutline(txtInit,1);
    TextDrawColor(txtInit, color);
}

//----------------------------------------------------------

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~The Transporter v0.1", 3000, 4);
  	SendClientMessage(playerid,COLOR_WHITE,"Welcome to The Transporter");
  	
	gPlayerRoleSelection[playerid] = -1;
    gTableScore[playerid] = 0;

	SetPlayerColor(playerid, COLOR_WHITE);
	
 	return 1;
}

//----------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	
	SetPlayerInterior(playerid,0);
 	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 2000);

	SetPlayerPos(playerid, 2495.0720, -1687.5278, 13.5150);
	SetPlayerFacingAngle(playerid, 359.6696);
	    
    GivePlayerWeapon(playerid,WEAPON_COLT45, 300);
	TogglePlayerClock(playerid, 0);

	return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
    if(round_is_runing == 1) {
		if(!IsPlayerNPC(playerid)) {
			if(!IsPlayerNPC(killerid)) {
				gTableScore[killerid] += 1;
				GivePlayerWeapon(killerid,WEAPON_COLT45, 100);
				GivePlayerMoney(playerid, 100);
			}
			gPlayerRoleSelection[playerid] = -1;
			ResetPlayerMoney(playerid);
			ForceClassSelection(playerid);
			TogglePlayerSpectating(playerid, true);
			TogglePlayerSpectating(playerid, false);
		}
 
		new DEA_are_alive = false;
		new transoprters_are_alive = false;

		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerNPC(i)) continue;
			if(!IsPlayerConnected(i)) continue;
			
			if (gPlayerRoleSelection[i] == DEA_ROLE) {
				DEA_are_alive = true;
			}
			if (gPlayerRoleSelection[i] == TRANSPORTER_ROLE) {
				transoprters_are_alive = true;
			}
		}
		if(!DEA_are_alive) {
			GameTextForAll("~w~Winner: ~r~The Transporters", 3000, 4);
			SetTimer("EndGame", 3000, -1);
			ShowBestPlayer();
		}
		if(!transoprters_are_alive) {
			GameTextForAll("~w~Winner: ~b~DEA", 3000, 4);
			SetTimer("EndGame", 3000, -1);
			ShowBestPlayer();
		}
	}
	
   	return 1;
}

//----------------------------------------------------------

public OnPlayerRequestSpawn(playerid)
{
    if(round_is_runing == 1) {
  		SendClientMessage(playerid, ALERT_COLOR, "The round is not over");
		return 0;
	}

	if (gPlayerRoleSelection[playerid] == DEA_ROLE) {
		SendClientMessage(playerid, ALERT_COLOR, "Your role is DEA");
		SetPlayerColor(playerid, COLOR_DEA_PLAYER);
	}
	if (gPlayerRoleSelection[playerid] == TRANSPORTER_ROLE) {
		SendClientMessage(playerid, ALERT_COLOR, "Your role is Transporter");
		SetPlayerColor(playerid, COLOR_TRANSPORTER_PLAYER);
	}
	
	TextDrawHideForPlayer(playerid,txtDEA);
	TextDrawHideForPlayer(playerid,txtTransporter);

    return 1;
}

//----------------------------------------------------------

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;

	SetPlayerColor(playerid, COLOR_WHITE);

	SetPlayerInterior(playerid, 11);
	SetPlayerPos(playerid, 508.7362, -87.4335, 998.9609);
	SetPlayerFacingAngle(playerid, 0.0);
	SetPlayerCameraPos(playerid, 508.7362, -83.4335, 998.9609);
	SetPlayerCameraLookAt(playerid, 508.7362, -87.4335, 998.9609);

	if (classid <= 8) {
		gPlayerRoleSelection[playerid] = DEA_ROLE;
		TextDrawShowForPlayer(playerid,txtDEA);
		TextDrawHideForPlayer(playerid,txtTransporter);
	} else if (classid >= 9) {
		gPlayerRoleSelection[playerid] = TRANSPORTER_ROLE;
		TextDrawShowForPlayer(playerid,txtTransporter);
		TextDrawHideForPlayer(playerid,txtDEA);
	}
	return 1;
}

//----------------------------------------------------------

public OnGameModeInit()
{
	SetGameModeText("The Transporter");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	ShowNameTags(0);
	EnableStuntBonusForAll(0);
	DisableInteriorEnterExits();
	SetWeather(2);
	SetWorldTime(11);

	ClassSel_InitTextDraws();

	// DEA Class
	AddPlayerClass(280,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(281,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(285,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(286,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(300,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(301,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(310,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(306,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(307,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

	// Transporter Class
	AddPlayerClass(111,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(112,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(113,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(124,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(125,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(126,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

	// SPECIAL
	// total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");

   	// LAS VENTURAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");
    
    // SAN FIERRO
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");
    
    // LOS SANTOS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");
    
    // OTHER AREAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");

    printf("Total vehicles from files: %d", total_vehicles_from_files);

	return 1;
}

//----------------------------------------------------------

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return 1;

    if(GetPlayerState(playerid) == PLAYER_STATE_DRIVER)
    {
        for(new i = 0; i < sizeof(SpikeInfo); i++)
  	    {
  	        if(IsPlayerInRangeOfPoint(playerid, 3.0, SpikeInfo[i][sX], SpikeInfo[i][sY], SpikeInfo[i][sZ]))
            {
  	            if(SpikeInfo[i][sCreated] == 1)
  	            {
  	                new panels, doors, lights, tires;
  	                new carid = GetPlayerVehicleID(playerid);
		            GetVehicleDamageStatus(carid, panels, doors, lights, tires);
		            tires = encode_tires(1, 1, 1, 1);
		            UpdateVehicleDamageStatus(carid, panels, doors, lights, tires);
  	                return 0;
  	            }
  	        }
  	    }
  	}

	// changing roles by inputs
	if( !gPlayerRoleSelection[playerid] &&
	    GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ) {
	    return 1;
	}

	// Don't allow minigun
	if(GetPlayerWeapon(playerid) == WEAPON_MINIGUN) {
	    Kick(playerid);
	    return 0;
	}
	
	// Don't allow jetpacks
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) {
	    Kick(playerid);
	    return 0;
	}

	return 1;
}

encode_tires(tires1, tires2, tires3, tires4) {

	return tires1 | (tires2 << 1) | (tires3 << 2) | (tires4 << 3);

}

//----------------------------------------------------------

public OnPlayerCommandText(playerid, cmdtext[])
{
	if (strcmp(cmdtext, "/role", true) == 0)
	{
		ForceClassSelection(playerid);
		TogglePlayerSpectating(playerid, true);
		TogglePlayerSpectating(playerid, false);
    	new name[MAX_PLAYER_NAME];
		new size = 0;
		size = GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if (size > 0) {
			new message[144];
			format(message, sizeof (message), "%s changes the role", name);
			SendClientMessageToAll(COLOR_GREEN, message);
		}
    	return 1;
	}
	if (strcmp(cmdtext, "/createstrip", true) == 0)
	{
	    new Float:plocx,Float:plocy,Float:plocz,Float:ploca;
        GetPlayerPos(playerid, plocx, plocy, plocz);
        GetPlayerFacingAngle(playerid,ploca);
        CreateStrip(plocx,plocy,plocz,ploca);
	    return 1;
	}
	else if (strcmp(cmdtext, "/removestrip", true) == 0)
	{
        DeleteClosestStrip(playerid);
	    return 1;
	}
	else if (strcmp(cmdtext, "/removeallstrip", true) == 0)
	{
        DeleteAllStrip();
	    return 1;
	}
	if (strcmp(cmdtext, "/start", true) == 0)
	{
		if(gPlayerRoleSelection[playerid] < 0) {
			SendClientMessage(playerid, ALERT_COLOR, "You must select a role");
			return 1;
		}
		if(round_is_runing == 1) {
			SendClientMessage(playerid, ALERT_COLOR, "The round is not over");
			return 1;
		}
		round_is_runing = 1;

		new name[MAX_PLAYER_NAME];
		new size = 0;
		size = GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if (size > 0) {
			new message[144];
			format(message, sizeof (message), "%s started the round", name);
			SendClientMessageToAll(COLOR_GREEN, message);

			new randSpawnTransporter = 	random(sizeof(gRandomSpawns_LosSantos_Trn));
			new randSpawnDEA = 			random(sizeof(gRandomSpawns_LosSantos_DEA));
			new randSpawnVehicle = 		random(sizeof(gRandomSpawns_LosSantos_Veh));
			new randSpawnTarget = 		random(sizeof(gRandomSpawns_SanFierro));

			vehicle_x = gRandomSpawns_LosSantos_Veh[randSpawnVehicle][0];
			vehicle_y = gRandomSpawns_LosSantos_Veh[randSpawnVehicle][1];
			vehicle_z = gRandomSpawns_LosSantos_Veh[randSpawnVehicle][2];
			vehicle_r = gRandomSpawns_LosSantos_Veh[randSpawnVehicle][3];

			target_x = gRandomSpawns_SanFierro[randSpawnTarget][0];
			target_y = gRandomSpawns_SanFierro[randSpawnTarget][1];
			target_z = gRandomSpawns_SanFierro[randSpawnTarget][2];

			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerNPC(i)) continue;
  	    		if(!IsPlayerConnected(i)) continue;

				if (gPlayerRoleSelection[i] == DEA_ROLE) {
					SetPlayerPos(i, 
						gRandomSpawns_LosSantos_DEA[randSpawnDEA][0],
						gRandomSpawns_LosSantos_DEA[randSpawnDEA][1],
						gRandomSpawns_LosSantos_DEA[randSpawnDEA][2]
					);
					GameTextForPlayer(i, "~w~The informant leaked the coordinates", 6000, 3);
					SetPlayerCheckpoint(i, target_x, target_y, target_z, 10);
				} else if (gPlayerRoleSelection[i] == TRANSPORTER_ROLE) {
					SetPlayerPos(i, 
						gRandomSpawns_LosSantos_Trn[randSpawnTransporter][0], 
						gRandomSpawns_LosSantos_Trn[randSpawnTransporter][1],
						gRandomSpawns_LosSantos_Trn[randSpawnTransporter][2]
					);

					GameTextForPlayer(i, "~w~Vehicle on the plase", 6000, 3);
					SetPlayerCheckpoint(i, vehicle_x, vehicle_y, vehicle_z, 10);
				}				
			}

			new randVehicles = random(sizeof(gRandomVehicles));
			target_vehicle = AddStaticVehicle(gRandomVehicles[randVehicles], vehicle_x, vehicle_y, vehicle_z, vehicle_r + 90, 0, 1);
			current_stage = STAGE_FIND_VEHICLE;
		}
    	return 1;
	}
	if (strcmp(cmdtext, "/stop", true) == 0)
	{
		if(gPlayerRoleSelection[playerid] < 0) {
			SendClientMessage(playerid, ALERT_COLOR, "You must select a role");
			return 1;
		}
		if(round_is_runing == 0) {
			SendClientMessage(playerid, ALERT_COLOR, "The round is not started");
			return 1;
		}
		round_is_runing = 0;
		if (target_vehicle > 0) {
			DestroyVehicle(target_vehicle);
		}
		target_vehicle = -1;
		
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerNPC(i)) continue;
			if(!IsPlayerConnected(i)) continue;

			SetPlayerPos(i, 2495.0720, -1687.5278, 13.5150);
			SetPlayerFacingAngle(i, 359.6696);
    		DisablePlayerCheckpoint(i);
		}

		new name[MAX_PLAYER_NAME];
		new size = 0;
		size = GetPlayerName(playerid, name, MAX_PLAYER_NAME);
		if (size > 0) {
			new message[144];
			format(message, sizeof (message), "%s stopped the round", name);
			SendClientMessageToAll(COLOR_GREEN, message);
		}
		current_stage = STAGE_ZERO;
    	return 1;
	}
	return 0;
}

//----------------------------------------------------------

public OnPlayerEnterCheckpoint(playerid)
{
	switch (current_stage) {
		case STAGE_ZERO: {
			printf("Theoretically, this code is not reachable.");
			return 0;
		}
		case STAGE_FIND_VEHICLE: {
			for(new i = 0; i < MAX_PLAYERS; i++)
			{
				if(IsPlayerNPC(i)) continue;
				if(!IsPlayerConnected(i)) continue;
				if(gPlayerRoleSelection[i] == TRANSPORTER_ROLE) {
					DisablePlayerCheckpoint(i);
					GameTextForPlayer(playerid, "~b~DEA ~w~calculated destination", 6000, 3);
					SetPlayerCheckpoint(i, target_x, target_y, target_z, 10);
				}
				if(gPlayerRoleSelection[i] == DEA_ROLE) {
					GameTextForPlayer(playerid, "~w~Car found by ~r~Transporters", 6000, 3);
				}
			}
			current_stage = STAGE_TRANSIT;
		}
		case STAGE_TRANSIT: {
			if (gPlayerRoleSelection[playerid] == TRANSPORTER_ROLE &&
				IsPlayerInVehicle(playerid, target_vehicle)
			) {
				for(new i = 0; i < MAX_PLAYERS; i++)
				{
					if(IsPlayerNPC(i)) continue;
					if(!IsPlayerConnected(i)) continue;
					DisablePlayerCheckpoint(i);
				}
				GameTextForAll("~w~Winner: ~r~The Transporters", 3000, 4);
				SetTimer("EndGame", 3000, -1);
				ShowBestPlayer();
			}
		}
	}
	if((round_is_runing == 1) && (vehicle_captured == 1) && (gPlayerRoleSelection[playerid] == DEA_ROLE)) {
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerNPC(i)) continue;
			if(!IsPlayerConnected(i)) continue;
			DisablePlayerCheckpoint(i);
		}
		GameTextForAll("~w~Winner: ~b~DEA", 3000, 4);
		SetTimer("EndGame", 3000, -1);
		ShowBestPlayer();
		vehicle_captured = 0;
	}
    return 1;
}

//----------------------------------------------------------

public OnVehicleDeath(vehicleid, killerid)
{
	if(round_is_runing == 1) {
		if (vehicleid == target_vehicle) {
			GameTextForAll("~g~Draw", 3000, 4);
			SetTimer("EndGame", 3000, -1);
			ShowBestPlayer();
		}
	}
    return 1;
}

//----------------------------------------------------------

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	if(round_is_runing == 1) {
		if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)
		{
			new vehicleid = GetPlayerVehicleID(playerid);
			if(vehicleid == target_vehicle) {
				GameTextForPlayer(playerid, "~w~Dangerous car", 3000, 1);
				if(gPlayerRoleSelection[playerid] == DEA_ROLE) {
					DisablePlayerCheckpoint(playerid);
					SetPlayerCheckpoint(playerid, 1564.6486, -1694.2390, 5.8906, 10);
					vehicle_captured = 1;
				}
			}
		}
		if(	(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER) && 
			(newstate == PLAYER_STATE_ONFOOT)) {
			if(gPlayerRoleSelection[playerid] == DEA_ROLE) {
				vehicle_captured = 0;
				DisablePlayerCheckpoint(playerid);
				SetPlayerCheckpoint(playerid, target_x, target_y, target_z, 10);
			}
		}
	}
    
    return 1;
}

//----------------------------------------------------------

public EndGame() {
	if(round_is_runing == 1) {
		round_is_runing = 0;
		for(new i = 0; i < MAX_PLAYERS; i++)
		{
			if(IsPlayerNPC(i)) continue;
			if(!IsPlayerConnected(i)) continue;

    		gTableScore[i] = 0;
			SetPlayerPos(i, 2495.0720, -1687.5278, 13.5150);
			SetPlayerFacingAngle(i, 359.6696);
			DisablePlayerCheckpoint(i);
			DestroyVehicle(target_vehicle);
			current_stage = STAGE_ZERO;
		}
	}
}

//----------------------------------------------------------

ShowBestPlayer()
{
	new best_player = 0;
	for(new i = 0; i < MAX_PLAYERS; i++)
	{
		if(IsPlayerNPC(i)) continue;
		if(!IsPlayerConnected(i)) continue;
		
		if (gTableScore[i] > gTableScore[best_player]) {
			best_player = i;
		}
	}
	if(best_player == 0) return 1;
	
	new name[MAX_PLAYER_NAME];
	new size = 0;
	size = GetPlayerName(best_player, name, MAX_PLAYER_NAME);
	if (size > 0) {
		new message[144];
		format(message, sizeof (message), "{ffffff}Best player: {ff2222}%s, {ffffff}killed {ff2222}%d {ffffff}player", name, gTableScore[best_player]);
		SendClientMessageToAll(COLOR_GREEN, message);
	}
   	return 1;
}

//----------------------------------------------------------
