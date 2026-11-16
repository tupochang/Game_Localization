#==============================================================================
# ** Scene_Title
#------------------------------------------------------------------------------
#  Aliases and uses the command_new_game method to reset $game_quests on the proper
#  time.
#==============================================================================

class Scene_Title < Scene_Base
  # Check if the alias already exists (To avoid F12 errors)
  unless self.method_defined?(:zeriab_questbook_scene_title_command_new_game)
    alias zeriab_questbook_scene_title_command_new_game :command_new_game
  end
  def command_new_game(*args)
    # Call the original method
    zeriab_questbook_scene_title_command_new_game(*args)
    # Reset quest data
    $game_quests.reset
  end
end
