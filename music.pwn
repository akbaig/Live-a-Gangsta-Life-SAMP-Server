#define DIALOG_MUSICLIST 101
new MusicTimer = 0;

public TickCount()
{
	MusicTimer++;
	if(MusicTimer == 180)
	{
	    new query[256], name[32], artist[24], url[512], rows, fields;
		mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE 1");
		mysql_query(mysql, query);
		cache_get_data(rows, fields, mysql);
		if(rows)
		{
			new id = random(rows);
	        cache_get_field_content(id, "Title", name);
	        cache_get_field_content(id, "Artist", artist);
			cache_get_field_content(id, "URL", url);
			if(isnull(artist))
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name);
			else
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} by {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name, artist);
			foreach(Player, i)
			{
			    if(AccInfo[i][pMusic] == 1 && AccInfo[i][pEntrySong] == 0)
			    {
			        PlayAudioStreamForPlayer(i, url);
			        SendClientMessage(i, 0xc91a8cFF, query);
				}
			}
		}
		MusicTimer = 0;
	}
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)// Checking what dialog we're processing
	{
		case DIALOG_MUSICLIST:
		{
			if(!response)
			{
				if(AccInfo[playerid][pMusicPage] == 0) return 0;
				else
				{
					new query[2048], name[32], artist[24], text[128], rows, fields;
					mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` LIMIT 25 OFFSET %d", --AccInfo[playerid][pMusicPage]*25);
					mysql_query(mysql, query);
					cache_get_data(rows, fields, mysql);
					format(query, sizeof(query), "");
					for(new i=0; i < rows; i++)
					{
						cache_get_field_content(i, "Title", name);
						cache_get_field_content(i, "Artist", artist);
						if(isnull(artist))
							format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}None\n", name);
						else
							format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}%s\n", name, artist);
						strcat(query, text);
					}
					if(AccInfo[playerid][pMusicPage] == 0)
						ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Next", "Close");
					else
						ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Next", "Back");
				}
			}
			else if(response)
			{
				new query[2048], name[32], artist[24], text[128], rows, fields;
				mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` LIMIT 25 OFFSET %d", ++AccInfo[playerid][pMusicPage]*25);
				mysql_query(mysql, query);
				cache_get_data(rows, fields, mysql);
				if(!rows)
				{
					AccInfo[playerid][pMusicPage] -=2;
					mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` LIMIT 25 OFFSET %d", AccInfo[playerid][pMusicPage]*25);
					mysql_query(mysql, query);
					cache_get_data(rows, fields, mysql);
				}
				format(query, sizeof(query), "");
				for(new i=0; i < rows; i++)
				{
					cache_get_field_content(i, "Title", name);
					cache_get_field_content(i, "Artist", artist);
					if(isnull(artist))
						format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}None\n", name);
					else
						format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}%s\n", name, artist);
					strcat(query, text);
				}
				if(rows != 25)
				{
					AccInfo[playerid][pMusicPage] -=2;
					ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Back", "");
				}
				else
				{
					if(AccInfo[playerid][pMusicPage] == 0)
						ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Next", "Close");
					else
						ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Next", "Back");
				}
			}
		}
	}
}
CMD:musicurl(playerid, params[])
{
    new url[128];
	if(sscanf(params, "s[128]", url)) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/musicurl [URL]");
    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {808080}Music played! [Use /stopmusic to stop the current music]");
    PlayAudioStreamForPlayer(playerid, url);
	return 1;
}
CMD:music(playerid, params[])
{
	return cmd_playmusic(playerid, params);
}
CMD:play(playerid, params[])
{
	return cmd_playmusic(playerid, params);
}
CMD:playmusic(playerid, params[])
{
    new name[32], artist[24], url[512], query[512], rows, fields;
	if(sscanf(params, "s[24]S[24]", name, artist))
	{
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/music [Title] [Artist]");
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 1]: {808080}Artist is optional");
		SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 2]: {808080}Use \" _ \" (underscore) to put spaces in-between names e.g. /music Rockstar Post_Malone");
	}
	else
	{
	    if(!strcmp(artist, "none", true)) format(artist, sizeof(artist), "");
	    if(isnull(artist))
        	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' LIMIT 1", name, artist);
		else
		    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' && `Artist` = '%s' LIMIT 1", name, artist);
		mysql_query(mysql, query);
		cache_get_data(rows, fields, mysql);
		if(rows)
		{
	        cache_get_field_content(0, "Title", name);
	        cache_get_field_content(0, "Artist", artist);
			cache_get_field_content(0, "URL", url);
			cache_delete(Cache:1, mysql);
	        PlayAudioStreamForPlayer(playerid, url);
	        if(isnull(artist))
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} [Use /stopmusic to stop the current music]", name);
			else
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} by {c91a8c}%s{FFFFFF} [Use /stopmusic to stop the current music]", name, artist);
	        SendClientMessage(playerid, 0xc91a8cFF, query);
		}
		else
		{
			if(UserStats[playerid][Admin] == 0)
		        SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {808080}No music found with such name! Ask an admin to add one?");
			else
				SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {808080}No music found with such name! Care to add one? (/addmusic)");
		}
		cache_delete(Cache:1, mysql);
	}
	return 1;
}
CMD:musicall(playerid, params[])
{
    if(UserStats[playerid][Admin] == 0) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}You don't have the permission to use this command! Use /music instead.");
    new name[32], artist[24], url[512], query[512], rows, fields;
	if(sscanf(params, "s[24]s[24]", name, artist))
	{
	
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/musicall [Title] [Artist]");
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 1]: {808080}If you don't know the artist write \"None\"");
		SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 2]: {808080}Use \" _ \" (underscore) to put spaces in-between names e.g. /musicall Rockstar Post_Malone");
	}
	else
	{
	    if(!strcmp(artist, "none", true)) format(artist, sizeof(artist), "");
		if(isnull(artist))
			mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' LIMIT 1", name, artist);
		else
    		mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' && `Artist` = '%s' LIMIT 1", name, artist);
		mysql_query(mysql, query);
		cache_get_data(rows, fields, mysql);
		if(rows)
		{
	        cache_get_field_content(0, "Title", name);
	        cache_get_field_content(0, "Artist", artist);
			cache_get_field_content(0, "URL", url);
			if(isnull(artist))
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name);
			else
	        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} by {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name, artist);
			foreach(Player, i)
			{
			    if(AccInfo[i][pMusic] == 1 && AccInfo[i][pEntrySong] == 0)
			    {
			        PlayAudioStreamForPlayer(i, url);
			        SendClientMessage(i, 0xc91a8cFF, query);
				}
			}
			MusicTimer = 0;
		}
		else
		{
			SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {808080}No music found with such name! Care to add one? (/addmusic)");
		}
		cache_delete(Cache:1, mysql);
	}
	return 1;
}
CMD:addmusic(playerid, params[])
{
	if(UserStats[playerid][Admin] == 0) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}You don't have the permission to use this command!");
	new name[32], artist[24], url[512], query[512], rows, fields;
	if(sscanf(params, "s[24]s[24]s[512]", name, artist, url))
	{
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/addmusic [Title] [Artist] [URL]");
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 1]: {808080}If you don't know the artist write \"None\" and URL must end with .mp3");
		SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 2]: {808080}Use \" _ \" (underscore) to put spaces in-between names e.g. /addmusic Rockstar Post_Malone https://..");
		return 1;
	}
	else
	{
		if(strfind(url, ".mp3", true) == -1) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}Your URL must contain .mp3 at the end.");
		if(!strcmp(artist, "none", true)) format(artist, sizeof(artist), "");
		if(isnull(artist))
			mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' LIMIT 1", name);
		else
			mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' && `Artist` = '%s' LIMIT 1", name, artist);
		mysql_query(mysql, query);
		cache_get_data(rows, fields, mysql);
		if(rows)
		{
		    if(!isnull(artist))
		    	SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}Music with that title exists already (/playmusic) - Try adding a artist with it maybe?");
			else
		 		SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}Music with that title exists already - Try /playmusic");
		    cache_delete(Cache:1, mysql);
		    return 1;
		}
		cache_delete(Cache:1, mysql);
		mysql_format(mysql, query, sizeof(query), "INSERT INTO `music`(`Title`, `Artist`, `URL`) VALUES ('%s','%s','%s')", name, artist, url);
		mysql_query(mysql, query);
		cache_delete(Cache:1, mysql);
		if(!isnull(artist)) format(query, sizeof(query), "[System]: {FFFFFF}Music added sucessfully! [Title: %s, Artist: %s]", name, artist);
		else format(query, sizeof(query), "[System]: {FFFFFF}Music added sucessfully! [Title: %s]", name, artist);
		SendClientMessage(playerid, COLOR_GREEN, query);
    	return 1;
	}
}
CMD:nextmusic(playerid, params[])
{
    if(UserStats[playerid][Admin] == 0) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}You don't have the permission to use this command!");
    new query[512], name[32], artist[24], url[512], rows, fields;
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE 1");
	mysql_query(mysql, query);
	cache_get_data(rows, fields, mysql);
	if(rows)
	{
		new id = random(rows);
        cache_get_field_content(id, "Title", name);
        cache_get_field_content(id, "Artist", artist);
		cache_get_field_content(id, "URL", url);
		if(isnull(artist))
        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name);
		else
        	format(query, sizeof(query), "[Music]: {FFFFFF}Now playing - {c91a8c}%s{FFFFFF} by {c91a8c}%s{FFFFFF} [/stopmusic or /togglemusic to stop]", name, artist);
		foreach(Player, i)
		{
		    if(AccInfo[i][pMusic] == 1 && AccInfo[i][pEntrySong] == 0)
		    {
		        PlayAudioStreamForPlayer(i, url);
		        SendClientMessage(i, 0xc91a8cFF, query);
			}
		}
	}
	MusicTimer = 0;
	return 1;
}
CMD:musiclist(playerid, params[])
{
    new query[2048], name[32], artist[24], text[128], rows, fields;
	mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` LIMIT 25 OFFSET %d", AccInfo[playerid][pMusicPage]*25);
	mysql_query(mysql, query);
	cache_get_data(rows, fields, mysql);
	format(query, sizeof(query), "");
	for(new i=0; i < rows; i++)
	{
        cache_get_field_content(i, "Title", name);
        cache_get_field_content(i, "Artist", artist);
        if(isnull(artist))
        	format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}None\n", name);
		else
		    format(text, sizeof(text), "{FF00FF}%s - {FFFFFF}%s\n", name, artist);
		strcat(query, text);
	}
	ShowPlayerDialog(playerid, DIALOG_MUSICLIST, DIALOG_STYLE_MSGBOX, "Music List", query, "Next", "Close");
	return 1;
}
CMD:deletemusic(playerid, params[])
{
	if(UserStats[playerid][Admin] == 0) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}You don't have the permission to use this command!");
	new name[24], artist[24], query[512], rows, fields;
	if(sscanf(params, "s[24]s[24]", name, artist))
	{
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/deletemusic [Title] [Artist]");
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 1]: {808080}If you don't know the artist write \"None\"");
		SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 2]: {808080}Use \" _ \" (underscore) to put spaces in-between names e.g. /deletemusic Rockstar Post_Malone");
	}
	else
	{
        if(!strcmp(artist, "none", true)) format(artist, sizeof(artist), "");
		mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' && `Artist` = '%s'", name, artist);
	   	mysql_query(mysql, query);
	   	cache_get_data(rows, fields, mysql);
	   	cache_delete(Cache:1, mysql);
	   	if(!rows)
		 	SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}No music exists with that title! Try adding a artist with it maybe?");
		else
		{
		    mysql_format(mysql, query, sizeof(query), "DELETE FROM `music` WHERE `Title` = '%s' && `Artist` = '%s'", name, artist);
		   	mysql_query(mysql, query);
		   	cache_get_data(rows, fields, mysql);
		   	cache_delete(Cache:1, mysql);
		    if(!isnull(artist))
				format(query, sizeof(query), "[System]: {FFFFFF}Music deleted sucessfully! [Title: %s, Artist: %s]", name, artist);
			else
			    format(query, sizeof(query), "[System]: {FFFFFF}Music deleted sucessfully! [Title: %s]", name);
			SendClientMessage(playerid, COLOR_BRIGHTRED, query);
		}
	}
    return 1;
}
CMD:updateurl(playerid, params[])
{
	if(UserStats[playerid][Admin] == 0) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}You don't have the permission to use this command!");
	new name[24], artist[24], url[512], query[512], rows, fields;
	if(sscanf(params, "s[24]s[24]s[512]", name, artist, url))
	{
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}/updatemusic [Title] [Artist] [URL]");
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 1]: {808080}If you don't know the artist write \"None\" and URL must end with .mp3");
		SendClientMessage(playerid, COLOR_BRIGHTRED, "[Tip 2]: {808080}Use \" _ \" (underscore) to put spaces in-between names e.g. /deletemusic Rockstar Post_Malone");
	}
	else
	{
	    if(strfind(url, ".mp3", true) == -1) return SendClientMessage(playerid, COLOR_BRIGHTRED, "[Usage]: {808080}Your URL must contain .mp3 at the end.");
	    if(!strcmp(artist, "none", true)) format(artist, sizeof(artist), "");
	    mysql_format(mysql, query, sizeof(query), "SELECT * FROM `music` WHERE `Title` = '%s' && `Artist` = '%s'", name, artist);
	   	mysql_query(mysql, query);
	   	cache_get_data(rows, fields, mysql);
	   	cache_delete(Cache:1, mysql);
	   	if(!rows)
		 	SendClientMessage(playerid, COLOR_BRIGHTRED, "[System]: {808080}No music exists with that title! Try adding a artist with it maybe?");
		else
		{
		    mysql_format(mysql, query, sizeof(query), "UPDATE `music` SET `URL` = '%s' WHERE `Title` = '%s' && `Artist` = '%s'", url, name, artist);
		   	mysql_query(mysql, query);
		   	cache_get_data(rows, fields, mysql);
		   	cache_delete(Cache:1, mysql);
		    if(!isnull(artist))
				format(query, sizeof(query), "[System]: {FFFFFF}Music URL updated! [Title: %s, Artist: %s]", name, artist);
			else
			    format(query, sizeof(query), "[System]: {FFFFFF}Music URL updated! [Title: %s]", name);
			SendClientMessage(playerid, COLOR_BRIGHTRED, query);
		}
	}
    return 1;
}
CMD:stop(playerid, params[])
{
	return cmd_stopmusic(playerid, params);
}
CMD:stopmusic(playerid, params[])
{
    StopAudioStreamForPlayer(playerid);
    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {FFFFFF}You've successfully stopped the current music! (/togglemusic to permanently disable upcoming music)");
    return 1;
}
CMD:togglemusic(playerid, params[])
{
	if(AccInfo[playerid][pMusic] == 1)
	{
	    StopAudioStreamForPlayer(playerid);
	    AccInfo[playerid][pMusic] = 0;
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {FFFFFF}You've successfully {FF0000}disabled {FFFFFF}upcoming music! (/togglemusic again to enable)");
	}
	else
	{
	    AccInfo[playerid][pMusic] = 1;
	    SendClientMessage(playerid, COLOR_BRIGHTRED, "[Music]: {FFFFFF}You've successfully {33AA33}enabled {FFFFFF}upcoming music! (/togglemusic again to disable)");
	}
    return 1;
}