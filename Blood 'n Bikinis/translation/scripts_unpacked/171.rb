#============================================================================
# * A Simple OK dialog
#============================================================================
class Dialog_OK < Dialog
  #--------------------------------------------------------------------------
  # * A show method
  #--------------------------------------------------------------------------
  def initialize(help_text = nil, click_text = 'OK')
    # Sets the default value
    self.value = nil
    if help_text.is_a?(Array)
      @text = help_text
    else
      @text = help_text.nil? ? [] : [help_text]
    end
    @click_text = click_text
  end
  #--------------------------------------------------------------------------
  # * Create the windows
  #--------------------------------------------------------------------------
  def main_window
    @disposables = []
    
    # The command window
    @command_window = Window_Command.new(80, [@click_text])
    @command_window.x = (640 - @command_window.width) / 2
    @command_window.y = (480 - @command_window.height) / 2
    @command_window.z = @@z_value
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
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Tell the dialog to close
      mark_to_close
    end
    if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Tell the dialog to close
      mark_to_close
    end
  end
end