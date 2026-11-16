#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Start Main Phase
  #--------------------------------------------------------------------------
  def start_phase4
    # Shift to phase 4
    @phase = 4
    # Turn count
    $game_temp.battle_turn += 1
    # Reset the counter counter
    @counter_counter = 200 # rand(5)*2 + 12
   # Search all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event page
      page = $data_troops[@troop_id].pages[index]
      # If this page span is [turn]
      if page.span == 1
        # Clear action completed flags
        $game_temp.battle_event_flags[index] = false
      end
    end
    # Set actor as unselectable
    @actor_index = -1
    @active_battler = nil
    # Enable party command window
    @party_command_window.active = false
    @party_command_window.visible = false
    # Disable actor command window
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Set main phase flag
    $game_temp.battle_main_phase = true
    if $game_temp.battle_turn > 0
      # Make enemy action
      for enemy in $game_troop.enemies
        enemy.make_action
      end
      # Make action orders
      make_action_orders
    else
      @action_battlers = []
      @first_strike_battlers = []
    end
    # Shift to step 1
    @phase4_step = 1
  end
  #--------------------------------------------------------------------------
  # * Make Action Orders
  #--------------------------------------------------------------------------
  def make_action_orders
    # Initialize @action_battlers array
    @action_battlers = []
    @first_strike_battlers = []
    # Add enemy to @action_battlers array
    for enemy in $game_troop.enemies
      # <Z> Also honor enemy first strike                          # 2016-03-26
      if enemy.has_first_strike?
        @first_strike_battlers.push(enemy)
      else # </Z>
        @action_battlers.push(enemy)
        # <Z>                                                      # 2016-03-26
      end
      # </Z>
    end
    # Add actor to @action_battlers array
    for actor in $game_party.actors
      if actor.has_first_strike?
        @first_strike_battlers.push(actor)
      else
        @action_battlers.push(actor)
      end
    end
    # Decide action speed for all
    for battler in @action_battlers
      battler.make_action_speed
    end
    # Line up action speed in order from greatest to least
    # <Z>                                                          # 2016-03-26
    sort_proc = Proc.new{|a,b| b - a}
    key_proc = Proc.new{|a| a.current_action.speed}
    @action_battlers = @action_battlers.sort_with_shuffle(sort_proc, &key_proc) 
    # </Z>
    if @first_strike_battlers.size > 0
      # Line up first-strike actors
      # <Z>                                                        # 2016-03-26
      @first_strike_battlers = @first_strike_battlers.sort_with_shuffle(sort_proc, &key_proc)
      # </Z>
      # Places the first-strike actors in front
      @action_battlers.unshift(@first_strike_battlers)
      @action_battlers.flatten!
    end
  end  
end

## <Z>                                                             # 2016-03-26
# Array additions
#
class Array
  def shuffle
    sort_by {rand}
  end
  
  def sort_with_shuffle(sort_block, &block)
    # Sort into buckets of identical keys  
    buckets = {}
    for element in self
      sort_key = block.call(element)
      if buckets[sort_key].nil?
        buckets[sort_key] = [element]
      else
        buckets[sort_key] << element
      end
    end
    # Create resulting array
    result = []
    for key in buckets.keys.sort(&sort_block)
      result = result + buckets[key].shuffle
    end
    return result
  end
end  