#==============================================================================
# ** Window_Questbook_Header
#------------------------------------------------------------------------------
#  This window designates quest information in the header of the questbook.
#==============================================================================

class Window_Questbook_Header < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #       quest : The quest which information will be used
  #--------------------------------------------------------------------------
  def initialize(quest)
    super(0, 0, 640, 128)
    # Creates the Bitmap
    self.contents = Bitmap.new(width - 32, height - 32)
    # Draws the header
    refresh(quest)
  end # def
  
  #--------------------------------------------------------------------------
  # * Refresh
  #       quest : The quest which information will be used
  #--------------------------------------------------------------------------
  def refresh(quest)
    # Redraw text
    self.contents.clear
    # checks if the quest is a Game_Quest.
    if quest.is_a?(Game_Quest)
      # Gets the current quest part
      current_quest = quest.current_quest
    else
      if quest.is_a?(Integer)
        # Draws the no completed quest header
        draw_noquest_header
      elsif quest == :active
        draw_active_quests_header
      elsif quest == :completed
        draw_completed_quests_header
      else
        # Draws the mainmenu header
        draw_mainmenu_header
      end
      # Stops processing this method (Refresh)
      return
    end
    # Changes the color of the text to Teal
    self.contents.font.color = text_color(4)
    # Bolds the text
    self.contents.font.bold = true
    # Draws the non-changing text in bold
    self.contents.draw_text(4, 0, 80, 32, "Who:")
    self.contents.draw_text(4, 32, 80, 32, "Where:")
    self.contents.draw_text(4, 64, 80, 32, "What:")
    # Unbolds the text
    self.contents.font.bold = false
    # Draws the owner of the quest next to "Who:" in gray
    self.contents.font.color = text_color(7)
    self.contents.draw_text(80, 0, 540, 32, current_quest.owner)
    # Draws the location of the quest next to "Where:" in blue
    self.contents.font.color = text_color(1)
    self.contents.draw_text(80, 32, 540, 32, current_quest.location)
    # Draws the goal of the quest next to "What:" in yellow
    self.contents.font.color = text_color(6)
    self.contents.draw_text(80, 64, 540, 32, current_quest.goal)
  end # def

  #--------------------------------------------------------------------------
  # * Draws the header in the case where no quests have been completed
  #--------------------------------------------------------------------------
  def draw_noquest_header
    # Changes the color of the text to Gray
    self.contents.font.color = text_color(7)
    # Draws the text centered in the window
    self.contents.draw_text(0, 32, 608, 32, "No quests have been completed", 1)
  end # def
  
  #--------------------------------------------------------------------------
  # * Draws the header in the case where the main menu icon is selected
  #--------------------------------------------------------------------------
  def draw_mainmenu_header
    # Changes the color of the text to Teal
    self.contents.font.color = text_color(4)
    # Draws the text centered in the window
    self.contents.draw_text(0, 32, 608, 32, "Return to the main menu", 1)
  end # def
  
  #--------------------------------------------------------------------------
  # * Draws the header in the case where the main menu icon is selected
  #--------------------------------------------------------------------------
  def draw_completed_quests_header
    # Changes the color of the text to Teal
    self.contents.font.color = text_color(4)
    # Draws the text centered in the window
    self.contents.draw_text(0, 32, 608, 32, "Switch to completed quests", 1)
  end # def
  
  #--------------------------------------------------------------------------
  # * Draws the header in the case where the main menu icon is selected
  #--------------------------------------------------------------------------
  def draw_active_quests_header
    # Changes the color of the text to Teal
    self.contents.font.color = text_color(4)
    # Draws the text centered in the window
    self.contents.draw_text(0, 32, 608, 32, "Switch to pending quests", 1)
  end # def
end # class