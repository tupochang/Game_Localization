#==============================================================================
# ** Window_Steps
#------------------------------------------------------------------------------
#  This window displays step count on the menu screen.
#==============================================================================

class Window_Steps < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 160, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Verdana", "Arial", "Times New Roman"]
    self.contents.font.size = 24
    
    cx = contents.text_size("m.").width
    self.contents.font.color = normal_color
    self.contents.draw_text(4, 0, 120-cx-2, 32, $game_party.steps.to_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(124-cx, 0, cx, 32, "m.", 2)
    
    #self.contents.font.color = system_color
    #self.contents.draw_text(4, 0, 120, 32, "Step Count")
    #self.contents.font.color = normal_color
    #self.contents.draw_text(4, 0, 120, 32, $game_party.steps.to_s, 2)
    #self.contents.draw_text(120, 0, 120, 32, "steps")
  end
end
