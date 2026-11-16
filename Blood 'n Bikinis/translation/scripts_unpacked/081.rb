#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs menu screen processing.
#==============================================================================

class Scene_Menu < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make command window
    s1 = $data_system.words.item
    s2 = $data_system.words.skill
    s3 = $data_system.words.equip
    s4 = "INFO"
    s5 = "TEAM"
    s6 = "GIRLS"
    s7 = "SAVE"
    s8 = "EXIT"
    s9 = "OPTIONS"
    # <Z>
    @command_window = Window_MenuCommand.new(140, [s1,s2,s3,s4,s5,s6,s7,s8,s9])
    # </Z>
    @command_window.index = @menu_index
    # Add as a mouse enabled window
    mouse_windows << @command_window
    # Set owner
    @command_window.owner = self
    # If number of party members is 0
    if $game_party.actors.size == 0
      # Disable items, skills, equipment, and status and party switcher
      @command_window.disable_item(0)
      @command_window.disable_item(1)
      @command_window.disable_item(2)
      @command_window.disable_item(3)
      @command_window.disable_item(4)
      @command_window.disable_item(5)
      @command_window.disable_item(6)
      @command_window.disable_item(8)
    end

    # If save is forbidden
    if $game_system.save_disabled
      # Disable save
      @command_window.disable_item(6)
    end
    
    if $game_switches[40] == false
      @command_window.disable_item(4)
    end  
    # Make play time window
    @playtime_window = Window_PlayTime.new
    @playtime_window.x = 0
    @playtime_window.y = 328
    # Make steps window
    @steps_window = Window_Steps.new
    @steps_window.x = 0
    @steps_window.y = 600
    # Make gold window
    @gold_window = Window_Gold.new
    @gold_window.x = 0
    @gold_window.y = 416
    # Make status window
    @status_window = Window_MenuStatus.new
    @status_window.x = 140
    @status_window.y = 0
    # Add as a mouse enabled window
    mouse_windows << @status_window
    # Set owner
    @status_window.owner = self
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
    @command_window.dispose
    @playtime_window.dispose
    @steps_window.dispose
    @gold_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update windows
    @command_window.update
    @playtime_window.update
    @steps_window.update
    @gold_window.update
    @status_window.update
    # If command window is active: call update_command
    if @command_window.active
      update_command
      return
    end
    # If status window is active: call update_status
    if @status_window.active
      update_status
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #--------------------------------------------------------------------------
  def update_command
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to map screen
      if $game_switches[39] == true and Utility.read_ini('Mouse') != '1'
        Utility.write_ini('Mouse', '1') and Mouse.start_up
      end
      if $game_switches[39] == false and Utility.read_ini('Mouse') != '0' 
        Utility.write_ini('Mouse', '0') and Mouse.turn_off
      end
      $scene = Scene_Map.new
      $game_map.refresh
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      command_trigger
      return
    end
  end
  
  ##
  # Command window trigger
  #
  def command_trigger
    # If command other than save or end game, and party members = 0
    if $game_party.actors.size == 0 and @command_window.index < 5
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Branch by command window cursor position
    case @command_window.index
    when 0  # item
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to item screen
      $scene = Scene_Item.new
    when 1  # skill
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Make status window active
      @command_window.active = false
      @status_window.active = true
      @status_window.index = 0
    when 2  # equipment
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Make status window active
      @command_window.active = false
      @status_window.active = true
      @status_window.index = 0
    when 3  # status
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Make status window active
      @command_window.active = false
      @status_window.active = true
      @status_window.index = 0
    when 4  # party
      if $game_switches[40] == false
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to save screen
      Utility.run_common_event(191)
      $scene = Scene_PartySwitcher.new
    when 5
            # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to end game screen
      $scene = Scene_Top10.new($scene)

    when 6  
            if $game_system.save_disabled
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to save screen
      $scene = Scene_Save.new

      when 7
              # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to end game screen
      $scene = Scene_End.new

        when 8
      # Play decision SE

      $game_system.se_play($data_system.decision_se)
      # Switch to end game screen
    Dialog_Options.show

    end

  end
  #--------------------------------------------------------------------------
  # * Frame Update (when status window is active)
  #--------------------------------------------------------------------------
  def update_status
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Make command window active
      @command_window.active = true
      @status_window.active = false
      @status_window.index = -1
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      status_trigger
      return
    end
  end
  ##
  # Status window trigger
  #
  def status_trigger
    # Branch by command window cursor position
    case @command_window.index
    when 1  # skill
      # If this actor's action limit is 2 or more
      if $game_party.actors[@status_window.index].restriction >= 2
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to skill screen
      $scene = Scene_Skill.new(@status_window.index)
    when 2  # equipment
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to equipment screen
      $scene = Scene_Equip.new(@status_window.index)
    when 3  # status
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to status screen
      $scene = Scene_Status.new(@status_window.index)
     when 4  # party switcher
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to status screen
      $scene = Scene_PartySwitcher.new(@status_window.index)     
    end
  end
  ##
  # Events can be fired on scenes
  #
  def fireEvent(event)
    command_trigger if event.sender == @command_window
    status_trigger if event.sender == @status_window
  end
end
