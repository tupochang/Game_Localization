#==============================================================================
# ** Game_Event
#------------------------------------------------------------------------------
#  This class deals with events. It handles functions including event page 
#  switching via condition determinants, and running parallel process events.
#  It's used within the Game_Map class.
#==============================================================================

class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # trigger
  attr_reader   :list                     # list of event commands
  attr_reader   :starting                 # starting flag
  attr_reader   :event                    # event data
  attr_reader   :mouse_cursor            ## mouse cursor for hover
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     map_id : map ID
  #     event  : event (RPG::Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # Move to starting position
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Clear Starting Flag
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # * Determine if Over Trigger
  #    (whether or not same position is starting condition)
  #--------------------------------------------------------------------------
  def over_trigger?
    # If not through situation with character as graphic
    if @character_name != "" and not @through
      # Starting determinant is face
      return false
    end
    # If this position on the map is impassable
    unless $game_map.passable?(@x, @y, 0)
      # Starting determinant is face
      return false
    end
    # Starting determinant is same position
    return true
  end
  #--------------------------------------------------------------------------
  # * Start Event
  #--------------------------------------------------------------------------
  def start
    # If list of event commands is not empty
    if @list.size > 1
      @starting = true
    end
  end
  #--------------------------------------------------------------------------
  # * Temporarily Erase
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Initialize local variable: new_page
    new_page = nil
    # If not temporarily erased
    unless @erased
      # Check in order of large event pages
      for page in @event.pages.reverse
        # Make possible referrence for event condition with c
        c = page.condition
        # Switch 1 condition confirmation
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # Switch 2 condition confirmation
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # Variable condition confirmation
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # Self switch condition confirmation
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # Set local variable: new_page
        new_page = page
        # Remove loop
        break
      end
    end
    # If event page is the same as last time
    if new_page == @page
      # End method
      return
    end
    # Set @page as current event page
    @page = new_page
    # Update event cursor information
    update_event_cursor
    # Clear starting flag
    clear_starting
    # If no page fulfills conditions
    if @page == nil
      # Set each instance variable
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # End method
      return
    end
    # Set each instance variable
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # If trigger is [parallel process]
    if @trigger == 4
      # Create parallel process interpreter
      @interpreter = Interpreter.new
    end
    # Auto event start determinant
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    # If event is running
    if $game_system.map_interpreter.running?
      return
    end
    # If trigger is [touch from event] and consistent with player coordinates
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # If starting determinant other than jumping is front event
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Automatic Event Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    # If trigger is [touch from event] and consistent with player coordinates
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # If starting determinant other than jumping is same position event
      if not jumping? and over_trigger?
        start
      end
    end
    # If trigger is [auto run]
    if @trigger == 3
      start
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # Automatic event starting determinant
    check_event_trigger_auto
    # If parallel process is valid
    if @interpreter != nil
      # If not running
      unless @interpreter.running?
        # Set up event
        @interpreter.setup(@list, @event.id)
      end
      # Update interpreter
      @interpreter.update
    end
  end
  
  #--------------------------------------------------------------------------
  # * Always_update property (is false by default) priority under never_update
  #--------------------------------------------------------------------------
  attr_writer :always_update
  def always_update
    @always_update = false  if @always_update.nil?
    return @always_update
  end
  
  #--------------------------------------------------------------------------
  # * Never_update property (is false by default) priority over always_update
  #--------------------------------------------------------------------------
  attr_writer :never_update
  def never_update
    @never_update = false  if @never_update.nil?
    return @never_update
  end
  
  #--------------------------------------------------------------------------
  # * Need Update method. Fast checks here.
  #--------------------------------------------------------------------------
  def need_update?
    return false if never_update
    return true if always_update
    return true if $game_map.visible?(x, y)
    return true if @move_type == 3
    return @trigger == 3 || @trigger == 4
  end
  
  #--------------------------------------------------------------------------
  # * Checks how the event should be updated.
  #--------------------------------------------------------------------------
  def check_update
    name = @event.name
    # Checks if the event is never to be updated. (For decoration)
    for pattern in NEVER_UPDATE_NAME_PATTERNS
      if (pattern.is_a?(String) && name.include?(pattern)) ||
        !(pattern =~ name).nil? 
        self.never_update = true
      end
    end
    # Checks if the event is to be always updated.
    for pattern in ALWAYS_UPDATE_NAME_PATTERNS
      if (pattern.is_a?(String) && name.include?(pattern)) ||
        !(pattern =~ name).nil? 
        self.always_update = true
      end
    end
    # Checks for special update for the particular id (overrules the patterns)
    special_update = SPECIAL_UPDATE_IDS[[@map_id,@id]]
    unless special_update.nil?
      # Checks if it never should be updated
      if special_update.downcase == 'n'
        self.never_update = true
        self.always_update = false
      # Checks if it always should be updated
      elsif special_update.downcase == 'a'
        self.always_update = true
        self.never_update = false
      end
    end
  end
  
  ##
  # Update mouse cursor information to the new page
  #
  def update_event_cursor
    # Mouse needs refreshing after this
    $game_map.mouse_refresh = true
    # Return if the event has no page
    return if @page.nil?
    # Retrieve the first event command
    first_command = @page.list[0]
    # Check that it is a comment
    if first_command.code == 108
      # Retrieve the comment
      comment = first_command.parameters[0]
      # Get the full comment
      i = 1
      next_command = @page.list[i]
      while next_command != nil && [108, 408].include?(next_command.code)
        comment += next_command.parameters[0]
        i += 1
        next_command = @page.list[i]
      end
      # Parse the comment
      @mouse_cursor = nil
      cursor = MouseCursor.new(nil, nil)
      # Check for icon change
      unless (comment =~ /\<cursor=(.+?)\>/).nil?
        cursor.icon = $1
        @mouse_cursor = cursor
      end
      # Check for text
      unless (comment =~ /\<cursor_text=(.+?)\>/).nil?
        cursor.text = $1
        @mouse_cursor = cursor
      end
    end
  end
  
  ####################
  # GENERATE METHODS #
  ####################
  # The method to alias and overwrite
  ax = [:jump, :moveto, :move_down, :move_left, :move_right, :move_up,
    :move_lower_left, :move_lower_right, :move_upper_left, :move_upper_right]
  for method in ax
    # Aliases the old method
    #new_method_as_string = 'zeriab_antilag_gmtev_' + method.to_s
    #new_method = new_method_as_string
    #alias_method(new_method, method)
    
    # Overwrites the old method
PROG = <<FIN
    def #{method}(*args)
      old_x = @x
      old_y = @y
      super(*args)
      unless old_x == @x && old_y == @y
        $game_map.move_event(old_x, old_y, self)
      end
    end
FIN
    # Evaluates the method definition
    eval(PROG)
  end
end
