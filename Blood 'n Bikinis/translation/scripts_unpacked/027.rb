#==============================================================================
# ** Game_Player
#------------------------------------------------------------------------------
#  This class handles the player. Its functions include event starting
#  determinants and map scrolling. Refer to "$game_player" for the one
#  instance of this class.
#==============================================================================

class Game_Player < Game_Character
  #--------------------------------------------------------------------------
  # * Invariables
  #--------------------------------------------------------------------------
  CENTER_X = (320 - 16) * 4   # Center screen x-coordinate * 4
  CENTER_Y = (240 - 16) * 4   # Center screen y-coordinate * 4
  #--------------------------------------------------------------------------
  # * Passable Determinants
  #     x : x-coordinate
  #     y : y-coordinate
  #     d : direction (0,2,4,6,8)
  #         * 0 = Determines if all directions are impassable (for jumping)
  #--------------------------------------------------------------------------
  def passable?(x, y, d)
    # Get new coordinates
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # If coordinates are outside of map
    unless $game_map.valid?(new_x, new_y)
      # Impassable
      return false
    end
    # If debug mode is ON and ctrl key was pressed
    if $DEBUG and Input.press?(Input::CTRL)
      # Passable
      return true
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Set Map Display Position to Center of Screen
  #--------------------------------------------------------------------------
  def center(x, y)
    max_x = ($game_map.width - 20) * 128
    max_y = ($game_map.height - 15) * 128
    $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
    $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max
  end
  #--------------------------------------------------------------------------
  # * Move to Designated Position
  #     x : x-coordinate
  #     y : y-coordinate
  #--------------------------------------------------------------------------
  def moveto(x, y)
    super
    # Stop pathfinding
    @pathfinding = false
    # Centering
    center(x, y)
    # Make encounter count
    make_encounter_count
  end
  #--------------------------------------------------------------------------
  # * Increaase Steps
  #--------------------------------------------------------------------------
  def increase_steps
    super
    # If move route is not forcing
    unless @move_route_forcing
      # Increase steps
      $game_party.increase_steps
      # Number of steps are an even number
      if $game_party.steps % 2 == 0
        # Slip damage check
        $game_party.check_map_slip_damage
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Encounter Count
  #--------------------------------------------------------------------------
  def encounter_count
    return @encounter_count
  end
  #--------------------------------------------------------------------------
  # * Make Encounter Count
  #--------------------------------------------------------------------------
  def make_encounter_count
    # Image of two dice rolling
    if $game_map.map_id != 0
      n = $game_map.encounter_step
      @encounter_count = 5
      @encounter_rate = rand(n/2) + n/2 + 1
      @min_steps = $game_variables[System::MINIMUM_STEPS_VARIABLE]
    end
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # If party members = 0
    if $game_party.actors.size == 0
      # Clear character file name and hue
      @character_name = ""
      @character_hue = 0
      # End method
      return
    end
    # Get lead actor
    actor = $game_party.actors[0]
    # Set character file name and hue
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    # Initialize opacity level and blending method
    @opacity = 255
    @blend_type = 0
  end
  #--------------------------------------------------------------------------
  # * Same Position Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_here(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Retrives the events on the specified tile
    events = $game_map.event_map[[@x,@y]]
    unless events.nil?
      # Loop through events on tile
      for event in events
        # If event triggers are consistent
        if triggers.include?(event.trigger)
          # If starting determinant is same position event (other than jumping)
          if not event.jumping? and event.over_trigger?
            event.start
            result = true
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Front Event Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_there(triggers)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Calculate front event coordinates
    new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    # Retrives the events on the specified tile
    events = $game_map.event_map[[new_x,new_y]]
    unless events.nil?
      # Loop through events on tile
      for event in events
        # If event triggers are consistent
        if triggers.include?(event.trigger)
          # If starting determinant is front event (other than jumping)
          if not event.jumping? and not event.over_trigger?
            event.start
            result = true
          end
        end
      end
    end
    # If fitting event is not found
    if result == false
      # If front tile is a counter
      if $game_map.counter?(new_x, new_y)
        # Calculate 1 tile inside coordinates
        new_x += (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y += (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        # Retrives the events on the specified tile
        events = $game_map.event_map[[new_x,new_y]]
        unless events.nil?
          # Loop through events on tile
          for event in events
            # If event triggers are consistent
            if triggers.include?(event.trigger)
              # If starting determinant is front event (other than jumping)
              if not event.jumping? and not event.over_trigger?
                event.start
                result = true
              end
            end
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Touch Event Starting Determinant
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    result = false
    # If event is running
    if $game_system.map_interpreter.running?
      return result
    end
    # Retrives the events on the specified tile
    events = $game_map.event_map[[x,y]]
    unless events.nil?
      # Loop through events on tile
      for event in events
        # If event coordinates and triggers are consistent
        if [1,2].include?(event.trigger)
          # If starting determinant is front event (other than jumping)
          if not event.jumping? and not event.over_trigger?
            event.start
            result = true
          end
        end
      end
    end
    return result
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Remember whether or not moving in local variables
    last_moving = moving?
    # If moving, event running, move route forcing, and message window
    # display are all not occurring
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # Move player in the direction the directional button is being pressed
      case Input.dir4
      when 2
        move_down
        @pathfinding = false
      when 4
        move_left
        @pathfinding = false
      when 6
        move_right
        @pathfinding = false
      when 8
        move_up
        @pathfinding = false
      else
        if @pathfinding
          pathfind_next_move
        end
      end
    end
    # Remember coordinates in local variables
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # If character moves down and is positioned lower than the center
    # of the screen
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # Scroll map down
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # If character moves left and is positioned more let on-screen than
    # center
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # Scroll map left
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # If character moves right and is positioned more right on-screen than
    # center
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # Scroll map right
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # If character moves up and is positioned higher than the center
    # of the screen
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # Scroll map up
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # If not moving
    unless moving?
      # If player was moving last time
      if last_moving
        # Event determinant is via touch of same position event
        result = check_event_trigger_here([1,2])
        # If event which started does not exist
        if result == false
          # Disregard if debug mode is ON and ctrl key was pressed
          unless $DEBUG and Input.press?(Input::CTRL)
            # Encounter countdown
            if @encounter_count > 0
              if @min_steps > 0
                @min_steps -= 1
              else
                @encounter_count = rand(@encounter_rate)
              end
            end
          end
        end
      end
      # If C button was pressed
      if Input.trigger?(Input::C)
        # Same position and front event determinant
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
      end
    end
    # Unless Interpretter Running, Forcing a Route or Message Showing
    unless $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      if Mouse.trigger?(Mouse::LEFT_CLICK)
        mx, my = Mouse.pos
        rx, ry = (mx + $game_map.display_x/4) / 32, (my + $game_map.display_y/4) / 32
        goto(rx, ry)
      end
    end
  end
  ##
  # Simple Pathfinding
  #
  def goto(x, y)
    @goto_x = x
    @goto_y = y
    @pathfinding = true
  end
  ##
  # Force move disables Pathfinding
  #
  def force_move_route(move_route)
    @pathfinding = false
    super
  end
  ##
  # Retrieve next pathfinding move
  #
  def pathfind_next_move
    # Find possible moves
    possible_moves = []
    possible_moves << 4 if @goto_x < @x && passable?(@x, @y, 4)
    possible_moves << 6 if @goto_x > @x && passable?(@x, @y, 6)
    possible_moves << 8 if @goto_y < @y && passable?(@x, @y, 8)
    possible_moves << 2 if @goto_y > @y && passable?(@x, @y, 2)
    if possible_moves.empty?
      # No possible moves => pathfinding finished
      @pathfinding = false
      if (@goto_x - @x).abs + (@goto_y - @y).abs <= 0
        check_event_trigger_here([0])
      else
        # Check for possible change of direction
        possible_moves << 4 if @goto_x < @x
        possible_moves << 6 if @goto_x > @x
        possible_moves << 8 if @goto_y < @y
        possible_moves << 2 if @goto_y > @y
        #return if possible_moves.empty?
        unless possible_moves.include?(direction)
          turn = possible_moves[rand(possible_moves.size)]
          case turn
          when 2
            turn_down
          when 4
            turn_left
          when 6
            turn_right
          when 8
            turn_up
          end
        end
        # Calculate next tile
        new_x = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
        new_y = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
        dist = $game_map.counter?(new_x, new_y) ? 2 : 1
        if (@goto_x - @x).abs + (@goto_y - @y).abs <= dist
          check_event_trigger_there([0,1,2])
        else
          check_event_trigger_there([1,2])
        end
      end
    else
      # Choose a possible move at random
      move = possible_moves[rand(possible_moves.size)]
      case move
      when 2
        move_down
      when 4
        move_left
      when 6
        move_right
      when 8
        move_up
      end
    end
  end
end
