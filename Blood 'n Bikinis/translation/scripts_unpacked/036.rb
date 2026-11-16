class Window_Selectable_Type_2 < Window_Selectable
  #----------------------------------------------------------------------------
  # * Frame Update
  #----------------------------------------------------------------------------
  def update
    last_index = @index
    # original update method is called
    super
    if last_index == @index && active && @item_max > 1
      if Input.repeat?(Input::DOWN)
        # Move cursor down
        $game_system.se_play($data_system.cursor_se)
        @index = (@index % @column_max + 1) % @column_max
        @index = 0  if @index >= @item_max
      end
      # If the up directional button was pressed
      if Input.repeat?(Input::UP)
        # Move cursor up
        $game_system.se_play($data_system.cursor_se)
        row_max = @item_max / @column_max
        @index += @column_max * row_max - 1
        @index -= @column_max  if @index >= @item_max
        @index = @item_max - 1  if @index < 0
      end
      # If the right directional button was pressed
      if Input.repeat?(Input::RIGHT)
        # Move cursor right
        $game_system.se_play($data_system.cursor_se)
        @index = (@index + 1) % @item_max
      end
      # If the left directional button was pressed
      if Input.repeat?(Input::LEFT)
        # Move cursor left
        $game_system.se_play($data_system.cursor_se)
        @index = (@index - 1) % @item_max
      end
    end
  end
end