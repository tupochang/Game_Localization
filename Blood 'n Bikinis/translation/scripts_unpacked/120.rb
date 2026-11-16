# Encapsulates cursor information
MouseCursor = Struct.new(:icon, :text)

##
# Encapsulates the mouse sprite and make sure the correct icon and 
# (optional) text is displayed
#
class Sprite_Mouse < Sprite
  ##
  # Object initialization
  #   config: Configuration module
  #
  def initialize(config = System::Mouse)
    # Create the sprite normally
    super()
    # Set the cursor to be on top of nearly everything
    self.z = 0xFFFFFA
    # Create text_sprite
    @text_sprite = Sprite.new
    # Create dummy bitmap
    @text_sprite.bitmap = Bitmap.new(16,16)
    # It should be on top of the cursor
    @text_sprite.z = 0xFFFFFD
    # Load the icon
    self.bitmap = RPG::Cache.icon(config::DEFAULT_ICON)
    # We want to store the reference to the config module
    @config = config
    # Last events (nil indicates no events)
    @le = nil
    # Default cursor after initialization
    @default = true
    # Previos cursor is nil
    @cursor = nil
    # Last x and y (-1 means no last coordinate)
    @lx, @ly = -1, -1
    # Text sprite position offset
    @tox, @toy = @config::DEFAULT_OFFSET_X, @config::DEFAULT_OFFSET_Y
  end
    
  ##
  # Check if double size is wanted
  #
  def double_size
    if @double_size.nil?
      @double_size = Utility.read_ini('big_mouse') == '1'
    end
    @double_size
  end
  
  ##
  # Mouse sprite update
  #
  def update
    # Return unless the current scene is Scene_Map
    unless $scene.is_a?(Scene_Map)
      unless @default
        default_cursor
      end
      return
    end
    # Check for mouse movement
    unless (@lx == x && @ly == y)
      @lx = x
      @ly = y
      # Update text sprite position if its visible
      if @text_sprite.visible
        @text_sprite.x = @lx + @tox
        @text_sprite.y = @ly + @toy
      end
    end
    # Calculate tile
    rx = (x + $game_map.display_x/4) / 32
    ry = (y + $game_map.display_y/4) / 32
    e = $game_map.event_map[[rx,ry]]
    if @le != e || $game_map.mouse_refresh
      @le = e
      if e.nil?
        # Use the default cursor
        default_cursor
      else
        # The cursor will not be the default anymore
        @default = false
        # Update the cursor
        update_cursor
      end
    end
    $game_map.mouse_refresh = false
  end
  
  ##
  # Change to the default cursor
  #
  def default_cursor
    return if @default
    default_icon
    remove_text
    @default = true
    @cursor = nil
  end
  
  ##
  # Change to default icon
  #
  def default_icon
    self.bitmap = RPG::Cache.icon(@config::DEFAULT_ICON)
    if double_size
      self.zoom_x = 1.0
      self.zoom_y = 1.0
    end
    @tox, @toy = @config::DEFAULT_OFFSET_X, @config::DEFAULT_OFFSET_Y
  end
  
  ##
  # Remove the text
  #
  def remove_text
    @text_sprite.visible = false
  end
  
  ##
  # Show text
  #
  def show_text(text)
    @text_sprite.visible = true
    rect = @text_sprite.bitmap.text_size(text)
    rect.width += 6
    @text_sprite.bitmap = Bitmap.new(rect.width, rect.height)
    @text_sprite.bitmap.draw_text(rect, text)
    @default = false
  end
  
  ##
  # Update icon
  #
  def update_cursor
    return if @le.nil?
    mcursor = nil
    # Go through the events on the current tile (Sor
    for event in @le.sort {|x, y| x.id <=> y.id}
      # Retrieve mouse cursor from the evnet
      ecursor = event.mouse_cursor
      # Break if the cursor is not nil (i.e. default)
      unless ecursor.nil?
        mcursor = ecursor 
        break
      end
    end
     if mcursor.nil?
      default_cursor unless @default
    else
      change_cursor(mcursor)
      @default = false
    end
  end
  
  ##
  # Change the mouse cursor
  #
  def change_cursor(cursor)
    return if cursor == @cursor || @@pause
    # Check icon
    if @cursor.nil? || @cursor.icon != cursor.icon
      if cursor.icon.nil?
        default_icon
      else
        info = @config.get_icon_info(cursor.icon)
        self.bitmap = RPG::Cache.icon(info[0])
        @tox = info[1]
        @toy = info[2]
        if double_size
          self.zoom_x = 1.25
          self.zoom_y = 1.25
        end
      end
    end
    # Check text
    if @cursor.nil? || @cursor.text != cursor.text
      if cursor.text.nil?
        remove_text
      else
        show_text(cursor.text)
      end
    end
    @cursor = cursor
  end
  
  @@pause = false
  def self.pause=(pause=false)
    @@pause = pause
  end
end