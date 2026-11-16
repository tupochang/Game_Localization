#==============================================================================
# ** Window_NameInput
#------------------------------------------------------------------------------
#  This window is used to select text characters on the input name screen.
#==============================================================================

class Window_NameInput < Window_Base
  attr_accessor :owner
  CHARACTER_TABLE =
  [
    "A","B","C","D","E",
    "F","G","H","I","J",
    "K","L","M","N","O",
    "P","Q","R","S","T",
    "U","V","W","X","Y",
    "Z"," "," "," "," ",
    "","","","","",
    "","","","","",
    "" ,"" ,"" ,"" ,"" ,
    "","","","","",
    "","","","","",
    "","","","","",
    "","","","","",
    "","","","","",
    ""," "," "," "," ",
    "","","","","",
    "","","","","",
    "" ,"" ,"" ,"" ,"" ,
  ]
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 128, 640, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    @index = 0
    refresh
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Text Character Acquisition
  #--------------------------------------------------------------------------
  def character
    return CHARACTER_TABLE[@index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    for i in 0...90
      x = 140 + i / 5 / 9 * 180 + i % 5 * 32
      y = i / 5 % 9 * 32
      self.contents.draw_text(x, y, 32, 32, CHARACTER_TABLE[i], 1)
    end
    self.contents.draw_text(428, 9 * 32, 48, 32, "OK", 1)
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # If cursor is positioned on [OK]
    if @index >= 90
      self.cursor_rect.set(428, 9 * 32, 48, 32)
    # If cursor is positioned on anything other than [OK]
    else
      x = 140 + @index / 5 / 9 * 180 + @index % 5 * 32
      y = @index / 5 % 9 * 32
      self.cursor_rect.set(x, y, 32, 32)
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # If cursor is positioned on [OK]
    if @index >= 90
      # Cursor down
      if Input.trigger?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        @index -= 90
      end
      # Cursor up
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        @index -= 90 - 40
      end
    # If cursor is positioned on anything other than [OK]
    else
      # If right directional button is pushed
      if Input.repeat?(Input::RIGHT)
        # If directional button pressed down is not a repeat, or
        # cursor is not positioned on the right edge
        if Input.trigger?(Input::RIGHT) or
           @index / 45 < 3 or @index % 5 < 4
          # Move cursor to right
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 < 4
            @index += 1
          else
            @index += 45 - 4
          end
          if @index >= 90
            @index -= 90
          end
        end
      end
      # If left directional button is pushed
      if Input.repeat?(Input::LEFT)
        # If directional button pressed down is not a repeat, or
        # cursor is not positioned on the left edge
        if Input.trigger?(Input::LEFT) or
           @index / 45 > 0 or @index % 5 > 0
          # Move cursor to left
          $game_system.se_play($data_system.cursor_se)
          if @index % 5 > 0
            @index -= 1
          else
            @index -= 45 - 4
          end
          if @index < 0
            @index += 90
          end
        end
      end
      # If down directional button is pushed
      if Input.repeat?(Input::DOWN)
        # Move cursor down
        $game_system.se_play($data_system.cursor_se)
        if @index % 45 < 40
          @index += 5
        else
          @index += 90 - 40
        end
      end
      # If up directional button is pushed
      if Input.repeat?(Input::UP)
        # If directional button pressed down is not a repeat, or
        # cursor is not positioned on the upper edge
        if Input.trigger?(Input::UP) or @index % 45 >= 5
          # Move cursor up
          $game_system.se_play($data_system.cursor_se)
          if @index % 45 >= 5
            @index -= 5
          else
            @index += 90
          end
        end
      end
      # If L or R button was pressed
      if Input.repeat?(Input::L) or Input.repeat?(Input::R)
        # Move capital / small
        $game_system.se_play($data_system.cursor_se)
        if @index < 45
          @index += 45
        else
          @index -= 45
        end
      end
    end
    update_cursor_rect
  end
  
  ##
  # Determines whether the given coordinates are within the given area
  #
  def is_in?(x,y, rx,ry,rw,rh)
    return x >= rx && x < rx + rw &&
           y >= ry && y < ry + rh
  end
  
  ##
  # Calculates the index from the coordinates
  #
  def calculate_index(x, y)
    # Check [OK] position
    return 90 if is_in?(x,y,  428, 9 * 32, 48, 32)
    if is_in?(x,y,  140, 0, 5*32, 9*32)
      # Left box
      x = (x - 140) / 32
      y /= 32
      return x + y * 5
    elsif is_in?(x,y,  320, 0, 5*32, 9*32)
      # Right box
      x = (x - 320) / 32
      y /= 32
      return x + y * 5 + 45
    end
    # Outside
    return -1
  end
  
  ##
  # Update mouse position
  # Mouse enabled subclasses should overwrite this method
  #
  def mouse_move(mx, my)
    @mx, @my = mx, my
    index = calculate_index(mx-16, my-16)
    @index = index unless index < 0
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  # Note: The mouse is over the window
  #
  def mouse_update
    if Mouse.trigger?(Mouse::LEFT_CLICK) && calculate_index(@mx-16, @my-16) >= 0
      owner.fireEvent(MouseEvent.new(self, Mouse::LEFT_CLICK, @index))
    end
  end
end
