#==============================================================================
# ** Scene_Equip
#------------------------------------------------------------------------------
#  This class performs equipment screen processing.
#==============================================================================

class Scene_Equip < Scene_Base
  EFFECT_TEXT_MAX_LENGTH = 230 - 4
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_index : actor index
  #     equip_index : equipment index
  #--------------------------------------------------------------------------
  def initialize(actor_index = 0, equip_index = 0)
    @actor_index = actor_index
    @equip_index = equip_index
    
    # Create a bitmap which is used for determining the size of element and
    # state effect strings
    @size_bitmap = Bitmap.new(32, 32)
    @size_bitmap.font.size = System::Menu::EFFECT_FONT_SIZE
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Get actor
    @actor = $game_party.actors[@actor_index]
    # Make windows
    @help_window = Window_Help.new
    @left_window = Window_EquipLeft.new(@actor)
    @right_window = Window_EquipRight.new(@actor)
    @item_window1 = Window_EquipItem.new(@actor, 0)
    @item_window2 = Window_EquipItem.new(@actor, 1)
    @item_window3 = Window_EquipItem.new(@actor, 2)
    @item_window4 = Window_EquipItem.new(@actor, 3)
    @item_window5 = Window_EquipItem.new(@actor, 4)
    # Add as a mouse enabled windows
    mouse_windows << @right_window
    mouse_windows << @item_window1
    mouse_windows << @item_window2
    mouse_windows << @item_window3
    mouse_windows << @item_window4
    mouse_windows << @item_window5
    # Set owners
    @right_window.owner = self
    @item_window1.owner = self
    @item_window2.owner = self
    @item_window3.owner = self
    @item_window4.owner = self
    @item_window5.owner = self
    # Associate help window
    @right_window.help_window = @help_window
    @item_window1.help_window = @help_window
    @item_window2.help_window = @help_window
    @item_window3.help_window = @help_window
    @item_window4.help_window = @help_window
    @item_window5.help_window = @help_window
    # Set cursor position
    @right_window.index = @equip_index
    refresh
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Mouse update
      mouse_update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @help_window.dispose
    @left_window.dispose
    @right_window.dispose
    @item_window1.dispose
    @item_window2.dispose
    @item_window3.dispose
    @item_window4.dispose
    @item_window5.dispose
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    @item_window1.visible = (@right_window.index == 0)
    @item_window2.visible = (@right_window.index == 1)
    @item_window3.visible = (@right_window.index == 2)
    @item_window4.visible = (@right_window.index == 3)
    @item_window5.visible = (@right_window.index == 4)
    item1 = @right_window.item
    case @right_window.index
    when 0
      @item_window = @item_window1
      newmode = 0
    when 1
      @item_window = @item_window2
      newmode = 1
    when 2
      @item_window = @item_window3
      newmode = 1
    when 3
      @item_window = @item_window4
      newmode = 1
    when 4
      @item_window = @item_window5
      newmode = 1
    end
    if newmode != @left_window.mode
      @left_window.mode = newmode
      @left_window.refresh
    end
    if @right_window.active
      @left_window.set_new_parameters(nil, nil, nil, nil, nil, nil, nil, nil,
        make_elem_text(item1), make_stat_text(item1))
    end
    if @item_window.active
      item2 = @item_window.item
      last_hp = @actor.hp
      last_sp = @actor.sp
      old_atk = @actor.atk
      old_pdef = @actor.pdef
      old_mdef = @actor.mdef
      old_str = @actor.str
      old_dex = @actor.dex
      old_agi = @actor.agi
      old_int = @actor.int
      old_eva = @actor.eva
      @actor.equip(@right_window.index, item2 == nil ? 0 : item2.id, false)
      new_atk = @actor.atk
      new_pdef = @actor.pdef
      new_mdef = @actor.mdef
      new_str = @actor.str
      new_dex = @actor.dex
      new_agi = @actor.agi
      new_int = @actor.int
      new_eva = @actor.eva
      @left_window.changes = [0, 0, 0, 0, 0, 0, 0, 0]
      if new_atk > old_atk
        @left_window.changes[0] = 1
      end
      if new_atk < old_atk
        @left_window.changes[0] = -1
      end
      if new_pdef > old_pdef
        @left_window.changes[1] = 1
      end
      if new_pdef < old_pdef
        @left_window.changes[1] = -1
      end
      if new_mdef > old_mdef
        @left_window.changes[2] = 1
      end
      if new_mdef < old_mdef
        @left_window.changes[2] = -1
      end
       if new_str > old_str
        @left_window.changes[3] = 1
      end
      if new_str < old_str
        @left_window.changes[3] = -1
      end
        if new_dex > old_dex
        @left_window.changes[4] = 1
      end
      if new_dex < old_dex
        @left_window.changes[4] = -1
      end
      if new_agi > old_agi
        @left_window.changes[5] = 1
      end
      if new_agi < old_agi
        @left_window.changes[5] = -1
      end
      if new_int > old_int
        @left_window.changes[6] = 1
      end
      if new_int < old_int
        @left_window.changes[6] = -1
      end
      if new_eva > old_eva
        @left_window.changes[7] = 1
      end
      if new_eva < old_eva
        @left_window.changes[7] = -1
      end
      elem_text = make_elem_text(item2)
      stat_text = make_stat_text(item2)
      @actor.equip(@right_window.index, item1 == nil ? 0 : item1.id, false)
      @actor.hp = last_hp
      @actor.sp = last_sp
      @left_window.set_new_parameters(new_atk, new_pdef, new_mdef, new_str,
      new_dex, new_agi, new_int, new_eva, elem_text, stat_text)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update windows
    @left_window.update
    @right_window.update
    @item_window.update
    refresh
    # If right window is active: call update_right
    if @right_window.active
      update_right
      return
    end
    # If item window is active: call update_item
    if @item_window.active
      update_item
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when right window is active)
  #--------------------------------------------------------------------------
  def update_right
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to menu screen
      $scene = Scene_Menu.new(2)
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      right_trigger
      return
    end
    # If R button was pressed
    if Input.trigger?(Input::R)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To next actor
      @actor_index += 1
      @actor_index %= $game_party.actors.size
      # Switch to different equipment screen
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
    # If L button was pressed
    if Input.trigger?(Input::L)
      # Play cursor SE
      $game_system.se_play($data_system.cursor_se)
      # To previous actor
      @actor_index += $game_party.actors.size - 1
      @actor_index %= $game_party.actors.size
      # Switch to different equipment screen
      $scene = Scene_Equip.new(@actor_index, @right_window.index)
      return
    end
  end
  ##
  # Right window trigger
  #
  def right_trigger
    # If equipment is fixed
    if @actor.equip_fix?(@right_window.index) ||
      (!@right_window.item.nil? && @right_window.item.cursed)
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Activate item window
    @right_window.active = false
    @item_window.active = true
    @item_window.index = 0
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when item window is active)
  #--------------------------------------------------------------------------
  def update_item
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Activate right window
      @right_window.active = true
      @item_window.active = false
      @item_window.index = -1
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      item_trigger
      return
    end
  end
  ##
  # Item window trigger
  #
  def item_trigger
    # Play equip SE
    $game_system.se_play($data_system.equip_se)
    # Get currently selected data on the item window
    item = @item_window.item
    # Change equipment
    @actor.equip(@right_window.index, item == nil ? 0 : item.id)
    # Activate right window
    @right_window.active = true
    @item_window.active = false
    @item_window.index = -1
    # Remake right window and item window contents
    @right_window.refresh
    @item_window.refresh
  end
  # --------------------------------
  def make_elem_text(item)
    text_arr = ["", ""]
    text_index = 0
    new_text = ""
    flag = false
    elements = []
    
    # Find elemental set
    if item.is_a?(RPG::Weapon) || item.is_a?(Game_Weapon)
      elements = item.element_set 
    elsif item.is_a?(RPG::Armor) || item.is_a?(Game_Armor)
      elements = item.guard_element_set
    end
    
    # Create text
    for i in elements
      if flag
        new_text += "  "
      end
      flag = true
      new_text += $data_system.elements[i]
      
      # Add to current text string
      if @size_bitmap.text_size(new_text).width >= EFFECT_TEXT_MAX_LENGTH
        if text_index >= 1
          # Too many states to be displayed
          text_arr[text_index] = text_arr[text_index] + "  ..."
          return text_arr
        end
        text_index += 1
        new_text = $data_system.elements[i]
      end
      text_arr[text_index] = new_text
    end
    return text_arr
  end
  # --------------------------------
  def make_stat_text(item)
    text_arr = ["", ""]
    text_index = 0
    new_text = ""
    flag = false
    states = []
    
    # Find state set
    if item.is_a?(RPG::Weapon) || item.is_a?(Game_Weapon)
      states = item.plus_state_set 
    elsif item.is_a?(RPG::Armor) || item.is_a?(Game_Armor)
      states = item.guard_state_set
    end
    
    # Create text
    for i in states
      if flag
        new_text += "  "
      end
      flag = true
      new_text += $data_states[i].name
      
      # Add to current text string
      if @size_bitmap.text_size(new_text).width >= EFFECT_TEXT_MAX_LENGTH
        if text_index >= 1
          # Too many states to be displayed
          text_arr[text_index] = text_arr[text_index] + "  ..."
          return text_arr
        end
        text_index += 1
        new_text = $data_states[i].name
      end
      text_arr[text_index] = new_text

    end
    return text_arr
  end
  ##
  # Event fired
  #
  def fireEvent(event)
    right_trigger if event.sender == @right_window
    item_trigger if event.sender == @item_window
  end
end
