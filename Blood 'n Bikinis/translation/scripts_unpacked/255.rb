class Game_Player < Game_Character
  alias_method :zeriab_mouse_update, :update
  ##
  # Add pathfinding functionality to the update method
  #
  def update
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      if Input.dir4 != 0
        @pathfinding = false
      else
        if @pathfinding
          pathfind_next_move
        end
      end
    end
    zeriab_mouse_update
    # Check for mouse click
    unless $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      if Mouse.trigger?(Mouse::LEFT_CLICK)
        mx, my = Mouse.pos
        rx, ry = (mx + $game_map.display_x.to_i/4) / 32, (my + $game_map.display_y.to_i/4) / 32
        goto(rx, ry)
      end
    end
  end
  
  ##
  # Pathfinding stops whenever the player teleports
  # 
  alias_method :zeriab_mouse_moveto, :moveto
  def moveto(*args)
    # Stop pathfinding
    @pathfinding = false
    zeriab_mouse_moveto(*args)
  end
  
  ##
  # Pathfind to the coordinates
  #
  def goto(x, y)
    if (@x - x).abs + (@y - y).abs > 2
      @path_replan = 0
      bfs_path(x, y)
    else
      simple_pathfinding(x, y)
    end
  end
  
  ##
  # Check if the destination has been reached
  #
  def path_check_dest(new_x, new_y, map, dist, d)
    end_dist = (new_x - @to_x).abs + (new_y - @to_y).abs
    # Target location
    if end_dist == 0
      map[new_x, new_y] = dist + 1
      @path_found = true
      return true
    end
    # Over the counter
    if end_dist == 1 && $game_map.counter?(new_x, new_y)
      next_x = new_x + (d == 6 ? 1 : d == 4 ? -1 : 0)
      next_y = new_y + (d == 2 ? 1 : d == 8 ? -1 : 0)      
      if next_x == @to_x && next_y == @to_y
        map[new_x, new_y] = dist + 1
        map[next_x, next_y] = dist + 2
        @path_found = true
        @path_counter = true
        return true
      end
    end
    return false
  end
  
  ##
  # Use standard sematics for d to check traversal in the particular direction
  #
  def traverse_direction(x, y, map, d)
    # Get new coordinates - Taken from the passable? method
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # Check boundaries
    return if new_x < 0 || new_x >= map.xsize
    return if new_y < 0 || new_y >= map.ysize
    # Fall out if exit point has been found
    if path_check_dest(new_x, new_y, map, map[x, y], d)
      # Set distance
      map[new_x, new_y] = map[x, y] + 1
      # Add new position
      @queue.clear
      return true
    end
    # Check if traversing is possible
    new_dist = map[new_x, new_y]
    if new_dist == 0 && passable?(x, y, d)
      # Set distance
      map[new_x, new_y] = map[x, y] + 1
      # Add new position
      @queue << [new_x, new_y]
    end
    return false
  end
  
  DIRECTIONS = [2, 4, 6, 8]
  def traverse(x, y, map)
    for direction in DIRECTIONS
      break if traverse_direction(x, y, map, direction)
    end    
  end
  
  def retrieve_pos_direction(map, pos, dist, d, count)
    x, y = pos
    # Get new coordinates - Taken from the passable? method
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    reverse_d = 10 - d
    # Check boundaries
    return nil if new_x < 0 || new_x >= map.xsize
    return nil if new_y < 0 || new_y >= map.ysize
    return nil unless map[new_x, new_y] == dist
    return nil unless passable?(new_x, new_y, reverse_d) || 
                      $game_map.counter?(x, y) || 
                      count < 2
    return [new_x, new_y]
  end
  
  def retrieve_pos(map, pos, dist, count)
    for direction in DIRECTIONS
      new_pos = retrieve_pos_direction(map, pos, dist, direction, count)
      return new_pos unless new_pos.nil?
    end    
  end
  
  def retrieve_path(map, to_x, to_y)
    length = map[to_x, to_y] - 1
    path = []
    pos = [to_x, to_y]
    path << pos
    count = 1
    length.downto(2) do |dist|
      pos = retrieve_pos(map, pos, dist, count)
      path << pos
      count += 1
    end
    return path
  end
  
  def path_check_target(to_x, to_y)
    # No events at target - Only pathfind towards passable tiles
    return passable?(to_x, to_y, 0) || 
           $game_map.event_map[[to_x, to_y]] ||
           $game_map.counter?(to_x, to_y)
  end
  
  ##
  # Create distance map using Breadth-First Search
  #
  MAX_CHECKS = 5000
  def create_map(to_x, to_y)
    ## DEBUG INFO
    start = Time.now
    
    # Check target_position
    unless path_check_target(to_x, to_y)
      #p "Target easily not reachable, ignoring request"
      return nil
    end
    
    # Use the efficient RGSS specific Table class for storing the distance map
    dist_map = Table.new($game_map.width, $game_map.height)
    # Start from the current player position
    # Note: 0 is the default value for all elements in the Table class
    #       Conceptually treat 0 as infinity. For values > 0 the actual distance
    #       can be retrieved by subtracting 1
    dist_map[@x, @y] = 1
    @to_x = to_x
    @to_y = to_y
    @path_counter = false
    
    # Start from the players current position
    @path_found = false
    @queue = [[@x, @y]]
    count = 0
    until @queue.empty? || @path_found
      count += 1
      break if count > MAX_CHECKS
      x, y = @queue.shift
      if x == @to_x and y == @to_y
        @path_found = true
        break
      else
        traverse(x, y, dist_map)
      end
    end
    
    mid = Time.now
    # Retrieve path
    path = nil
    if @path_found
      path = retrieve_path(dist_map, @to_x, @to_y)
    end
    
    ## DEBUG INFO
    t = Time.now - start
    tm = mid - start
    l = path.nil? ? 0 : path.size
    #print "Path found: #{path_found}    Path size: #{l}    Time: #{t} (#{tm})    Count: #{count}"
    
    return path
  end
  
  ##
  # Do Breadth-First Search
  #
  def bfs_path(x, y)
    @path = create_map(x, y)
    if @path.is_a?(Array)
      @goto_x = x
      @goto_y = y
      @pathfinding = true
      @path_type = :list
    end
  end
  
  ##
  # Simple Pathfinding
  #
  def simple_pathfinding(x, y)
    @goto_x = x
    @goto_y = y
    @pathfinding = true
    @path_type = :goal
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
    if @path_type == :list
      pathfind_next_move_list
    elsif @path_type == :goal
      pathfind_next_move_goal
    end
  end
  
  REPLAN_ATTEMPTS = 5
  def path_check_direction(d)
    return true if passable?(@x, @y, d)
    # Attempt to replan a few times
    if @path_replan < REPLAN_ATTEMPTS
      bfs_path(@goto_x, @goto_y)
      @path_replan += 1
    else
      # Cancel rest the route
      @path.clear
    end
    return false
  end
  
  def path_move(next_pos)
    x, y = next_pos
    # Move accordingly
    if x < @x
      move_left if path_check_direction(4)
    elsif x > @x
      move_right if path_check_direction(6)
    elsif y < @y
      move_up if path_check_direction(8)
    elsif y > @y
      move_down if path_check_direction(2)
    end    
  end
  
  
  ##
  # List-based pathfinding
  #
  def pathfind_next_move_list
    # Defensive check
    if @path.nil?
      @pathfinding = false
      return
    end
    
    # Fetch next position
    next_pos = @path.pop
    path_move(next_pos)
    
    # Pathfinding ends when the list has been emptied
    if @path.nil? || @path.empty?
      @pathfinding = false
      return
    elsif (@goto_x - @x).abs + (@goto_y - @y).abs < 2 ||
        ((@goto_x - @x).abs == 2 && (@goto_y - @y).abs == 0) ||
        ((@goto_x - @x).abs == 0 && (@goto_y - @y).abs == 2)
      @path_type = :goal
    end
  end

  ##
  # Simple goal-based pathfinding
  #
  def pathfind_next_move_goal
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
