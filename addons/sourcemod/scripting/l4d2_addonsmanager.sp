#include <left4dhooks>
#include <sourcemod>
#include <sdktools>

#define STEAMIDLIST_WHITELIST "addons/sourcemod/data/steamsforaddons.txt"
#define STEAMIDLIST_BLACKLIST "addons/sourcemod/data/steamsagainstaddons.txt"

new Handle:Arr_SteamIDs_WhiteList = INVALID_HANDLE;
new Handle:Arr_SteamIDs_BlackList = INVALID_HANDLE;
new Handle:g_steamAddons = INVALID_HANDLE;
new Handle:g_steamModeAddons = INVALID_HANDLE;

public Plugin:myinfo =  
{ 
	name = "L4D2 Addons Manager", 
	author = "Magical", 
	description = "Disables or enables addons for specified players.", 
	version = "1.0",
}

public OnPluginStart() 
{
	g_steamAddons = CreateConVar("l4d2_addons_manager_enabled", "1", "Addons Manager: 0 - Disabled, 1 - Enabled.", FCVAR_SPONLY,true,0.00,true,1.00);
	g_steamModeAddons = CreateConVar("l4d2_addons_manager_mode", "1", "When Addons manager and eclipse is activated: 0 - Use Black list, 1 - Use White list", FCVAR_SPONLY,true,0.00,true,1.00);
	RegAdminCmd("sm_addonwhitecontrol", Command_AddonWhiteListControl, ADMFLAG_BAN);
	RegAdminCmd("sm_addonblackcontrol", Command_AddonBlackListControl, ADMFLAG_BAN);
	LoadSteamIDWhiteList();
	LoadSteamIDBlackList();
	AutoExecConfig(true, "l4d2_addonsmanager");
}

