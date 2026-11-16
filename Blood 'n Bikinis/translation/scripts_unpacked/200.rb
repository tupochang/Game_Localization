#==============================================================================
# ** Questbook
#------------------------------------------------------------------------------
# Zeriab
# 1.2
# 2007-10-01 (year-month-day)
#==============================================================================

#==============================================================================
# ** Scene_Questbook
#------------------------------------------------------------------------------
#  This window designates the quest selection on the questbook screen.
#==============================================================================

class Scene_Questbook < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(scene = Scene_Menu.new(5))
    # Gets the active quests
    @active_questset = $game_quests.get_active_quests
    # Gets the completed quests
    @completed_questset = $game_quests.get_completed_quests
    # Starts at the main_menu
    @last_index = 0
    # The completed quests starts in the top-left corner
    @other_index = 0
    # Active quests are shown when the questlog has opened
    @active_quests = true
    # Sets the current quest set
    @current_questset = @active_questset
    # The next scene it will skip to is the scene given
    @next_scene = scene
  end # def
  
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # The background image
    @back_sprite = Sprite.new(Viewport.new(0,0,640,480))
    picname = BACK_PICS[$game_variables[BACK_VAR]]
    unless picname.is_a?(String)
      picname = BACK_PICS["standard"]
    end
    @back_sprite.bitmap = RPG::Cache.picture(BACKGROUND_DIR+picname)
    # Quest selection window
    @quest_select = Window_Questbook.new(@current_questset)
    @quest_select.opacity = WINDOW_OPACITY
    # Add as a mouse enabled window
    mouse_windows << @quest_select
    # Set owner
    @quest_select.owner = self
    # Quest info-header window
    @quest_header = Window_Questbook_Header.new(@current_questset[0])
    @quest_header.opacity = WINDOW_OPACITY
    # Quest information window
    @quest_info = Window_Questbook_Info.new
    @quest_info.opacity = WINDOW_OPACITY
    @quest_info.visible = false
    # Execute transition
    Graphics.transition
    # Scene Objects
    @scene_objects = [@back_sprite, @quest_select, @quest_header, @quest_info]
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Mouse update
      mouse_update
      # Updates Scene Objects
      @scene_objects.each { |x| x.update}
      ## Frame update
      update
      # Abort loop if screen is changed
      break if $scene != self
    end # loop
    # Prepare for transition
    Graphics.freeze
    # Dispose Scene Objects
    @scene_objects.each { |x| x.dispose }
  end # def
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def switch
    # Switch to the previously remembered index (In case L or R was used)
    tmp = @quest_select.index
    @quest_select.index = @other_index
    @other_index = tmp
    # Plays the Cursor sound effect
    $game_system.se_play($data_system.cursor_se)
    # Checks if there are active quests shown
    if @active_quests
      # Completed quests is to be shown. (Active quest NOT shown)
      @active_quests = false
      # Sets the current questset to the completed questset
      @current_questset = @completed_questset
    else
      # Active quests is to be shown.
      @active_quests = true
      # Sets the current questset to the active questset
      @current_questset = @active_questset
    end # if
    # Sets the data in the selection window
    @quest_select.set_data(@current_questset, @active_quests)
    # Checks if there are any fields
    if @quest_select.index > -1
      # Opdates the header
      @quest_header.refresh(get_quest_header(0))
    else
      # Opdates the header
      @quest_header.refresh(1)
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # If RIGHT Button Is Pressed
    if Input.trigger?(Input::RIGHT) && !@quest_info.visible
      # Checks if there are any items to select.
      if @quest_select.index <= -1
        # Switches between active and completed quests
        switch
      end # if
    end # if
    # If LEFT Button Is Pressed
    if Input.trigger?(Input::LEFT) && !@quest_info.visible
      # Checks if the last index is the same as the current. (All left)
      if @last_index == @quest_select.index || @quest_select.index <= -1
        # Switches between active and completed quests
        switch
      end # if
    end # if
    # Checks if the index in @quest_select have changed
    if @last_index != @quest_select.index && @quest_select.index > -1
      # Updates the last_index
      @last_index = @quest_select.index
      # Updates the header
      @quest_header.refresh(get_quest_header(@last_index))
    end # if
    # If C Button Is Pressed
    if Input.trigger?(Input::C) && @quest_select.index > -1
      quest_trigger
    end # if
    # If B Button Is Pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to next scene
      $scene = @next_scene unless @quest_info.visible
      # Changes the quest info to become invisible
      @quest_info.visible = false
      # The quest select is active as the info is not visible
      @quest_select.active = true
      # Refreshes the quest info
      @quest_info.refresh(@current_questset[@quest_select.index])
      # Stops processing this method
      return
    end # if
    # If L Button Is Pressed
    if Input.trigger?(Input::L)
      switch
    end # if
    # If R Button Is Pressed
    if Input.trigger?(Input::R)
      switch
    end # if
  end # def
  ##
  # Quest selection window trigger
  #
  def quest_trigger
    # Checks that a quest is not select. (So it must be the main menu)
    if (@quest_select.index >= @current_questset.size)
      # Checks if the main menu icon is selected
      if (@quest_select.index >= @current_questset.size + 1)
        # Plays the Cancel sound effect
        $game_system.se_play($data_system.cancel_se)
        # Changes the scene to the main menu
        $scene = Scene_Menu.new(5)
      else
        switch
      end # if
      # Stops processing this method
      return
    end
    # Plays the Decision sound effect
    $game_system.se_play($data_system.decision_se)
    # Change the visibility of the quest_info
    # Visible => Invisible, Invisible => Visible        
    @quest_info.visible = !@quest_info.visible
    # The quest select is not active if the info is visible, else it is
    @quest_select.active = !@quest_info.visible
    # Refreshes the quest info
    @quest_info.refresh(@current_questset[@quest_select.index])
  end
  ##
  # Event fired
  #
  def fireEvent(event)
    if @quest_select.index > -1
      quest_trigger
    end
  end
  ##
  # Retrieve the quest for the header
  #
  def get_quest_header(index)
    if index < @current_questset.size
      return @current_questset[index]
    elsif index < @current_questset.size + 1
      if @active_quests
        return :completed
      else
        return :active
      end
    else
      return :mainmenu
    end
  end
end # class