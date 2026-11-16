#============================================================================
# * A Simple Yes/No dialog
#============================================================================
class Dialog_YesNo < Dialog
    include Mouse_Windows  
  # self.value: false = No, true = Yes
  
  #--------------------------------------------------------------------------
  # * A show method
  #--------------------------------------------------------------------------
  def initialize(default_value = false, text = nil)
    # Sets the default value
    self.value = default_value
    @text = text
    # Sets the menu index
    if default_value
      @menu_index = 0
    else
      @menu_index = 1
    end
  end
  #--------------------------------------------------------------------------
  # * Create the windows
  #--------------------------------------------------------------------------
  def main_window
    @disposables = []
    
    # The command window
    @command_window = Window_Command.new(80, ['Yes', 'No'])
    @command_window.index = @menu_index
    @command_window.x = (640 - @command_window.width) / 2
    @command_window.y = (480 - @command_window.height) / 2
    @command_window.z = @@z_value
    @command_window.owner = self
    mouse_windows << @command_window
    @disposables << @command_window
    
    # The text window
    if @text.is_a?(Array)
      @text_window = Window_MultiLine.new
      @text_window.set_text(@text, 1)
      @text_window.z = @@z_value
      @disposables << @text_window
    end
  end
  #--------------------------------------------------------------------------
  # * Dispose the windows
  #--------------------------------------------------------------------------
  def main_dispose
    @disposables.each {|element| element.dispose}
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    @command_window.update
    mouse_update
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Tell the dialog to close
      mark_to_close
    end
    if Input.trigger?(Input::C)
      ok_trigger
    end
  end
  
  def ok_trigger
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    if @command_window.index == 0
      self.value = true
    else
      self.value = false
    end
    # Tell the dialog to close
    mark_to_close
  end
  
  def fireEvent(event)
    ok_trigger if event.trigger == Mouse::LEFT_CLICK
  end
end