#============================================================================== 
# ** Scene_File 
#------------------------------------------------------------------------------ 
#  This is a superclass for the save screen and load screen. 
#============================================================================== 

class Scene_File < Scene_Base
  attr_sec_reader :mouse_windows, '[]'
  #-------------------------------------------------------------------------- 
  # * Object Initialization 
  #     help_text : text string shown in the help window 
  #-------------------------------------------------------------------------- 
  def initialize(help_text) 
  end 
  #-------------------------------------------------------------------------- 
  # * Main Processing 
  #-------------------------------------------------------------------------- 
  def main
    @window = Window_Help.new 
    if @scene == "Save" 
      @window.set_text("Save to which file?")
    elsif @scene == "Load" 
      @window.set_text("Load which file?")
    else 
      return 
    end
    # Select last file to be operated 
    @file_index = $game_temp.last_file_index 
    # Choose the offset
    calculate_offset
    # Make save file window 
    @savefile_windows = [] 
    for i in 0..(System::SAVEFILE_AMOUNT <= 3 ? System::SAVEFILE_AMOUNT - 1: 3)
      window = Window_SaveFile.new(i+@offset, -@offset)
      @savefile_windows.push(window)
      # Add as a mouse enabled window
      mouse_windows << window
    end 
    # Set the correct window as selected
    @savefile_windows[@file_index-@offset].selected = true 
    # Test
    refresh_savefile_windows
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
    @window.dispose 
    for i in @savefile_windows 
      i.dispose 
    end 
  end 
  #-------------------------------------------------------------------------- 
  # * Frame Update 
  #-------------------------------------------------------------------------- 
  def update
    @savefile_windows.each {|window| window.update}
    @window.update 
    # If C button was pressed 
    if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK)
      # Call method: on_decision (defined by the subclasses) 
      on_decision(make_filename(@file_index)) 
      $game_temp.last_file_index = @file_index 
      return 
    end 
    # If B button was pressed 
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Call method: on_cancel (defined by the subclasses) 
      on_cancel 
      return 
    end 
    # If the down directional button was pressed 
    if Input.repeat?(Input::DOWN)
      # Play cursor SE 
      $game_system.se_play($data_system.cursor_se) 
      # Move cursor down
      @savefile_windows[@file_index - @offset].selected = false 
      @file_index = (@file_index + 1) % System::SAVEFILE_AMOUNT
      if @file_index <= 0
        @offset = 0
        refresh_savefile_windows
      elsif @file_index - @offset >= 4
        @offset += 1
        refresh_savefile_windows
      end
      @savefile_windows[@file_index - @offset].selected = true 
      return 
    end 
    # If the up directional button was pressed 
    if Input.repeat?(Input::UP) 
      # Play cursor SE 
      $game_system.se_play($data_system.cursor_se) 
      # Move cursor up 
      @savefile_windows[@file_index - @offset].selected = false 
      @file_index = (@file_index - 1) % System::SAVEFILE_AMOUNT
      if @file_index - @offset < 0
        @offset -= 1
        refresh_savefile_windows
      elsif @file_index - @offset >= 4
        @offset = System::SAVEFILE_AMOUNT - 4
        refresh_savefile_windows
      end
      @savefile_windows[@file_index - @offset].selected = true 
      return 
    end 
  end
  #-------------------------------------------------------------------------- 
  # * Make File Name 
  #-------------------------------------------------------------------------- 
  def refresh_savefile_windows
    for i in 0...4
      index = @offset + i
      @savefile_windows[i].update_status(index, -@offset)
      @savefile_windows[i].refresh
    end
  end
  #-------------------------------------------------------------------------- 
  # * Calculate the offset from the file_index
  #-------------------------------------------------------------------------- 
  def calculate_offset
    @offset = @file_index - 1
    @offset = System::SAVEFILE_AMOUNT - 4 if @offset > System::SAVEFILE_AMOUNT - 4
    @offset = 0 if @offset <= 0
  end
  #-------------------------------------------------------------------------- 
  # * Make File Name 
  #     file_index : save file index (0-3) 
  #-------------------------------------------------------------------------- 
  def make_filename(file_index) 
    return $appPath + "/" + "Save#{file_index + 1}.rxdata" 
  end
  
  ##
  # Update the mouse
  #
  def mouse_update
    # Do nothing if the mouse is not enabled
    return unless Mouse.enabled
    mx, my = Mouse.pos
    # Check for first update
    if @mx.nil?
      @mx = mx
      @my = my
    end
    # Check if the mouse position has changed
    return if @mx == mx && @my == my
    # Update mouse position
    @mx = mx
    @my = my
    # Go through the mouse enabled windows
    for i in 0...4
      index = i
      window = @savefile_windows[i]
      # Check if the mouse is over the window
      if mouse_inside_window?(window)
        new_index = @offset + index
        if new_index >= System::SAVEFILE_AMOUNT
          new_index = System::SAVEFILE_AMOUNT - 1
        elsif new_index < 0
          new_index = 0
        end
        if @file_index != new_index
          @savefile_windows[@file_index - @offset].selected = false 
          window.selected = true
          @file_index = new_index
        end
      end
    end
  end
  
  ##
  # Check if the mouse is inside the given window
  #
  def mouse_inside_window?(window)
    mx, my = @mx, @my
    return mx >= window.x && mx < (window.x + window.width) &&
           my >= window.y && my < (window.y + window.height)
  end
end
