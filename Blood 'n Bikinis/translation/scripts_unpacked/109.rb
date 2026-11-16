#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Frame Update (main phase)
  #--------------------------------------------------------------------------
  def update_phase4
    @status_window.update
    case @phase4_step
    when 1
      update_phase4_step1
    when 2
      update_phase4_step2
    when 3
      update_phase4_step3
    when 4
      update_phase4_step4
    when 5
      update_phase4_step5
    when 6
      update_phase4_step6
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 1 : action preparation)
  #--------------------------------------------------------------------------
  def update_phase4_step1
    # Hide help window
    @help_window.visible = false
    # Determine win/loss
    if judge
      # If won, or if lost : end method
      return
    end
    # If an action forcing battler doesn't exist
    if $game_temp.forcing_battler == nil
      # Set up battle event
      setup_battle_event
      # If battle event is running
      if $game_system.battle_interpreter.running?
        return
      end
    end
    # If no actionless battlers exist (all have performed an action)
    if @action_battlers.size == 0 && @execute_now_battlers.empty?
      # Start party command phase
      start_phase2
      return
    end
    # Initialize animation ID and common event ID
    @animation1_id = 0
    @animation2_id = 0
    @common_event_id = 0
    # If any execute now battlers exist
    if @execute_now_battlers.empty?
      # Shift from head of actionless battlers
      @active_battler = @action_battlers.shift
    else
      # Take the next execute now battler and remove it from the list
      @active_battler = @execute_now_battlers.dequeue
      while @active_battler != nil &&
            @active_battler.current_action.fixed
        @active_battler.current_action.fixed = false
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.exist?
          break
        end
        @active_battler.retrieve_next_action
        @active_battler = @execute_now_battlers.dequeue
        if @execute_now_battlers.empty?
          @active_battler = @action_battlers.shift
          break
        end
      end
    end
    #p @active_battler
    # If already removed from battle
    if @active_battler.nil? || @active_battler.index == nil
      return
    end
    # Slip damage
    if @active_battler.hp > 0
      if @active_battler.get_slip_damage != 0
        @active_battler.slip_damage_effect
        @active_battler.damage_pop = true
      end
      if @active_battler.regen_effect
        @active_battler.damage_pop = true
      end
    end
    # Natural removal of states
    @active_battler.remove_states_auto
    # Refresh status window
    @status_window.refresh
    # Check for state changes
    update_state_windows
    # Shift to step 2
    @phase4_step = 2
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 2 : start action)
  #--------------------------------------------------------------------------
  def update_phase4_step2
    # If not a forcing action
    unless @active_battler.current_action.forcing
      # If restriction is [normal attack enemy] or [normal attack ally]
      if @active_battler.restriction == 2 or @active_battler.restriction == 3
        # Set attack as an action
        @active_battler.current_action.kind = 0
        @active_battler.current_action.basic = 0
      end
      # If restriction is [cannot perform action]
      if @active_battler.restriction == 4
        # Clear battler being forced into action
        $game_temp.forcing_battler = nil
        # Shift to step 1
        @phase4_step = 1
        return
      end
    end
    # Clear target battlers
    @target_battlers = []
    # Branch according to each action
    case @active_battler.current_action.kind
    when 0  # basic
      make_basic_action_result
    when 1  # skill
      make_skill_action_result
    when 2  # item
      make_item_action_result
    end
    # Retrieve next action if one is present
    @active_battler.retrieve_next_action
    # Shift to step 3
    if @phase4_step == 2
      @phase4_step = 3
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 3 : animation for action performer)
  #--------------------------------------------------------------------------
  def update_phase4_step3
    # Animation for action performer (if ID is 0, then white flash)
    if @animation1_id == 0
      @active_battler.white_flash = true
    else
      @active_battler.animation_id = @animation1_id
      @active_battler.animation_hit = true
    end
    # Shift to step 4
    @phase4_step = 4
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 4 : animation for target)
  #--------------------------------------------------------------------------
  def update_phase4_step4
    # Animation for target
    for target in @target_battlers
      target.animation_id = @animation2_id
      target.animation_hit = (target.damage != "Miss")
    end
    # Animation has at least 8 frames, regardless of its length
    @wait_count = 8
    # Shift to step 5
    @phase4_step = 5
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 5 : damage display)
  #--------------------------------------------------------------------------
  def update_phase4_step5
    # Hide help window
    @help_window.visible = false
    # Refresh status window
    @status_window.refresh
    # Check for state changes
    update_state_windows
    # Display damage
    for target in @target_battlers
      if target.damage != nil
        target.damage_pop = true
      end
    end
    # Shift to step 6
    @phase4_step = 6
  end
  #--------------------------------------------------------------------------
  # * Frame Update (main phase step 6 : refresh)
  #--------------------------------------------------------------------------
  def update_phase4_step6
    # Clear battler being forced into action
    $game_temp.forcing_battler = nil
    # If common event ID is valid
    if @common_event_id > 0
      # Set up event
      if $game_system.battle_interpreter.running?
        @old_interpreter = $game_system.battle_interpreter.dup
      end
      common_event = $data_common_events[@common_event_id]
      $game_system.battle_interpreter.setup(common_event.list, 0)
    end
    # Shift to step 1
    @phase4_step = 1
  end
end
