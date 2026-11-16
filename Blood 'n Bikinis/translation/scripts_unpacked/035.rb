#==============================================================================
# ** Window_Selectable
#------------------------------------------------------------------------------
#  This window class contains cursor movement and scroll functions.
#==============================================================================

class Window_Selectable < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :index                    # cursor position
  attr_reader   :help_window              # help window
  attr_sec_accessor :scroll_wait, 0
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
  end
  #--------------------------------------------------------------------------
  # * Set Cursor Position
  #     index : new cursor position
  #--------------------------------------------------------------------------
  def index=(index)
    @index = index
    # Update Help Text (update_help is defined by the subclasses)
    if self.active and @help_window != nil
      update_help
    end
    # Update cursor rectangle
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Get Row Count
  #--------------------------------------------------------------------------
  def row_max
    # Compute rows from number of items and columns
    return (@item_max + @column_max - 1) / @column_max
  end
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    # Divide y-coordinate of window contents transfer origin by 1 row
    # height of 32
    return self.oy / 32
  end
  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    # If row is less than 0, change it to 0
    if row < 0
      row = 0
    end
    # If row exceeds row_max - 1, change it to row_max - 1
    if row > row_max - 1
      row = row_max - 1
    end
    # Multiply 1 row height by 32 for y-coordinate of window contents
    # transfer origin
    self.oy = row * 32
  end
  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    # Subtract a frame height of 32 from the window height, and divide it by
    # 1 row height of 32
    return (self.height - 32) / 32
  end
  #--------------------------------------------------------------------------
  # * Get Number of Items Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_item_max
    # Multiply row count (page_row_max) times column count (@column_max)
    return page_row_max * @column_max
  end
  #--------------------------------------------------------------------------
  # * Set Help Window
  #     help_window : new help window
  #--------------------------------------------------------------------------
  def help_window=(help_window)
    @help_window = help_window
    # Update help text (update_help is defined by the subclasses)
    if self.active and @help_window != nil
      update_help
    end
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
    # Get current row
    row = @index / @column_max
    # If current row is before top row
    if row < self.top_row
      # Scroll so that current row becomes top row
      self.top_row = row
    end
    # If current row is more to back than back row
    if row > self.top_row + (self.page_row_max - 1)
      # Scroll so that current row becomes back row
      self.top_row = row - (self.page_row_max - 1)
    end
    # Calculate cursor width
    cursor_width = self.width / @column_max - 32
    # Calculate cursor coordinates
    x = @index % @column_max * (cursor_width + 32)
    y = @index / @column_max * 32 - self.oy
    # Update cursor rectangle
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # If cursor is movable
    if self.active and @item_max > 0 and @index >= 0
      # If pressing down on the directional buttons
      if Input.repeat?(Input::DOWN)
        # Stop scrolling
        @scrolling = false
        # If column count is 1 and directional button was pressed down with no
        # repeat, or if cursor position is more to the front than
        # (item count - column count)
        if (@column_max == 1 and Input.trigger?(Input::DOWN)) or
           @index < @item_max - @column_max
          # Move cursor down
          $game_system.se_play($data_system.cursor_se)
          @index = (@index + @column_max) % @item_max
        end
      end
      # If the up directional button was pressed
      if Input.repeat?(Input::UP)
        # Stop scrolling
        @scrolling = false
        # If column count is 1 and directional button was pressed up with no
        # repeat, or if cursor position is more to the back than column count
        if (@column_max == 1 and Input.trigger?(Input::UP)) or
           @index >= @column_max
          # Move cursor up
          $game_system.se_play($data_system.cursor_se)
          @index = (@index - @column_max + @item_max) % @item_max
        end
      end
      # If the right directional button was pressed
      if Input.repeat?(Input::RIGHT)
        # Stop scrolling
        @scrolling = false
        # If column count is 2 or more, and cursor position is closer to front
        # than (item count -1)
        if @column_max >= 2 and @index < @item_max - 1
          # Move cursor right
          $game_system.se_play($data_system.cursor_se)
          @index += 1
        end
      end
      # If the left directional button was pressed
      if Input.repeat?(Input::LEFT)
        # Stop scrolling
        @scrolling = false
        # If column count is 2 or more, and cursor position is more back than 0
        if @column_max >= 2 and @index > 0
          # Move cursor left
          $game_system.se_play($data_system.cursor_se)
          @index -= 1
        end
      end
      # If R button was pressed
      if Input.repeat?(Input::R)
        # Stop scrolling
        @scrolling = false
        # If bottom row being displayed is more to front than bottom data row
        if self.top_row + (self.page_row_max - 1) < (self.row_max - 1)
          # Move cursor 1 page back
          $game_system.se_play($data_system.cursor_se)
          @index = [@index + self.page_item_max, @item_max - 1].min
          self.top_row += self.page_row_max
        end
      end
      # If L button was pressed
      if Input.repeat?(Input::L)
        # Stop scrolling
        @scrolling = false
        # If top row being displayed is more to back than 0
        if self.top_row > 0
          # Move cursor 1 page forward
          $game_system.se_play($data_system.cursor_se)
          @index = [@index - self.page_item_max, 0].max
          self.top_row -= self.page_row_max
        end
      end
    end
    # Update help text (update_help is defined by the subclasses)
    if self.active and @help_window != nil
      update_help
    end
    # Update cursor rectangle
    update_cursor_rect
  end
  
  ##
  # Get the height of the elements
  #
  def element_height
    return 32
  end
  
  ##
  # Get the height of the elements
  #
  def element_width
    return self.width / @column_max - 32
  end
  
  ##
  # Calculates the index from the x and y coordinate
  # Assumes (0,0) to be upper-left corner of the contents
  #
  def calculate_index(x, y)
    ex = x / element_width
    ey = y / element_height
    return ex + (ey + top_row) * @column_max
  end
  
  ##
  #
  #
  def cause_scroll(index)
    # Get  row
    row = index / @column_max
    # If row is before top row or more to back than back row
    return row < self.top_row || row > self.top_row + (self.page_row_max - 1)
  end
  
  ##
  # Update mouse position
  # Mouse enabled subclasses should overwrite this method
  #
  def mouse_move(mx, my)
    # Cursor position less than 0 implies that the cursor is hidden
    return if @index < 0 || !self.active
    # Store the coordinates
    @mx, @my = mx, my
    # Ignore the move if it is not over the contents
    if mx >= 16 && mx < width - 16
      index = calculate_index(mx-16, my-16)
      # If the index is valid
      if index < @item_max && index >= 0
        # Scroll wait
        if cause_scroll(index) && self.scroll_wait > 0
          return
        elsif cause_scroll(index)
          self.scroll_wait = System::Mouse::SCROLL_WAIT
          @scrolling = true
        else
          @scrolling = false
        end
        # Change the index
        @index = index
      end
    end
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  # Note: The mouse is over the window
  #
  def mouse_update
    # Only update if active
    return unless self.active
    # Scroll wait update
    if self.scroll_wait > 0
      self.scroll_wait -= 1
      return
    elsif @scrolling
      # See if the scrolling should continue
      index = calculate_index(@mx-16, @my-16)
      if cause_scroll(index) && index < @item_max && index >= 0
        self.scroll_wait = System::Mouse::SCROLL_WAIT
        @index = index
      else
        # Stop scrolling
        @scrolling = false
      end
    end
    @mx, @my = -1, -1 if @mx.nil?
    # Check for click
    if Mouse.trigger?(Mouse::LEFT_CLICK) && over_contents?(@mx, @my)
      owner.fireEvent(MouseEvent.new(self, Mouse::LEFT_CLICK, @index))
    end
  end
end
