begin
  SteamAPI_Init = Win32API.new("steam_api.dll", "SteamAPI_Init", [], 'l')
  SteamAPI_Shutdown = Win32API.new("steam_api.dll", "SteamAPI_Shutdown", [], 'v')
  
  steam_init = SteamAPI_Init.call
  if steam_init != 1
    p 'Please launch this game from your Steam client.'
    exit
  end
end
