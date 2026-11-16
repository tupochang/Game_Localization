#============================================================================
# * A Simple Yes/No dialog
#============================================================================
class Dialog_Options < Dialog
  include Mouse_Windows  
  # self.value has no meaning
  #--------------------------------------------------------------------------
  # * A show method
  #--------------------------------------------------------------------------
  def initialize(menu_index = 0)
    # Pause possible cursor chagnes
    Sprite_Mouse.pause=true
    # Sets the menu index
    @menu_index = menu_index
  end
  #--------------------------------------------------------------------------
  # * Create the windows
  #--------------------------------------------------------------------------
  def main_window
    @disposables = []
    
    # The text window
    @text_window = Window_Options_Bar.new
    @text_window.z = @@z_value
    @disposables << @text_window

    # The mouse windows
    @options_window = Windows_Options.new
    @options_window.x = (640 - @options_window.width) / 2
    @accept_window = Window_Accept.new
    @accept_window.index = 1
    @accept_window.x = (640 - @accept_window.width) / 2
    ypos = (480 - @text_window.height - @options_window.height - @accept_window.height) / 2
    ypos = 0 if ypos < 0
    @text_window.y = ypos
    @options_window.y = ypos + @text_window.height
    @options_window.z = @@z_value
    @options_window.owner = self
    @accept_window.y = @options_window.y + @options_window.height
    @accept_window.y = 480 - @accept_window.height if @accept_window.y > 480 - @accept_window.height
    @accept_window.z = @@z_value + 3
    @accept_window.owner = self
    mouse_windows << @options_window
    mouse_windows << @accept_window
    @disposables << @options_window
    @disposables << @accept_window
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
    mouse_update
    if @options_window.focus
      @options_window.update
    else
      @accept_window.update
    end
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      cancel_trigger
      return
    end
    if Input.trigger?(Input::C)
      if @accept_window.focus
        if @accept_window.index == 0
          accept_trigger
        else
          cancel_trigger
        end
      end
    end
  end

  def accept_trigger
    # Apply changes (if any)
    @options_window.apply_effects
    # Tell the dialog to close
    mark_to_close
  end
  
  def cancel_trigger
    # Play cancel SE
    $game_system.se_play($data_system.cancel_se)
    # Tell the dialog to close
    mark_to_close
  end
  
  def mark_to_close
    Sprite_Mouse.pause=false
    super
  end
  
  def fireEvent(event)
    if event.trigger == Mouse::LEFT_CLICK
      if event.sender.is_a?(Window_Accept)
        if event.info == 0
          accept_trigger
        else
          cancel_trigger
        end
      end
    end
    if event.trigger == :take_focus
      if event.sender == @options_window
        @accept_window.focus = false
      else
        @options_window.focus = false
      end
    elsif event.trigger == :shift_focus
      if event.sender == @options_window
        @accept_window.focus = true
      else
        @options_window.focus = true
        if event.info == :up
          @options_window.focus_bottom
        else
          @options_window.focus_top
        end
      end
    end
  end
end