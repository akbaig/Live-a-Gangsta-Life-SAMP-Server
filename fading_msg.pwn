new DisplayMsgColor[3][MAX_PLAYERS][32];
new DisplayMsgText[3][MAX_PLAYERS][32];
new DisplayMsgTime[3][MAX_PLAYERS];
new DisplayMsgTimer = -1;
new DisplayMsgCount[3][MAX_PLAYERS];
new DisplayMsgTimerCount[3][MAX_PLAYERS];

new PlayerText:DisplayMsg[3][MAX_PLAYERS];

public TickCount()
{
	foreach(Player, i)
	{
		for(new j = 0; j < 3; j++)
		{
		    if(DisplayMsgCount[j][i] != -1)
		    {
		    	DisplayMsgCount[j][i]--;
				if(DisplayMsgCount[j][i] == 0)
				{
				    new color[32], hex;
					format(color, sizeof(color), "0x%sAA", DisplayMsgColor[j][i]);
					sscanf(color, "x", hex);
				    PlayerTextDrawColor(i, DisplayMsg[j][i], hex);
					PlayerTextDrawShow(i, DisplayMsg[j][i]);
					DisplayMsgTimerCount[j][i] = 9;
					if(DisplayMsgTimer == -1)
						DisplayMsgTimer = SetTimer("DisplayMsgTimerRepeat", 100, true);
				 	DisplayMsgCount[j][i] = -1;
				}
			}
		}
	}
}
	
stock DisplayMessage(playerid, color[], msg[])
{
	new id = 0;
	new time = gettime() - DisplayMsgTime[id][playerid];
	for(new j=1; j < 3; j++)
	{
		if(gettime()-DisplayMsgTime[j][playerid] > time)
		    id = j;
	}
	new colorr[32], hex;
	format(DisplayMsgColor[id][playerid], 32, "%s", color);
	format(DisplayMsgText[id][playerid], 32, "%s", msg);
	format(colorr, sizeof(colorr), "0x%sFF", color);
	sscanf(colorr, "x", hex);
	PlayerTextDrawSetString(playerid, DisplayMsg[id][playerid], msg);
	PlayerTextDrawColor(playerid, DisplayMsg[id][playerid], hex);
	PlayerTextDrawShow(playerid, DisplayMsg[id][playerid]);
	DisplayMsgCount[id][playerid] = 4;
	DisplayMsgTimerCount[id][playerid] = -1;
    DisplayMsgTime[id][playerid] = gettime();
}
forward DisplayMsgTimerRepeat();
public DisplayMsgTimerRepeat()
{
 	new color[32], hex, check = 0;
 	foreach(Player, i)
 	{
 	    for(new j = 0; j < 3; j++)
 	    {
			if(DisplayMsgTimerCount[j][i] != -1)
			{
			    check = 1;
			    format(color, sizeof(color), "0x%s%s%s", DisplayMsgColor[j][i], convertToHexa(DisplayMsgTimerCount[j][i]), convertToHexa(DisplayMsgTimerCount[j][i]));
                sscanf(color, "x", hex);
			    PlayerTextDrawColor(i, DisplayMsg[j][i], hex);
				PlayerTextDrawShow(i, DisplayMsg[j][i]);
			    if(DisplayMsgTimerCount[j][i] == 0)
			    {
				    format(DisplayMsgColor[j][i], 32, "");
				    format(DisplayMsgText[j][i], 32, "");
				    DisplayMsgTimerCount[j][i] = -1;
                    DisplayMsgTime[j][i] = -1;
				}
				if(DisplayMsgTimerCount[j][i] != -1) DisplayMsgTimerCount[j][i]--;
			}
		}
	}
	if(check == 0)
	{
		new id = DisplayMsgTimer;
		DisplayMsgTimer = -1;
	    KillTimer(id);
	}
	return 1;
}