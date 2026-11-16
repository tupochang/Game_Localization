# Encapsulation of a mouse event
MouseEvent = Struct.new(:sender, :trigger, :info)

#==============================================================================
# ** Mouse module
#------------------------------------------------------------------------------
# Manages the Win32API calls and the base mouse functionalities
#==============================================================================
module Mouse
  #--------------------------------------------------------------------------
  # * Mouse to Input Triggers
  #--------------------------------------------------------------------------
  LEFT_CLICK = 1
  RIGHT_CLICK = 2
  MIDDLE_CLICK = 4
  
  MOUSE_TRIGGERS = [LEFT_CLICK, RIGHT_CLICK, MIDDLE_CLICK]
  #--------------------------------------------------------------------------
  # * API Declaration
  #--------------------------------------------------------------------------
  ASYNC_KEY        = Win32API.new('user32',    'GetAsyncKeyState', 'i',     'i')
  SCREEN_TO_CLIENT = Win32API.new('user32',    'ScreenToClient',   %w(l p), 'i')
  CURSOR_POS       = Win32API.new('user32',    'GetCursorPos',     'p',     'i')
  FIND_WINDOW      = Win32API.new('user32',    'FindWindowA',      %w(p p), 'l')

  module_function
  ##
  # Start up procedures
  #
  def start_up
    # Create a reference to the configuration module
    @@const = System::Mouse
    # Initialize button states
    @button_states = Array.new(5, 0)
    # Compute the handle for the window
    window_handle
    # Read mouse status
    mouse_status = Utility.read_ini('mouse')
    @enabled = !(mouse_status == '0' || mouse_status == '')
    # Create mouse sprite if the mouse script is enabled
    if @enabled 
      # Create mouse sprite
      create_cursor
      # Update cursor
      update
    end
  end
  
  
  ##
  # Shutdown procedures
  #
  def shutdown
    # Dispose the mouse sprite
    @mouse_sprite.dispose unless @mouse_sprite.nil? || @mouse_sprite.disposed?
  end
  
  ##
  # Turn the mouse script on
  # Nothing will happen if it is already turned on
  #
  def turn_on
    return if self.enabled
    @enabled = true
    # Create mouse sprite
    create_cursor
    # Update cursor
    update
  end
  
  ##
  # Turn the mouse script off.
  # Nothing will happen if it is already turned off
  #
  def turn_off
    return unless self.enabled
    @enabled = false
    # Show the cursor if it was hidden
    unless @mouse_sprite.nil? || @mouse_sprite.disposed?
      # Dispose the mouse sprite
      @mouse_sprite.dispose
      # Remove the reference so the garbage cleaner will remove it eventually
      @mouse_sprite = nil
    end
  end
  
  ##
  # Update
  #
  def update
    # Only update if enabled
    return unless self.enabled
    # Get new position
    sx, sy = screen_pos
    # If the position of the mouse have changed
    if @sx != sx || @sy != sy
      # Store new screen x and y
      @sx = sx
      @sy = sy
      # Get relative position
      if Input.is_fullscreen  
        rx, ry = sx, sy
      else
        rx, ry = screen_to_client(sx, sy)
      end
      return unless rx >= 0 && rx < 640 && ry >= 0 && ry < 480
      # Change location of the cursor
      @mouse_sprite.x = rx
      @mouse_sprite.y = ry
    end
    # Check for clicks
    for trigger in MOUSE_TRIGGERS
      # Gets Async State
      state = ASYNC_KEY.call(trigger)
      # If 0 or 1
      if state == 0 || state == 1
        if @button_states[trigger] > 0
          @button_states[trigger] *= -1
        else
          @button_states[trigger] = 0
        end
      else
        if @button_states[trigger] > 0
          @button_states[trigger] += 1
        else
          @button_states[trigger] = 1
        end
      end
    end
    # Update the mouse sprite
    @mouse_sprite.update
  end
  
  ##
  # Check for press
  #   Returns false if Mouse is not enabled
  #
  def press?(id = LEFT_CLICK)
    return false unless self.enabled
    return @button_states[id] >= 1
  end
  
  ##
  # Check for trigger
  #   Returns false if Mouse is not enabled
  #
  def trigger?(id = LEFT_CLICK)
    return false unless self.enabled
    return @button_states[id] == 1
  end
  
  ##
  # Check for repeat
  #   Returns false if Mouse is not enabled
  #
  def repeat?(id = LEFT_CLICK)
    return false unless self.enabled
    if @button_states[id] <= 0
      return false
    elsif @button_states[id] == 1
      return true
    elsif @button_states[id] > @@const::REPEAT_START_WAIT
      return @button_states[id] % @@const::REPEAT_WAIT == 1
    end
  end
  
  ##
  # Return true if the mouse script is enabled
  #
  def enabled
    @enabled
  end
  
  ##
  # Get screen coordinates
  #
  def screen_pos
    # Packs 0 Position
    pos = [0, 0].pack('ll')
    # Returns Unpacked Cursor Position Call
    return CURSOR_POS.call(pos) == 0 ? nil : pos.unpack('ll')
  end
  
  ##
  # Converts screen X- and Y-coordinates to relative coordinates.
  # Top-left corner = (0, 0)
  #
  def pos
    return @mouse_sprite.x, @mouse_sprite.y
  end
  
  ##
  # Check if the mouse is inside the window
  #
  def inside?
    x, y = pos
    return x >= 0 && x < 640 && y >= 0 && y < 480
  end
  
  ##
  # Screen coordinates converted to be relative to client window
  #
  def screen_to_client(x, y)
    # Return nil if X & Y empty
    return nil unless x and y
    if @ori_pos.nil?
      @stc_wait = 0
    end
    if @stc_wait <= 0
      # Locate upper-left corner
      pack = [0, 0].pack('ll')
      SCREEN_TO_CLIENT.call(window_handle, pack)
      @ori_pos = pack.unpack('ll')
      # Wait 10 frames before the next look-up
      @stc_wait = 10
    else
      @stc_wait -= 1
    end
    # Translocate X- and Y-coordinates
    x += @ori_pos[0]
    y += @ori_pos[1]
    return x, y
  end
  
  ##
  # Retrieve the window handle
  #
  def window_handle
    if @window_handle.nil?
      # Finds Game Name
      game_name = Utility.read_ini('Title')
      # Finds Window
      @window_handle = FIND_WINDOW.call('RGSS Player', game_name)
    end
    return @window_handle
  end
  
  # Opens up singleton class of the module 
  class << self
    ###################
    # Private methods #
    ###################
    private
    ##
    # Create the cursor
    #
    def create_cursor
      @mouse_sprite = Sprite_Mouse.new(@@const)
    end
  end
end

