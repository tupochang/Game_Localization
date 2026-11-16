#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Pre-Battle Phase
  #--------------------------------------------------------------------------
  def start_phase1
    # Shift to phase 1
    @phase = 1
    # Clear all party member actions
    $game_party.clear_actions
    # Set up battle event
    setup_battle_event
    # Add a fight to the party members
    $game_party.actors.each {|actor| actor.fights += 1}
  end
  #--------------------------------------------------------------------------
  # * Frame Update (pre-battle phase)
  #--------------------------------------------------------------------------
  def update_phase1
    # Determine win/loss situation
    if judge
      # If won or lost: end method
      return
    end
    # Start party attack phase
    start_phase4
  end
end
