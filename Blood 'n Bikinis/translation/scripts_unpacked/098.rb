#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # If battle event is running
    if $game_system.battle_interpreter.running? && !@message_window.visible
      # Update interpreter
      $game_system.battle_interpreter.update
      if !$game_system.battle_interpreter.running? && @old_interpreter != nil
        $game_system.battle_interpreter = @old_interpreter
        @old_interpreter = nil
      end
      update_state_windows
      # If a battler which is forcing actions doesn't exist
      if $game_temp.forcing_battler == nil
        # If battle event has finished running
        unless $game_system.battle_interpreter.running?
          # Rerun battle event set up if battle continues
          unless judge
            setup_battle_event
          end
        end
        # If not after battle phase
        if @phase != 5
          # Refresh status window
          @status_window.refresh
        end
      end
    end
    # Update state windows?
    if @update_state_windows
      speed = [64,32,16,8,4,2,1]
      for window in @state_windows
        window.update
        next if window.y == window.limit || !window.visible
        i = 0
        y = speed[i]
        while window.y < window.limit + y && y != 0
          i += 1
          y = speed[i]
          y = 0 if y.nil?
        end
        window.y -= y
      end
      # Check if the state windows still must be updated
      @update_state_windows = false
      for window in @state_windows
        if window.visible
          @update_state_windows = true
        end
      end
    end
    # Update enemy state windows?
    if @update_enemy_state_windows
      # Check if the state windows still must be updated
      @update_enemy_state_windows = false
      for window in @state_enemy_windows
        if window.visible
          window.update
          @update_enemy_state_windows = true
        end
      end
    end
    # Update system (timer) and screen
    $game_system.update
    $game_screen.update
    # If timer has reached 0
    if $game_system.timer_working and $game_system.timer == 0
      # Abort battle
      $game_temp.battle_abort = true
    end
    # Update windows
#    @help_window.update
#    @party_command_window.update
#    @actor_command_window.update
#    @status_window.update
    @message_window.update
    # Update sprite set
    @spriteset.update
    # If transition is processing
    if $game_temp.transition_processing
      # Clear transition processing flag
      $game_temp.transition_processing = false
      # Execute transition
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
    # If message window is showing
    if $game_temp.message_window_showing
      return
    end
    # If effect is showing
    if @spriteset.effect?
      return
    end
    # If game over
    if $game_temp.gameover
      # Switch to game over screen
      $scene = Scene_Gameover.new
      return
    end
    # If returning to title screen
    if $game_temp.to_title
      # Switch to title screen
      $scene = Scene_Title.new
      return
    end
    # If battle is aborted
    if $game_temp.battle_abort
      # Return to BGM used before battle started
      $game_system.bgm_play($game_temp.map_bgm)
      # Battle ends
      battle_end(1)
      return
    end
    # If waiting
    if @wait_count > 0
      # Decrease wait count
      @wait_count -= 1
      return
    end
    # If battler forcing an action doesn't exist,
    # and battle event is running
    if $game_temp.forcing_battler == nil and
       $game_system.battle_interpreter.running?
      return
    end
    # Branch according to phase
    case @phase
    when 1  # pre-battle phase
      update_phase1
    when 2  # party command phase
      update_phase2
    when 3  # actor command phase
      update_phase3
    when 4  # main phase
      update_phase4
    when 5  # after battle phase
      update_phase5
    end
  end
  
  ##
  # Update the mouse
  #
  def mouse_update
    return unless Mouse.enabled
    super
    if @enemy_arrow != nil
      @enemy_arrow.mouse_update
    end
    if @actor_arrow != nil
      @actor_arrow.mouse_update
    end
  end
end
