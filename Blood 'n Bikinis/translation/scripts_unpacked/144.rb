class Interpreter
  def seamless_move(x, y, mode = 0)
    if mode == 0
      x = $game_variables[x]
      y = $game_variables[y]
    end
    # Register the current display x and y
    dx = $game_map.display_x / 4
    dy = $game_map.display_y / 4
    # Set up player position
    $game_player.moveto(x, y)
    # Find the difference in display x and y
    diffx = dx - $game_map.display_x / 4
    diffy = dy - $game_map.display_y / 4
    # Move the fog accordingly
    $game_map.instance_eval('@fog_ox += diffx')
    $game_map.instance_eval('@fog_oy += diffy')
  end
end