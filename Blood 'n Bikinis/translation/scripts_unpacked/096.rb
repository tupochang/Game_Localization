#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Add an execute now battler
  #--------------------------------------------------------------------------
def add_execute_now_battler(battler)
    @counter_counter ||= 20 # rand(5)*2 + 12
    @counter_counter -= 1
    if @counter_counter > 0
      @execute_now_battlers.enqueue(battler)
    end
  end
  #--------------------------------------------------------------------------
  # * Determine Battle Win/Loss Results
  #--------------------------------------------------------------------------
  def judge
    # If all dead determinant is true, or number of members in party is 0
    if $game_party.all_dead? or $game_party.actors.size == 0
      # If possible to lose
      if $game_temp.battle_can_lose
        # Return to BGM before battle starts
        $game_system.bgm_play($game_temp.map_bgm)
        # Battle ends
        battle_end(2)
        # Return true
        return true
      end
      # Set game over flag
      $game_temp.gameover = true
      # Return true
      return true
    end
    # Return false if even 1 enemy exists
    for enemy in $game_troop.enemies
      next if enemy.index == 0
      if enemy.exist?
        return false
      end
    end
    # Start after battle phase (win)
    start_phase5
    # Return true
    return true
  end
  
  #--------------------------------------------------------------------------
  # * Battle Ends
  #     result : results (0:win 1:lose 2:escape)
  #--------------------------------------------------------------------------
  def battle_end(result)
    # Clear forcing battler
    $game_temp.forcing_battler = nil
    # Clear in battle flag
    $game_temp.in_battle = false
    # Clear entire party actions flag
    $game_party.clear_actions
    # Remove battle states
    for actor in $game_party.actors
      actor.remove_states_battle
    end
    # Clear enemies
    $game_troop.enemies.clear
    # Call battle callback
    if $game_temp.battle_proc != nil
      $game_temp.battle_proc.call(result)
      $game_temp.battle_proc = nil
    end
    # <Z> Update variable so the common event can reason about the results of 
    # the battle
    $game_variables[System::Battle::BATTLE_END_RESULT_VARIABLE] = result
    # </Z>
    # Switch to map screen
    $scene = Scene_Map.new
    # Run common event
    Utility.run_common_event(System::Battle::BATTLE_END_COMMON_EVENT)
  end
end
