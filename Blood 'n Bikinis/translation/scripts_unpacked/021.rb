#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles the map. It includes scrolling and passable determining
#  functions. Refer to "$game_map" for the instance of this class.
#==============================================================================

class Game_Map
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :tileset_name             # tileset file name
  attr_accessor :autotile_names           # autotile file name
  attr_accessor :panorama_name            # panorama file name
  attr_accessor :panorama_hue             # panorama hue
  attr_accessor :fog_name                 # fog file name
  attr_accessor :fog_hue                  # fog hue
  attr_accessor :fog_opacity              # fog opacity level
  attr_accessor :fog_blend_type           # fog blending method
  attr_accessor :fog_zoom                 # fog zoom rate
  attr_accessor :fog_sx                   # fog sx
  attr_accessor :fog_sy                   # fog sy
  attr_accessor :battleback_name          # battleback file name
  attr_accessor :display_x                # display x-coordinate * 128
  attr_accessor :display_y                # display y-coordinate * 128
  attr_accessor :need_refresh             # refresh request flag
  attr_reader   :passages                 # passage table
  attr_reader   :priorities               # prioroty table
  attr_reader   :terrain_tags             # terrain tag table
  attr_reader   :events                   # events
  attr_reader   :fog_ox                   # fog x-coordinate starting point
  attr_reader   :fog_oy                   # fog y-coordinate starting point
  attr_reader   :fog_tone                 # fog color tone
  attr_reader   :event_map               ## event map (anti lag)
  attr_accessor :mouse_refresh           ## mouse refresh flag
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @map_id = 0
    @display_x = 0
    @display_y = 0
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     map_id : map ID
  #--------------------------------------------------------------------------
  def setup(map_id)
    # Makes an event map as a hash 
    @event_map = {} 
    # Put map ID in @map_id memory
    @map_id = map_id
    # Load map from file and set @map
    @map = load_data(sprintf("Data/%sMap%03d.rxdata", $game_system.disc, @map_id))
    # set tile set information in opening instance variables
    tileset = $data_tilesets[@map.tileset_id]
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @fog_name = tileset.fog_name
    @fog_hue = tileset.fog_hue
    @fog_opacity = tileset.fog_opacity
    @fog_blend_type = tileset.fog_blend_type
    @fog_zoom = tileset.fog_zoom
    @fog_sx = tileset.fog_sx
    @fog_sy = tileset.fog_sy
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    # Initialize displayed coordinates
    @display_x = 0
    @display_y = 0
    # Clear refresh request flag
    @need_refresh = false
    # Set map event data
    @events = {}
    for i in @map.events.keys
      @events[i] = Game_Event.new(@map_id, @map.events[i])
    end
    # Set common event data
    @common_events = {}
    for i in 1...$data_common_events.size
      @common_events[i] = Game_CommonEvent.new(i)
    end
    # Initialize all fog information
    @fog_ox = 0
    @fog_oy = 0
    @fog_tone = Tone.new(0, 0, 0, 0)
    @fog_tone_target = Tone.new(0, 0, 0, 0)
    @fog_tone_duration = 0
    @fog_opacity_duration = 0
    @fog_opacity_target = 0
    # Initialize scroll information
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    # Go through each event
    for event in @events.values
      # Check how the event should be updated
      event.check_update
    end
  end
  #--------------------------------------------------------------------------
  # * Get Map ID
  #--------------------------------------------------------------------------
  def map_id
    return @map_id
  end
  #--------------------------------------------------------------------------
  # * Get Width
  #--------------------------------------------------------------------------
  def width
    return @map.width
  end
  #--------------------------------------------------------------------------
  # * Get Height
  #--------------------------------------------------------------------------
  def height
    return @map.height
  end
  #--------------------------------------------------------------------------
  # * Get Encounter List
  #--------------------------------------------------------------------------
  def encounter_list
    return @map.encounter_list
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Steps
  #--------------------------------------------------------------------------
  def encounter_step
    return @map.encounter_step
  end
  #--------------------------------------------------------------------------
  # * Set Encounter Steps
  #--------------------------------------------------------------------------
  def encounter_step=(value)
    return @map.encounter_step=(value)
  end
  #--------------------------------------------------------------------------
  # * Get Map Data
  #--------------------------------------------------------------------------
  def data
    return @map.data
  end
  #--------------------------------------------------------------------------
  # * Automatically Change Background Music and Backround Sound
  #--------------------------------------------------------------------------
  def autoplay
    if @map.autoplay_bgm
      $game_system.bgm_play(@map.bgm)
    end
    if @map.autoplay_bgs
      $game_system.bgs_play(@map.bgs)
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # If map ID is effective
    if @map_id > 0
      # Refresh all map events
      for event in @events.values
        event.refresh
      end
      # Refresh all common events
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    # Clear refresh request flag
    @need_refresh = false
  end
  #--------------------------------------------------------------------------
  # * Scroll Down
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_down(distance)
    @display_y = [@display_y + distance, (self.height - 15) * 128].min
  end
  #--------------------------------------------------------------------------
  # * Scroll Left
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_left(distance)
    @display_x = [@display_x - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # * Scroll Right
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_right(distance)
    @display_x = [@display_x + distance, (self.width - 20) * 128].min
  end
  #--------------------------------------------------------------------------
  # * Scroll Up
  #     distance : scroll distance
  #--------------------------------------------------------------------------
  def scroll_up(distance)
    @display_y = [@display_y - distance, 0].max
  end
  #--------------------------------------------------------------------------
  # * Determine Valid Coordinates
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def valid?(x, y)
    return (x >= 0 and x < width and y >= 0 and y < height)
  end
  #--------------------------------------------------------------------------
  # * Determine Thicket
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def bush?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x40 == 0x40
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Determine Counter
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def counter?(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return false
        elsif @passages[tile_id] & 0x80 == 0x80
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Terrain Tag
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil
          return 0
        elsif @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
  #--------------------------------------------------------------------------
  # * Get Designated Position Event ID
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def check_event(x, y)
    for event in $game_map.events.values
      if event.x == x and event.y == y
        return event.id
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Start Scroll
  #     direction : scroll direction
  #     distance  : scroll distance
  #     speed     : scroll speed
  #--------------------------------------------------------------------------
  def start_scroll(direction, distance, speed)
    @scroll_direction = direction
    @scroll_rest = distance * 128
    @scroll_speed = speed
  end
  #--------------------------------------------------------------------------
  # * Determine if Scrolling
  #--------------------------------------------------------------------------
  def scrolling?
    return @scroll_rest > 0
  end
  #--------------------------------------------------------------------------
  # * Start Changing Fog Color Tone
  #     tone     : color tone
  #     duration : time
  #--------------------------------------------------------------------------
  def start_fog_tone_change(tone, duration)
    @fog_tone_target = tone.clone
    @fog_tone_duration = duration
    if @fog_tone_duration == 0
      @fog_tone = @fog_tone_target.clone
    end
  end
  #--------------------------------------------------------------------------
  # * Start Changing Fog Opacity Level
  #     opacity  : opacity level
  #     duration : time
  #--------------------------------------------------------------------------
  def start_fog_opacity_change(opacity, duration)
    @fog_opacity_target = opacity * 1.0
    @fog_opacity_duration = duration
    if @fog_opacity_duration == 0
      @fog_opacity = @fog_opacity_target
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Refresh map if necessary
    if $game_map.need_refresh
      refresh
    end
    # If scrolling
    if @scroll_rest > 0
      # Change from scroll speed to distance in map coordinates
      distance = 2 ** @scroll_speed
      # Execute scrolling
      case @scroll_direction
      when 2  # Down
        scroll_down(distance)
      when 4  # Left
        scroll_left(distance)
      when 6  # Right
        scroll_right(distance)
      when 8  # Up
        scroll_up(distance)
      end
      # Subtract distance scrolled
      @scroll_rest -= distance
    end
    # Runs through the events
    for event in @events.values
      # checks if the event is visible or needs to be updated
      if ALWAYS_UPDATE || event.need_update?
        event.update
      end
    end
    # Update common event
    for i in COMMON_EVENTS_TO_UPDATE
      @common_events[i].update
    end
    # Manage fog scrolling
    @fog_ox -= @fog_sx / 8.0
    @fog_oy -= @fog_sy / 8.0
    # Manage change in fog color tone
    if @fog_tone_duration >= 1
      d = @fog_tone_duration
      target = @fog_tone_target
      @fog_tone.red = (@fog_tone.red * (d - 1) + target.red) / d
      @fog_tone.green = (@fog_tone.green * (d - 1) + target.green) / d
      @fog_tone.blue = (@fog_tone.blue * (d - 1) + target.blue) / d
      @fog_tone.gray = (@fog_tone.gray * (d - 1) + target.gray) / d
      @fog_tone_duration -= 1
    end
    # Manage change in fog opacity level
    if @fog_opacity_duration >= 1
      d = @fog_opacity_duration
      @fog_opacity = (@fog_opacity * (d - 1) + @fog_opacity_target) / d
      @fog_opacity_duration -= 1
    end
  end
  
  #--------------------------------------------------------------------------
  # * Called when an event has been moved with it's old x and y coordinate
  #   Used to update its position in the event_map
  #--------------------------------------------------------------------------
  def move_event(old_x,old_y,event)
    # Checks if the event has moved to a new position.
    return if old_x == event.x && old_y == event.y
    # Removes the event from its old position
    remove_event(old_x, old_y, event)
    # Adds the event to its new position
    add_event(event.x,event.y,event)
    # Gets the spriteset from Scene_Map
    spriteset = $scene.instance_eval('@spriteset')
    # Checks that it actually is a Spriteset_Map.
    if spriteset.is_a?(Spriteset_Map)
      # Tells the spriteset to update the event to its new position
      spriteset.update_event(old_x,old_y,event)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Adds an event to the event_map at the given x and y coordinate
  #--------------------------------------------------------------------------
  def add_event(x,y,event)
    # Checks if there are not any events on the specific tile
    if @event_map[[x,y]].nil?
      # Sets the position on the map to be an array containing the given
      # event. (In case there are placed additional events on this tile)
      @event_map[[x,y]] = [event]
    else
      # Adds the event to the array of events on the specific tile
      @event_map[[x,y]] << event
    end
  end
  
  #--------------------------------------------------------------------------
  # * Removes an event from the event_map with the given x and y coordinate
  #--------------------------------------------------------------------------
  def remove_event(x,y,event)
    # Checks if there actually are an event on the given coordinates
    return if @event_map[[x,y]].nil?
    # Checks whether or not there are more events than the given event on
    # with the given coordinates
    if @event_map[[x,y]].size > 1
      # Deletes the events from the array of events
      @event_map[[x,y]].delete(event)
    else
      # Deletes the key along with the corresponding value from the hashmap
      # since there are no other events on the tile.
      @event_map.delete([x,y])
    end
  end
  
  #--------------------------------------------------------------------------
  # * Gets min_x, max_x, min_y and max_y including the buffer-size
  # Returns min_x, max_x, min_y, max_y  (tile-coordinates)
  # Returns a Rect if 'true' is given as the argument
  #--------------------------------------------------------------------------  
  def get_tile_area(rect = false)
    # Gets the upper left x and y tile-coordinate
    x = $game_map.display_x / 128
    y = $game_map.display_y / 128
    # Computes the min and max coordinates when considering the buffer-size
    min_x = x - BUFFER_SIZE
    min_y = y - BUFFER_SIZE
    max_x = x + TILES_HORIZONTAL + BUFFER_SIZE
    max_y = y + TILES_VERTICAL + BUFFER_SIZE
    # Makes sure the min and max coordinates are within the map
    if min_x < 0
      min_x = 0
    end
    if max_x >= $game_map.width
      max_x = $game_map.width - 1
    end
    if min_y < 0
      min_y = 0
    end
    if max_y >= $game_map.height
      max_y = $game_map.height - 1
    end
    # Checks if the return should be a Rect
    if rect
      # Returns the result as a Rect
      return Rect.new(min_x, min_y, max_x - min_x, max_y - min_y)
    else
      # Returns the result as the min and max coordinates
      return min_x, max_x, min_y, max_y
    end
  end
  
  #--------------------------------------------------------------------------
  # * Checks if the tile with the given x and y coordinate is visible.
  #   Takes the buffer size into account.
  #--------------------------------------------------------------------------
  def visible?(x,y)
    min_x = $game_map.display_x / 128
    min_y = $game_map.display_y / 128
    if x >= min_x - BUFFER_SIZE && x <= min_x + BUFFER_SIZE + TILES_HORIZONTAL &&
       y >= min_y - BUFFER_SIZE && y <= min_y + BUFFER_SIZE + TILES_VERTICAL
      return true
    end
    return false
  end
  
  #--------------------------------------------------------------------------
  # * Get Designated Position Event ID
  #     x          : x-coordinate
  #     y          : y-coordinate
  #--------------------------------------------------------------------------
  def check_event(x, y)
    # Retrives the events on the specified tile
    events = event_map[[x,y]]
    unless events.nil?
      # Loop through events on tile
      for event in events
        if event.x == x and event.y == y
          return event.id
        end
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Determine if Passable
  #     x          : x-coordinate
  #     y          : y-coordinate
  #     d          : direction (0,2,4,6,8,10)
  #                  *  0,10 = determine if all directions are impassable
  #     self_event : Self (If event is determined passable)
  #--------------------------------------------------------------------------
  def passable?(x, y, d, self_event = nil)
    # If coordinates given are outside of the map
    unless valid?(x, y)
      # impassable
      return false
    end
    # Change direction (0,2,4,6,8,10) to obstacle bit (0,1,2,4,8,0)
    bit = (1 << (d / 2 - 1)) & 0x0f
    # Retrives the events on the specified tile
    events = event_map[[x,y]]
    unless events.nil?
      # Loop through events on tile
      for event in events
        # If tiles other than self are consistent with coordinates
        if event.tile_id >= 0 and event != self_event and not event.through
          # If obstacle bit is set
          if @passages[event.tile_id] & bit != 0
            # impassable
            return false
          # If obstacle bit is set in all directions
          elsif @passages[event.tile_id] & 0x0f == 0x0f
            # impassable
            return false
          # If priorities other than that are 0
          elsif @priorities[event.tile_id] == 0
            # passable
            return true
          end
        end
      end
    end
    # Loop searches in order from top of layer
    for i in [2, 1, 0]
      # Get tile ID
      tile_id = data[x, y, i]
      # Tile ID acquistion failure
      if tile_id == nil
        # impassable
        return false
      # If obstacle bit is set
      elsif @passages[tile_id] & bit != 0
        # impassable
        return false
      # If obstacle bit is set in all directions
      elsif @passages[tile_id] & 0x0f == 0x0f
        # impassable
        return false
      # If priorities other than that are 0
      elsif @priorities[tile_id] == 0
        # passable
        return true
      end
    end
    # passable
    return true
  end
end
