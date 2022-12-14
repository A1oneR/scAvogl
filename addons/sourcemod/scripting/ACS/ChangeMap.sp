/*======================================================================================
#################             A C S   C H A N G E   M A P              #################
======================================================================================*/

// Checks conditions to see if the map needs to be changed by ACS now
// If the map needs to be changed this will also change it
void ChangeMapIfNeeded()
{
	// Ensure the game mode has been set to a valid one before continuing
	if (IsGameModeValid(g_iGameMode) == false)
		return;
	
	// This is required because the Events can fire multiple times
	g_bStopACSChangeMap = true;
	CreateTimer(REALLOW_ACS_MAP_CHANGE_DELAY, TimerResetCanACSChangeMap);

	// If no player has chosen a map by voting, then go with the automatic map rotation cycle
	int iNextMapIndex = FindCurrentMapIndex();
	//if (IsMapIndexValid(iNextMapIndex) == false)
		//return;
	
	// Delayed call to change the map
	CreateTimer(g_fWaitTimeBeforeSwitch[g_iGameMode], Timer_ChangeMap, iNextMapIndex);
}

// Change campaign using its index
Action Timer_ChangeMap(Handle timer, int iMapIndex)
{
	char currentmap[64];
	GetCurrentMap(currentmap, 64);
	L4D_RestartScenarioFromVote(currentmap);

	//ServerCommand("changelevel %s", g_strMapListArray[iMapIndex][MAP_LIST_COLUMN_MAP_NAME_START]);

	return Plugin_Stop;
}

// This is required because the Events can fire multiple times
Action TimerResetCanACSChangeMap(Handle timer, int iData)
{
	g_bStopACSChangeMap = false;

	return Plugin_Stop;
}

// Finds the map list array index of the map the players are currently on
int FindCurrentMapIndex()
{
	if (g_iMapsIndexStartForCurrentGameMode == -1)
		return -1;

	// Get the current map from the game
	char strCurrentMap[32];
	GetCurrentMap(strCurrentMap, 32);	

	// Go through all maps and to find which map index it is on
	for(int iMapIndex = g_iMapsIndexStartForCurrentGameMode; iMapIndex <= g_iMapsIndexEndForCurrentGameMode; iMapIndex++)
		if (StrEqual(g_strMapListArray[iMapIndex][MAP_LIST_COLUMN_MAP_NAME_END], strCurrentMap, false) == true)
			return iMapIndex;

	return -1;
}

// Finds the next map index item to know what map comes after the existing one
int FindNextMapIndex()
{
	int iCurrentMapIndex = FindCurrentMapIndex();
	if (iCurrentMapIndex == -1)
		return -1;

	int iNextCampaignMapIndex = iCurrentMapIndex;			    	// Letz keep going
	if (iNextCampaignMapIndex > g_iMapsIndexEndForCurrentGameMode)	// Check to see if its the end of the array. If so,
		iNextCampaignMapIndex = 0;									// set it to the first map index fro the game mode

	return iNextCampaignMapIndex;
}