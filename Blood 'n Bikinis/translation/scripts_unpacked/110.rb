#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Make Basic Action Results
  #--------------------------------------------------------------------------
  def make_basic_action_result
    # If attack
    if @active_battler.current_action.basic == 0
      # Set anaimation ID
      @animation1_id = @active_battler.animation1_id
      @animation2_id = @active_battler.animation2_id
      # If action battler is enemy
      if @active_battler.is_a?(Game_Enemy)
        if @active_battler.restriction == 3
          target = $game_troop.random_target_enemy
        elsif @active_battler.restriction == 2
          target = $game_party.random_target_actor
        else
          index = @active_battler.current_action.target_index
          target = $game_party.smooth_target_actor(index)
        end
      end
      # If action battler is actor
      if @active_battler.is_a?(Game_Actor)
        if @active_battler.restriction == 3
          target = $game_party.random_target_actor
        elsif @active_battler.restriction == 2
          target = $game_troop.random_target_enemy
        else
          index = @active_battler.current_action.target_index
          if @active_battler.current_action.fixed
            target = $game_troop.enemies[index]
            @active_battler.current_action.fixed = false
            if target.nil?
              return
            end
          else
            target = $game_troop.smooth_target_enemy(index)
          end
        end
      end
      # Set array of targeted battlers
      @target_battlers = [target]
      fixed_target_exists = target.exist?
      # Apply normal attack results
      for target in @target_battlers
        target.attack_effect(@active_battler)
        # <Z> Refactoring - Method extracted                       # 2016-03-26
        # Counter attacks may be applicable
        check_attack_counter(target)
        # </Z>
      end
      # Go through multiple hits
      hits = @active_battler.get_hit_multiplier
      hits_fixed = @active_battler.get_hit_multiplier_fixed
      fixed = false
      if hits_fixed > hits
        hits = hits_fixed
        fixed = true
        if fixed_target_exists
          fixed_target_index = target.index
        else
          fixed_target_index = random_target_index
          hits += 1
        end
      end
      if hits > 1 && !@active_battler.current_action.forcing
        (hits - 1).times do
          if fixed
            @active_battler.current_action.fixed = fixed
            @active_battler.current_action.target_index = fixed_target_index
          else
            random_target = random_target_index
            break if random_target.nil?
            @active_battler.current_action.target_index = random_target
          end
          @active_battler.current_action.kind = 0
          @active_battler.current_action.basic = 0
          @active_battler.current_action.forcing = true
          add_execute_now_battler(@active_battler)#@execute_now_battlers.enqueue(@active_battler)
          @active_battler.store_current_action
        end unless fixed && fixed_target_index.nil?
      end
      return
    end
    # If guard
    if @active_battler.current_action.basic == 1
      # Display "Guard" in help window
      @help_window.set_text($data_system.words.guard, 1)
      return
    end
    # If escape
    if @active_battler.is_a?(Game_Enemy) and
       @active_battler.current_action.basic == 2
      # Display "Escape" in help window
      @help_window.set_text("Escape", 1)
      # Escape
      @active_battler.escape
      return
    end
    # If doing nothing
    if @active_battler.current_action.basic == 3
      # Clear battler being forced into action
      $game_temp.forcing_battler = nil
      # Shift to step 1
      @phase4_step = 1
      return
    end
  end
  
  def random_target_index
    # If action battler is actor
    if @active_battler.is_a?(Game_Actor)
      random_target = $game_troop.random_target_enemy
    else
      random_target = $game_party.random_target_actor
    end
    return nil if random_target.nil?
    return random_target.index
  end
end
