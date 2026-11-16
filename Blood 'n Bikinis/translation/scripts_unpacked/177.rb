class Window_Option_Command < Window_Base
  attr_accessor :index
  def initialize(width, current)
    @current_index = current ? 0 : 1
    @commands = ['YES', 'NO']
    super(0, 0, width, 52) #56
    self.index = @current_index
    self.contents = Bitmap.new(width - 32, height-32)
    refresh
  end
  
  def update
    super
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Update Cursor Rectangle
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # If cursor position is less than 0
    if @index < 0
      self.cursor_rect.empty
      return
    end
    # Calculate cursor width
    cursor_width = self.width / 2 - 32
    # Calculate cursor coordinates
    x = @index * (cursor_width + 32)
    # Update cursor rectangle
    self.cursor_rect.set(x, 0, cursor_width, 20) #32
  end
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Times New Roman"]
    self.contents.font.size = 18
    if @current_index == 0
      draw_item(0, System::Options::CURRENT_COLOR)
      draw_item(1, System::Options::OTHER_COLOR)
    else
      draw_item(0, System::Options::OTHER_COLOR)
      draw_item(1, System::Options::CURRENT_COLOR)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #     color : text color
  #--------------------------------------------------------------------------
  def draw_item(index, color)
    self.contents.font.color = color
    cursor_width = self.width / 2 - 32
    x = index % 2 * (cursor_width + 32)
    rect = Rect.new(x-4, 0, cursor_width+8, 16) #32
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index], 1)
  end
end