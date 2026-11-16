#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Party Command Phase
  #--------------------------------------------------------------------------
  def start_phase2
    # Shift to phase 2
    @phase = 2
    # Set actor to non-selecting
    @actor_index = -1
    @active_battler = nil
    # Enable party command window
    @party_command_window.active = true
    @party_command_window.visible = true
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Clear main phase flag
    $game_temp.battle_main_phase = false
    # Clear all party member actions
    $game_party.clear_actions
    # If impossible to input command
    unless $game_party.inputable?
      # Start main phase
      start_phase4
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase)
  #--------------------------------------------------------------------------
  def update_phase2
    @party_command_window.update
    @status_window.update
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase2_trigger
      return
    end
  end
  ##
  # Phase 2 trigger
  #
  def phase2_trigger
    # Branch by party command window cursor position
    case @party_command_window.index
    when 0  # fight
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Start actor command phase
      start_phase3

    when 1 # rush 
      for i in 0...$game_party.actors.size 
        @active_battler = $game_party.actors[i]
        # Set action 
        @active_battler.current_action.kind = 0 
        @active_battler.current_action.basic = 0 
        @active_battler.current_action.target_index = $game_troop.random_target_enemy.index
      end
      start_phase4
    when 2 # escape
      # If it's not possible to escape
      if $game_temp.battle_can_escape == false
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Escape processing
      update_phase2_escape
    end 
  end
  
  #--------------------------------------------------------------------------
  # * Frame Update (party command phase: escape)
  #--------------------------------------------------------------------------
  def update_phase2_escape
    # Calculate enemy agility average
    enemies_agi = 0
    enemies_number = 0
    for enemy in $game_troop.enemies
      if enemy.exist?
        enemies_agi += enemy.agi
        enemies_number += 1
      end
    end
    if enemies_number > 0
      enemies_agi /= enemies_number
    end
    # Calculate actor agility average
    actors_agi = 0
    actors_number = 0
    for actor in $game_party.actors
      if actor.exist?
        actors_agi += actor.agi
        actors_number += 1
      end
    end
    if actors_number > 0
      actors_agi /= actors_number
    end
    # Determine if escape is successful
    success = rand(100) < 50 * actors_agi / enemies_agi
    # If escape is successful
    if success
      # Play escape SE
      $game_system.se_play($data_system.escape_se)
      # Return to BGM before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
    # If escape is failure
    else
      # Clear all party member actions
      $game_party.clear_actions
      # Start main phase
      start_phase4
    end
  end
end
