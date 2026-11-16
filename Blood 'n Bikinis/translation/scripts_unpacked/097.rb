#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Battle Event Setup
  #--------------------------------------------------------------------------
  def setup_battle_event
    # If battle event is running
    if $game_system.battle_interpreter.running?
      return
    end
    # Search for all battle event pages
    for index in 0...$data_troops[@troop_id].pages.size
      # Get event pages
      page = $data_troops[@troop_id].pages[index]
      # Make event conditions possible for reference with c
      c = page.condition
      # Go to next page if no conditions are appointed
      unless c.turn_valid or c.enemy_valid or
             c.actor_valid or c.switch_valid
        next
      end
      # Go to next page if action has been completed
      if $game_temp.battle_event_flags[index]
        next
      end
      # Confirm turn conditions
      if c.turn_valid
        n = $game_temp.battle_turn
        a = c.turn_a
        b = c.turn_b
        if (b == 0 and n != a) or
           (b > 0 and (n < 1 or n < a or n % b != a % b))
          next
        end
      end
      # Confirm enemy conditions
      if c.enemy_valid
        enemy = $game_troop.enemies[c.enemy_index]
        if enemy == nil or enemy.hp * 100.0 / enemy.maxhp > c.enemy_hp
          next
        end
      end
      # Confirm actor conditions
      if c.actor_valid
        actor = $game_actors[c.actor_id]
        if actor == nil or actor.hp * 100.0 / actor.maxhp > c.actor_hp
          next
        end
      end
      # Confirm switch conditions
      if c.switch_valid
        if $game_switches[c.switch_id] == false
          next
        end
      end
      # Set up event
      $game_system.battle_interpreter.setup(page.list, 0)
      # If this page span is [battle] or [turn]
      if page.span <= 1
        # Set action completed flag
        $game_temp.battle_event_flags[index] = true
      end
      return
    end
  end
end
