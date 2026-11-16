#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Actor Command Phase
  #--------------------------------------------------------------------------
  def start_phase3
    # Shift to phase 3
    @phase = 3
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Go to command input for next actor
    phase3_next_actor
  end
  #--------------------------------------------------------------------------
  # * Go to Command Input for Next Actor
  #--------------------------------------------------------------------------
  def phase3_next_actor
    # Loop
    begin
      # Actor blink effect OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # If last actor
      if @actor_index == $game_party.actors.size-1
        # Start main phase
        start_phase4
        return
      end
      # Advance actor index
      @actor_index += 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Once more if actor refuses command input
    end until @active_battler.inputable?
    # Set up actor command window
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # * Go to Command Input of Previous Actor
  #--------------------------------------------------------------------------
  def phase3_prior_actor
    # Loop
    begin
      # Actor blink effect OFF
      if @active_battler != nil
        @active_battler.blink = false
      end
      # If first actor
      if @actor_index == 0
        # Start party command phase
        start_phase2
        return
      end
      # Return to actor index
      @actor_index -= 1
      @active_battler = $game_party.actors[@actor_index]
      @active_battler.blink = true
    # Once more if actor refuses command input
    end until @active_battler.inputable?
    # Set up actor command window
    phase3_setup_command_window
  end
  #--------------------------------------------------------------------------
  # * Actor Command Window Setup
  #--------------------------------------------------------------------------
  def phase3_setup_command_window
    # Disable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Enable actor command window
    @actor_command_window.active = true
    @actor_command_window.visible = true
    # Set actor command window position
    @actor_command_window.x = @actor_index * 160
    # Set index to 0
    @actor_command_window.index = 0
  end
end
