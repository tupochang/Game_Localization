#==============================================================================
# ** Warped Movement mix-in for subclasses of Window Selectable
#------------------------------------------------------------------------------
# Zeriab
# Version 1.0
# 2007-08-22 (Year-Month-Day)
#------------------------------------------------------------------------------
# * Description :
#
#   This is a mix-in module for windows subclassing designed to 'enhance' the
#   arrow-key movement system used to select the item by creating warping.
#   That is, if you are at the bottom and press down you will go up to the top
#   in the next column. Like-wise for down, left and right.
#------------------------------------------------------------------------------
# * Instructions :
#
#   Place the script anywhere above Main.
#   To give a subclass of Window_Selectable let it include the module
#
#   If you for example wanted to apply the module to Window_Item you should
#   write this code: (Must be below the original Window_Item
# ------------------------------------------
#   class Window_Item < Window_Selectable
#     include Window_Selectable_Warped
#   end
# ------------------------------------------
#
#   Here is a version for Window_Skill. You get the idea.
# ------------------------------------------
#   class Window_Skill < Window_Selectable
#     include Window_Selectable_Warped
#   end
# ------------------------------------------
#
#   Note: Don't include this module in Window_Selectable ~
#         May cause issues with Windows where the update method is used
#==============================================================================

#==============================================================================
# ** module Window_Selectable_Warped
#==============================================================================
module Window_Selectable_Warped
  #----------------------------------------------------------------------------
  # * Frame Update
  #----------------------------------------------------------------------------
  def update
    last_index = @index
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