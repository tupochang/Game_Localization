#==============================================================================
# ** Window_Questbook
#------------------------------------------------------------------------------
#  This window designates the quest selection on the questbook screen.
#==============================================================================

class Window_Questbook < Window_Selectable
  # Constants
  ACTIVE_QUESTS_ICON_PATH = "Quest/Icons/activequests.png"
  COMPLETED_QUESTS_ICON_PATH = "Quest/Icons/donequests.png"
  MAIN_MENU_ICON_PATH = "Quest/Icons/mainmenu.png"
  
  # Attributes
  #attr_accessor   :active_quests # Tells whether active quests are show or not
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(questset)
    super(0, 128, 640, 352)
    # Saves the quest set given
    @data = questset
    # Old data (stores refrences to old data)
    @old_data = {}
    # Amount of items
    @item_max = @data.size
    # The amount of items on each line   (Items per row)
    @column_max = 6
    # Starts on index 0 (Top-Left)
    @index = 0
    # Active quests are shown at start up
    @active_quests = true
    # Creates Bitmap
    self.contents = Bitmap.new(width - 32, @item_max / @column_max * 96 + 192)
    refresh
  end # def
  
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    # Redraw text
    self.contents.clear
    # Draws the icons
    for i in 0...@item_max
      draw_icon(i,@data[i].current_quest.get_icon)
    end # for
    # Add main menu and other page icons
    @item_max = @data.size + 2
    draw_icon(@item_max - 1, MAIN_MENU_ICON_PATH)
    if @active_quests
      draw_icon(@item_max - 2, COMPLETED_QUESTS_ICON_PATH)
    else
      draw_icon(@item_max - 2, ACTIVE_QUESTS_ICON_PATH)
    end
    # Sets the cursor to the first element (there will always be an element)
    @index = 0
  end # def

  #--------------------------------------------------------------------------
  # * Draws the icon of the quest at the i'th space
  #--------------------------------------------------------------------------
  def draw_icon(i, icon_name)
    # Calculates the x- and y-coordinates
    x = (i % @column_max) * 99 + 16
    y = (i / @column_max) * 96 - 10
    # Draws the given quest icon at the given position
    draw_quest_icon(icon_name, x, y + 18)
  end # def
  
  #--------------------------------------------------------------------------
  # * Sets a new set quests as data
  #--------------------------------------------------------------------------
  def set_data(questset, active_quests)
    if questset == @data && active_quests == @active_quests
      return
    end
    # Stores old data
    @old_data[[@data,@active_quests]] = self.contents
    # Sets whether or not the questset is of the active quests
    @active_quests = active_quests
    # Sets the questset as data
    @data = questset
    # Amount of items
    @item_max = @data.size
    # Creates Bitmap
    if @old_data[[@data,@active_quests]] != nil
      self.contents = @old_data[[@data,@active_quests]]
    else
      self.contents = Bitmap.new(width - 32, @item_max / @column_max * 96 + 192)
    end
    # Refreshes (redraws) the window with the new data
    refresh
  end
  
  #--------------------------------------------------------------------------
  # * Update Cursor Rectangle
  #--------------------------------------------------------------------------
  def update_cursor_rect
    # If cursor position is less than 0
    if @index < 0
      self.cursor_rect.empty
      return
    end # if
    # Get current row
    row = @index / @column_max
    # If current row is before top row
    if row < self.top_row
      # Scroll so that current row becomes top row
      self.top_row = row
    end # if
    # If current row is more to back than back row
    if row > self.top_row + (self.page_row_max - 1)
      # Scroll so that current row becomes back row
      self.top_row = row - (self.page_row_max - 1)
    end # if
    # Calculate cursor coordinates
    x = (@index % @column_max) * 99 + 8       #112
    y = (@index / @column_max) * 96 - self.oy
    self.cursor_rect.set(x, y, 96, 96)
  end # def
  
  #--------------------------------------------------------------------------
  # * Get Top Row
  #--------------------------------------------------------------------------
  def top_row
    # Divide y-coordinate of window contents transfer origin by 1 row
    # height of 96
    return self.oy / 96
  end # def

  #--------------------------------------------------------------------------
  # * Set Top Row
  #     row : row shown on top
  #--------------------------------------------------------------------------
  def top_row=(row)
    row = row % row_max
    self.oy = row * 96
  end # def

  #--------------------------------------------------------------------------
  # * Get Number of Rows Displayable on 1 Page
  #--------------------------------------------------------------------------
  def page_row_max
    # Subtract a frame height of 32 from the window height, and divide it by
    # 1 row height of 96
    return (self.height - 32) / 96
  end # def
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    super
    # Disposes the stored bitmaps
    @old_data.each_value {|value| value.dispose}
  end
  
  ##
  # Get the height of the elements
  #
  def element_height
    return 96
  end
  
  ##
  # Get the height of the elements
  #
  def element_width
    return 100
  end
end # class