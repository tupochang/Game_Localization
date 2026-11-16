#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Make Skill Action Results
  #--------------------------------------------------------------------------
  def make_skill_action_result
    # Get skill
    @skill = $game_system.skills[@active_battler.current_action.skill_id]
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If unable to use due to SP running out
      unless @active_battler.skill_can_use?(@skill.id)
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Use up SP
    @active_battler.sp -= @active_battler.sp_cost(@skill)
    # Refresh status window
    @status_window.refresh
    # Show skill name on help window
    @help_window.set_text(@skill.name, 1)
    # Set animation ID
    @animation1_id = @skill.animation1_id
    @animation2_id = @skill.animation2_id
    # Set command event ID
    @common_event_id = @skill.common_event_id
    # Set target battlers
    set_target_battlers(@skill.scope)
    # Apply skill effect
    for target in @target_battlers
      target.skill_effect(@active_battler, @skill)
      # Check for skill counter attack
      # <Z>                                                        # 2016-03-26
      if (@skill.atk_f == 1)
        # Treat physical attack based skills the same as normal physical attacks
        check_attack_counter(target)
      else
        check_skill_counter(target)  ## Refactoring - Method extracted
      end
      # </Z>
    end
  end
end