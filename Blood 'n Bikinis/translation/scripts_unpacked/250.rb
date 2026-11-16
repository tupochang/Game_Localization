##
# Encapsulates the achievements and the communication with Steam
#
module Achievements
  # DLL utility functions
  dll_filename = 'UtilsSteam.dll'
  SteamUtils_CallbackReceived = Win32API.new(dll_filename, 'callbackReceived', '', 'i')
  SteamUtils_GetAchievementStatus = Win32API.new(dll_filename, 'getAchievementStatus', 'p', 'i')
  SteamUtils_GetAchievementName = Win32API.new(dll_filename, 'getAchievementName', 'ppi', 'i')
  SteamUtils_GetAchievementDesc = Win32API.new(dll_filename, 'getAchievementDesc', 'ppi', 'i')
  SteamUtils_SetAchievement = Win32API.new(dll_filename, 'setAchievement', 'p', 'i')
  SteamUtils_TestResetAllStats = Win32API.new(dll_filename, 'testResetAllStats', '', 'i')

  # Error values
  RESULT_ABORT = -2
  RESULT_ERROR = -1
  RESULT_FALSE =  0
  RESULT_TRUE  =  1
  
  ##
  # Backbone functions for controlling achievements
  #
  module_function
  def callback_received
    @callback_received ||= (SteamUtils_CallbackReceived.call == RESULT_TRUE)
    return @callback_received
  end
  
  ##
  # Getters
  #
  def unlocked?(achievement_symbol)
    return nil unless callback_received
    apiname = SymbolToAPIName[achievement_symbol]
    status = SteamUtils_GetAchievementStatus.call(apiname)
    return status == RESULT_TRUE
  end
  
  def name(achievement_symbol)
    return nil unless callback_received
    apiname = SymbolToAPIName[achievement_symbol]
    name_buffer = " " * 256 + "\0"
    SteamUtils_GetAchievementName.call(apiname, name_buffer, 256)
    name = name_buffer.rstrip.rstrip # Two strips may be needed
    return name
  end
  
  def description(achievement_symbol)
    return nil unless callback_received
    apiname = SymbolToAPIName[achievement_symbol]
    description_buffer = " " * 256 + "\0"
    SteamUtils_GetAchievementDesc.call(apiname, description_buffer, 256)
    description = description_buffer.rstrip.rstrip # Two strips may be needed
    return description
  end
  
  ##
  # Modify achievement status
  #
  def steamapi_unlock(achievement_symbol)
    return nil unless callback_received
    return false if unlocked?(achievement_symbol)
    # Try to unlock
    apiname = SymbolToAPIName[achievement_symbol]
    set_result = SteamUtils_SetAchievement.call(apiname)
    return set_result == RESULT_TRUE
  end
  
  def reset_all
    return false unless callback_received
    reset_result = SteamUtils_TestResetAllStats.call
    return reset_result == RESULT_TRUE
  end
end