public Action:Command_AddonWhiteListControl(client, args)
{
	if (args < 1)
	{									
		ReplyToCommand(client, "[SM] Usage: sm_addonwhitecontrol <#userid|name> Adds or removes player from Addons White list.");
		return Plugin_Handled;
	}
	
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		//ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		new target = target_list[i];
		if (IsClientConnected(target))
		{
			if (IsClientInGame(target))
			{
				if (!IsFakeClient(target))
				{
					new String:tmp_steamid[21];
					GetClientAuthId(target, AuthId_Steam2, tmp_steamid, sizeof(tmp_steamid), false);
					if (FindStringInArray(Arr_SteamIDs_WhiteList, tmp_steamid) != -1)
					{
						int ArrayIndex = FindStringInArray(Arr_SteamIDs_WhiteList, tmp_steamid);
						RemoveFromArray(Arr_SteamIDs_WhiteList, ArrayIndex);
					
						if (FileExists(STEAMIDLIST_WHITELIST))
							DeleteFile(STEAMIDLIST_WHITELIST);

						new Handle:hFile = OpenFile(STEAMIDLIST_WHITELIST, "at");

						new String:testarr[21];
		
						for (int ind = 0; ind < GetArraySize(Arr_SteamIDs_WhiteList); ind++)
						{
							GetArrayString(Arr_SteamIDs_WhiteList, ind, testarr, sizeof(testarr));
							if (ind == GetArraySize(Arr_SteamIDs_WhiteList))
								WriteFileString(hFile, testarr, false);
							else
								WriteFileLine(hFile, testarr);
						}

						CloseHandle(hFile);
					
						ReplyToCommand(client, "[SM] Removed from Addons White list of %s.", target_name);
					}
					else
					{
						PushArrayString(Arr_SteamIDs_WhiteList, tmp_steamid);
						new Handle:hFile = OpenFile(STEAMIDLIST_WHITELIST, "at");
						WriteFileLine(hFile, tmp_steamid);
						CloseHandle(hFile);
						ReplyToCommand(client, "[SM] Added to Addons White list for %s.", target_name);
					}
				}
				else
				{
					ReplyToCommand(client, "[SM] Can't use this command to bots.");
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:Command_AddonBlackListControl(client, args)
{
	if (args < 1)
	{									
		ReplyToCommand(client, "[SM] Usage: sm_addonblackcontrol <#userid|name> Adds or removes player from Addons Black list.");
		return Plugin_Handled;
	}
	
	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));

	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;

	if ((target_count = ProcessTargetString(
			arg,
			client,
			target_list,
			MAXPLAYERS,
			COMMAND_FILTER_ALIVE,
			target_name,
			sizeof(target_name),
			tn_is_ml)) <= 0)
	{
		//ReplyToTargetError(client, target_count);
		return Plugin_Handled;

	}
	
	for (new i = 0; i < target_count; i++)
	{
		new target = target_list[i];
		if (IsClientConnected(target))
		{
			if (IsClientInGame(target))
			{
				if (!IsFakeClient(target))
				{
					new String:tmp_steamid[21];
					GetClientAuthId(target, AuthId_Steam2, tmp_steamid, sizeof(tmp_steamid), false);
					if (FindStringInArray(Arr_SteamIDs_BlackList, tmp_steamid) != -1)
					{
						int ArrayIndex = FindStringInArray(Arr_SteamIDs_BlackList, tmp_steamid);
						RemoveFromArray(Arr_SteamIDs_BlackList, ArrayIndex);
					
						if (FileExists(STEAMIDLIST_BLACKLIST))
							DeleteFile(STEAMIDLIST_BLACKLIST);

						new Handle:hFile = OpenFile(STEAMIDLIST_BLACKLIST, "at");

						new String:testarr[21];
		
						for (int ind = 0; ind < GetArraySize(Arr_SteamIDs_BlackList); ind++)
						{
							GetArrayString(Arr_SteamIDs_BlackList, ind, testarr, sizeof(testarr));
							if (ind == GetArraySize(Arr_SteamIDs_BlackList))
								WriteFileString(hFile, testarr, false);
							else
								WriteFileLine(hFile, testarr);
						}

						CloseHandle(hFile);
					
						ReplyToCommand(client, "[SM] Removed from Addons Black list of %s.", target_name);
					}
					else
					{
						PushArrayString(Arr_SteamIDs_BlackList, tmp_steamid);
						new Handle:hFile = OpenFile(STEAMIDLIST_BLACKLIST, "at");
						WriteFileLine(hFile, tmp_steamid);
						CloseHandle(hFile);
						ReplyToCommand(client, "[SM] Added to Addons Black list for %s.", target_name);
					}
				}
				else
				{
					ReplyToCommand(client, "[SM] Can't use this command to bots.");
				}
			}
		}
	}
	
	return Plugin_Handled;
}

public Action:L4D2_OnClientDisableAddons(const char[] SteamID)
{
	if (GetConVarInt(g_steamAddons) == 1)
	{
		if (GetConVarInt(g_steamModeAddons) == 1)
		{
			if (FindStringInArray(Arr_SteamIDs_WhiteList, SteamID) != -1)
				return Plugin_Handled;
			else
				return Plugin_Continue;
		}
		else
		{
			if (FindStringInArray(Arr_SteamIDs_BlackList, SteamID) != -1)
				return Plugin_Continue;
			else
				return Plugin_Handled;
		}
	}

	return Plugin_Continue;
}

public void OnMapStart() 
{     
	ClearArray(Arr_SteamIDs_WhiteList);
	ClearArray(Arr_SteamIDs_BlackList);
	LoadSteamIDWhiteList();
	LoadSteamIDBlackList();
}

LoadSteamIDWhiteList()
{
	new Handle:fSteamIDList = OpenFile(STEAMIDLIST_WHITELIST, "rt");

	if (fSteamIDList == INVALID_HANDLE)
	{
		SetFailState("Unable to load file: %s", STEAMIDLIST_WHITELIST);
	}

	Arr_SteamIDs_WhiteList = CreateArray(256);

	new String:auth[256];

	while (!IsEndOfFile(fSteamIDList) && ReadFileLine(fSteamIDList, auth, sizeof(auth)))
	{
		ReplaceString(auth, sizeof(auth), "\r", "");
		ReplaceString(auth, sizeof(auth), "\n", "");
		// Maybe use TrimString instead of the two ReplaceStrings here?
	
		PushArrayString(Arr_SteamIDs_WhiteList, auth);
	}
	
	CloseHandle(fSteamIDList);
}

LoadSteamIDBlackList()
{
	new Handle:fSteamIDList = OpenFile(STEAMIDLIST_BLACKLIST, "rt");

	if (fSteamIDList == INVALID_HANDLE)
	{
		SetFailState("Unable to load file: %s", STEAMIDLIST_WHITELIST);
	}

	Arr_SteamIDs_BlackList = CreateArray(256);

	new String:auth[256];

	while (!IsEndOfFile(fSteamIDList) && ReadFileLine(fSteamIDList, auth, sizeof(auth)))
	{
		ReplaceString(auth, sizeof(auth), "\r", "");
		ReplaceString(auth, sizeof(auth), "\n", "");
		// Maybe use TrimString instead of the two ReplaceStrings here?
	
		PushArrayString(Arr_SteamIDs_BlackList, auth);
	}
	
	CloseHandle(fSteamIDList);
}

