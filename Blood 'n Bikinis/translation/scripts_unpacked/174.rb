#==============================================================================
# ** Window_SkillStatus
#------------------------------------------------------------------------------
#  This window displays the skill user's status on the skill screen.
#==============================================================================

class Window_Options_Bar < Window_Base
  Text_In_Bar = "OPTIONS MENU"
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(arg=nil)
    super(128, 0, 384, 52)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = ["Impact", "Times New Roman"]
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    # Changes the font size of the text to 48
    self.contents.font.size = 26
    # Changes the color of the text to Teal
    self.contents.font.color = text_color(6)
    # Bolds the text
    self.contents.font.bold = true
    str = Text_In_Bar
    rect = self.contents.text_size(str)
    rect.width += 4   # If italic
    rect.x = (width-32-rect.width)/2
    rect.y = (height-32-rect.height)/2
    self.contents.draw_text(rect,str)
  end
end