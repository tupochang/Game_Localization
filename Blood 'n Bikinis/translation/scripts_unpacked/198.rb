#==============================================================================
# ** Window_Questbook_Header
#------------------------------------------------------------------------------
#  This window designates quest information in the questbook.
#==============================================================================

class Window_Questbook_Info < Window_Base
  
  #============================================================================
  # ** Details
  #----------------------------------------------------------------------------
  #  This window contains the details of the quest.
  #  Only the text are show. (No window)
  #  Provides scrolling to the details only. (Not the header)
  #============================================================================
  class Details < Window_Base
    #------------------------------------------------------------------------
    # * Object Initialization
    #------------------------------------------------------------------------
    def initialize
      super(80, 130, 480, 290)
      # Must be higher than the parent window or the details will not be shown
      self.z = 210
      # No window, only text is shown
      self.opacity = 0
      # Creates the Bitmap
      self.contents = Bitmap.new(width - 32, height - 32)
    end # def
    
    #------------------------------------------------------------------------
    # * Refresh
    #       quest : The quest which information will be drawn
    #------------------------------------------------------------------------
    def refresh(quest)
      # Resets the position of the bitmap
      self.oy = 0
      # Splits the info into lines
      info = quest.info.split(/\n/)
      # Disposes of the old bitmap
      self.contents.dispose
      # Creates an appropriately big bitmap
      self.contents = Bitmap.new(width - 32, info.size*32+16)
      
      # Clears the bitmap
      self.contents.clear
      # Sets the text color to the standard color (White)
      self.contents.font.color = text_color(0)
      # Draws all the lines except the last on
      for i in 0...info.size - 1
        text = info[i].dup
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
        self.contents.draw_text(0, i*32, 480, 32, text)
      end # for
      
      # Sets the text color to yellow
      self.contents.font.color = text_color(6)
      # Only prints the last info if there actually are something to print
      if info[-1].is_a?(String)
        text = info[-1].dup
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
        # The last line of the info (if any is present) is consider as the
        # goal and positioned a bit different, centered and drawn in yellow.
        self.contents.draw_text(0, info.size*32-22, 440, 32, text, 1)
      end # if
    end # def
    
    #------------------------------------------------------------------------
    # * Update
    #------------------------------------------------------------------------
    def update
      # Calls the parent method
      super
      # Checks if the text is big enough for scrolling to be necessary
      if self.contents.height > height
        # Moves the text up if the UP key is pressed. (Warps)
        if Input.repeat?(Input::UP)
          self.oy = (self.oy - 10) % (self.contents.height - height + 64)
        end # if
        # Moves the text down if the DOWN key is pressed. (Warps)
        if Input.repeat?(Input::DOWN)
          self.oy = (self.oy + 10) % (self.contents.height - height + 64)
        end # if
      end # if
    end # def
    
  end # class
  
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(80, 60, 480, 360)
    # Puts this on top of the other windoes
    self.z = 200  
    # Creates the Bitmap
    self.contents = Bitmap.new(width - 32, height - 32)
    # Creates the detail part.
    @details = Details.new
    # The details window is by standard not immediately visible
    @details.visible = false
  end # def
  
  #--------------------------------------------------------------------------
  # * Refresh
  #       quest : The quest which information will be drawn (Game_Quest)
  #--------------------------------------------------------------------------
  def refresh(quest)
    return unless quest.is_a?(Game_Quest)
    # Gets the current_quest part
    current_quest = quest.current_quest
    # Redraw text (the top part)
    self.contents.clear
    # Draws who gave the current quest part
    self.contents.font.color = text_color(7)
    self.contents.font.bold = false
    self.contents.draw_text(0, 0, 440, 32, current_quest.owner, 1)
    # Draws the area
    self.contents.font.color = text_color(1)
    self.contents.draw_text(0, 32, 440, 32, current_quest.location, 1)
    # Draws a seperator line
    self.contents.font.color = text_color(0)
    self.contents.draw_text(0, 8, 480, 32,
                            "__________________________________________", 1)
    # Refreshes the details.
    @details.refresh(current_quest)
  end # def
  
  #--------------------------------------------------------------------------
  # * Update
  #--------------------------------------------------------------------------
  def update
    # Calls the parent method
    super
    # Updates the details if it is visible
    @details.visible = self.visible
    @details.update
  end # def

end # class