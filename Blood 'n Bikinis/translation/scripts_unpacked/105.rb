#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase)
  #--------------------------------------------------------------------------
  def update_phase3
    @help_window.update
    @actor_command_window.update
    # If enemy arrow is enabled
    if @enemy_arrow != nil
      update_phase3_enemy_select
    # If actor arrow is enabled
    elsif @actor_arrow != nil
      update_phase3_actor_select
    # If skill window is enabled
    elsif @skill_window != nil
      update_phase3_skill_select
    # If item window is enabled
    elsif @item_window != nil
      update_phase3_item_select
    # If actor command window is enabled
    elsif @actor_command_window.active
      update_phase3_basic_command
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : basic command)
  #--------------------------------------------------------------------------
  def update_phase3_basic_command
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Go to command input for previous actor
      phase3_prior_actor
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase3_basic_trigger
      return
    end
  end
  ##
  # Phase 3 basic command trigger
  #
  def phase3_basic_trigger
    # Branch by actor command window cursor position
    case @actor_command_window.index
    when 0  # attack
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.kind = 0
      @active_battler.current_action.basic = 0
      # Start enemy selection
      start_enemy_select
    when 1  # skill
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.kind = 1
      # Start skill selection
      start_skill_select
    when 2  # guard
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.kind = 0
      @active_battler.current_action.basic = 1
      # Go to command input for next actor
      phase3_next_actor
    when 3  # item
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Set action
      @active_battler.current_action.kind = 2
      # Start item selection
      start_item_select
    end
    # Update the mouse
    Mouse.update
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : skill selection)
  #--------------------------------------------------------------------------
  def update_phase3_skill_select
    # Make skill window visible
    @skill_window.visible = true
    # Update skill window
    @skill_window.update
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End skill selection
      end_skill_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase3_skill_trigger
      return
    end
  end
  ##
  # Phase 3 skill window trigger
  #
  def phase3_skill_trigger
    # Get currently selected data on the skill window
    @skill = @skill_window.skill
    # If it can't be used
    if @skill == nil or not @active_battler.skill_can_use?(@skill.id)
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.skill_id = @skill.id
    # Make skill window invisible
    @skill_window.visible = false
    # If effect scope is single enemy
    if @skill.scope == 1
      # Start enemy selection
      start_enemy_select
    # If effect scope is single ally
    elsif @skill.scope == 3 or @skill.scope == 5
      # Start actor selection
      start_actor_select
    # If effect scope is not single
    else
      # End skill selection
      end_skill_select
      # Go to command input for next actor
      phase3_next_actor
    end
    Mouse.update
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : item selection)
  #--------------------------------------------------------------------------
  def update_phase3_item_select
    # Make item window visible
    @item_window.visible = true
    # Update item window
    @item_window.update
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End item selection
      end_item_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase3_item_trigger
      return
    end
  end
  ##
  # Phase 3 item window trigger
  #
  def phase3_item_trigger
    # Get currently selected data on the item window
    @item = @item_window.item
    # If it can't be used
    unless $game_party.item_can_use?(@item.id)
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.item_id = @item.id
    # Make item window invisible
    @item_window.visible = false
    # If effect scope is single enemy
    if @item.scope == 1
      # Start enemy selection
      start_enemy_select
    # If effect scope is single ally
    elsif @item.scope == 3 or @item.scope == 5
      # Start actor selection
      start_actor_select
    # If effect scope is not single
    else
      # End item selection
      end_item_select
      # Go to command input for next actor
      phase3_next_actor
    end
    Mouse.update
  end
  #--------------------------------------------------------------------------
  # * Frame Updat (actor command phase : enemy selection)
  #--------------------------------------------------------------------------
  def update_phase3_enemy_select
    # Update enemy arrow
    @enemy_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End enemy selection
      end_enemy_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase3_enemy_trigger
    end
  end
  ##
  # Phase 3 enemy selection trigger
  #
  def phase3_enemy_trigger
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.target_index = @enemy_arrow.index
    # End enemy selection
    end_enemy_select
    # If skill window is showing
    if @skill_window != nil
      # End skill selection
      end_skill_select
    end
    # If item window is showing
    if @item_window != nil
      # End item selection
      end_item_select
    end
    # Go to command input for next actor
    phase3_next_actor
  end
  #--------------------------------------------------------------------------
  # * Frame Update (actor command phase : actor selection)
  #--------------------------------------------------------------------------
  def update_phase3_actor_select
    # Update actor arrow
    @actor_arrow.update
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # End actor selection
      end_actor_select
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      phase3_actor_trigger
    end
  end
  ##
  # Phase 3 actor selection trigger
  #
  def phase3_actor_trigger
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Set action
    @active_battler.current_action.target_index = @actor_arrow.index
    # End actor selection
    end_actor_select
    # If skill window is showing
    if @skill_window != nil
      # End skill selection
      end_skill_select
    end
    # If item window is showing
    if @item_window != nil
      # End item selection
      end_item_select
    end
    # Go to command input for next actor
    phase3_next_actor
  end
end
