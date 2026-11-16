#==============================================================================
# ** Window_Help
#------------------------------------------------------------------------------
#  This window shows skill and item explanations along with actor status.
#==============================================================================

class Window_MultiLine < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @text = []
  end
  #--------------------------------------------------------------------------
  # * Set Text
  #  text  : text string displayed in window
  #  align : alignment (0..flush left, 1..center, 2..flush right)
  #--------------------------------------------------------------------------
  def set_text(text, align = 0)
    # If at least one part of text and alignment differ from last time
    if text != @text or align != @align
      if text.size != @text.size
        resize(text.size)
      end
      # Redraw text
      self.contents.clear
      for i in 0...text.size
        text_elem = text[i]
        self.contents.font.color = normal_color
        self.contents.font.name = ['Verdana', 'Arial']
        self.contents.draw_text(4, i*32, self.width - 40, 32, text_elem, align)
      end
      @text = text
      @align = align
      @actor = nil
    end
    self.visible = true
  end
  ##
  #
  #
  def resize(lines)
    height = lines*32 + 32
    height = 64 if height < 64
    self.height = height
    self.contents.dispose unless self.contents.disposed?
    self.contents = Bitmap.new(width - 32, height - 32)
  end
end
