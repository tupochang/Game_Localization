#==============================================================================
# ** Window_Command
#------------------------------------------------------------------------------
#  This window deals with general command choices.
#==============================================================================

class Window_Horizontal_Command < Window_Selectable_Type_2
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     width    : window width
  #     commands : command text string array
  #--------------------------------------------------------------------------
  def initialize(width, commands)
    # Compute window height from command quantity
    super(0, 0, width, 64)
    @item_max = commands.size
    @column_max = @item_max
    @commands = commands
    self.contents = Bitmap.new(width - 32, height-32)
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    self.contents.font.size = 27
    for i in 0...@item_max
      draw_item(i, normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #     color : text color
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    cursor_width = self.width / @column_max - 32
    x = index % @column_max * (cursor_width + 32)
    rect = Rect.new(x-4, 0, cursor_width+8, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index], 1)
  end
  #--------------------------------------------------------------------------
  # * Disable Item
  #     index : item number
  #--------------------------------------------------------------------------
  def disable_item(index)
    draw_item(index, disabled_color)
  end
  ##
  # Get the height of the elements
  #
  def element_width
    return self.width / @item_max
  end
end
