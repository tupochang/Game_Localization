#==============================================================================
# ** Scene_Load
#------------------------------------------------------------------------------
#  Aliases and uses the on_decision method to reset $game_quests on the proper
#  time.
#==============================================================================
 
class Scene_Load < Scene_File
  # Check if the alias already exists (To avoid F12 errors)
  unless self.method_defined?(:zeriab_questbook_scene_load_on_decision)
    alias zeriab_questbook_scene_load_on_decision :on_decision
  end
  def on_decision(*args)
    # Call the original method
    zeriab_questbook_scene_load_on_decision(*args)
    # Check if the scene has changed
    unless $scene == self
      # Reset quest data
      $game_quests.reset
    end
  end
end