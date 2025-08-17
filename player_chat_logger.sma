#include <amxmodx>
#include <amxmisc>
#include <cstrike>

#define PLUGIN_NAME    "Player Chat Logger"
#define PLUGIN_VERSION "1.0"
#define PLUGIN_AUTHOR  "sakulmore"

new g_szFilePath[256];

public plugin_init()
{
    register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);

    register_clcmd("say", "HookSay");
    register_clcmd("say_team", "HookSayTeam");

    new datadir[128];
    get_datadir(datadir, charsmax(datadir));
    formatex(g_szFilePath, charsmax(g_szFilePath), "%s/Chats.txt", datadir);

    if (!file_exists(g_szFilePath))
    {
        new fp = fopen(g_szFilePath, "wt");
        if (fp)
        {
            fprintf(fp, "; Chat Logger initialized.%c", 10);
            fclose(fp);
        }
    }
}

public HookSay(id)
{
    if (!is_user_connected(id)) return PLUGIN_CONTINUE;

    new message[192];
    read_args(message, charsmax(message));
    remove_quotes(message);

    if (!message[0]) return PLUGIN_CONTINUE;

    LogChat(id, message, false);
    return PLUGIN_CONTINUE;
}

public HookSayTeam(id)
{
    if (!is_user_connected(id)) return PLUGIN_CONTINUE;

    new message[192];
    read_args(message, charsmax(message));
    remove_quotes(message);

    if (!message[0]) return PLUGIN_CONTINUE;

    LogChat(id, message, true);
    return PLUGIN_CONTINUE;
}

LogChat(id, const message[], bool:teamchat)
{
    new name[64], authid[64], teamName[32];
    get_user_name(id, name, charsmax(name));
    get_user_authid(id, authid, charsmax(authid));

    switch (cs_get_user_team(id))
    {
        case CS_TEAM_T: copy(teamName, charsmax(teamName), "T");
        case CS_TEAM_CT: copy(teamName, charsmax(teamName), "CT");
        case CS_TEAM_SPECTATOR: copy(teamName, charsmax(teamName), "SPECTATOR");
        default: copy(teamName, charsmax(teamName), "UNASSIGNED");
    }

    new fp = fopen(g_szFilePath, "at");
    if (!fp) return;

    if (teamchat)
        fprintf(fp, "[%s-TEAM] %s(%s) : %s%c", teamName, name, authid, message, 10);
    else
        fprintf(fp, "[%s] %s(%s) : %s%c", teamName, name, authid, message, 10);

    fclose(fp);
}