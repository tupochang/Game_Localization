#==============================================================================
# ** Window_SkillStatus
#------------------------------------------------------------------------------
#  This window displays the skill user's status on the skill screen.
#==============================================================================

class Window_Top10 < Window_Base
  DOWN = 1
  UP = 2
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(arg=nil)
    super(0, 0, 480, 400)
    self.contents = Bitmap.new(width - 32, 40) #height - 32)
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    @score = Sprite.new
    @const = System::Hall_Of_Fame
    @wait = 0
    @pps = 0
    refresh
  end

  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(actor_array=nil, text_array=nil, command=nil)
    self.contents.clear
    return  if actor_array.nil? || text_array.nil?
    #drawage
    command = "Tops"  if command.nil?
    @actorsize = @const::MAX_ACTORS < actor_array.size ? @const::MAX_ACTORS : actor_array.size
    #self.contents = Bitmap.new(width - 32, 40)# + actorsize * 33 - 2)
    @score.bitmap.dispose unless @score.nil? || @score.bitmap.nil?
    @score.bitmap = Bitmap.new(width - 32, @actorsize * 33 - 2)
    @score.bitmap.font.name = ["Impact", "Arial", "Times New Roman"]
    @score.x = self.x + 18
    @score.y = self.y + 60
    @score.z = self.z + 10
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    draw_title(command)
    for i in 0...text_array.size
      break   if i >= @actorsize
      draw_item(i, actor_array[i], text_array[i])
    end
    @wait = @const::WAIT_BEFORE_SCROLL
    @direction = DOWN
    @score.src_rect.set(0, 0, width - 32, height - 72)
    @score_height = @score.bitmap.height
  end
  
  #--------------------------------------------------------------------------
  # * Change of z-value
  #--------------------------------------------------------------------------
  def z=(*args)
    super(*args)
    @score.z = self.z + 10 if !@score.nil?
  end
  
  #--------------------------------------------------------------------------
  # * DrawItem
  #--------------------------------------------------------------------------
  def draw_item(pos, actor, text)
    return   if pos >= @actorsize
    # getting the font
    font = @score.bitmap.font
    # Gets the name
    name = (pos+1).to_s + ". " + actor.name
    # Calculates the rect of the title
    rect = @score.bitmap.text_size(name)
    # text_size does not consider that italic and bold require extra size
    # Makes the rect a wee bit broader to composition for the text being bolded
    rect.width += 2
    # Sets the hight
    rect.y = pos * 33 #(self.contents.height - 40)*pos/MAX_ACTORS
    # Draws the actor name in the given rect
    @score.bitmap.draw_text(rect,name)
    # Draws the text in the given rect
    rect.width = @score.bitmap.text_size(text.to_s).width + 4
    rect.x = @score.bitmap.width - rect.width
    @score.bitmap.draw_text(rect,text.to_s)
  end
  
  #--------------------------------------------------------------------------
  # * Draws the title with a fixed-width underline
  #--------------------------------------------------------------------------
  def draw_title(title)
    # getting the font
    font = self.contents.font
    # storing previous properties of the font
    size_ori = font.size
    bold_ori = font.bold
    color_ori = font.color.dup
    # Changes the properties of the font
    font.bold = true
    font.size = 32
    # Calculates the rect of the title
    rect = self.contents.text_size(title)
    # text_size does not consider that italic and bold require extra size
    # Makes the rect a wee bit broader to composition for the text being bolded
    rect.width += 2
    # Centers the text
    rect.x = (self.contents.width - rect.width)/2
    # Draws the title in the given rect
    self.contents.draw_text(rect,title)
    
    # Width based on size of the window
    rect.width = self.contents.width - 20
    # Changes the rect for the underline
    rect.y += rect.height
    # Centers the line
    rect.x = (self.contents.width - rect.width)/2
    # Line thickness
    rect.height = 3
    font.color = Color.new(255,255,255,200)
    self.contents.fill_rect(rect, self.contents.font.color) 
    
    # Repeat of above
    rect.width = self.contents.width - 10
    rect.y += rect.height / 2
    rect.x = (self.contents.width - rect.width)/2
    rect.height = 1
    self.contents.fill_rect(rect, self.contents.font.color)
    
    # setting previous properties back to the font
    font.size = size_ori
    font.bold = bold_ori
    font.color = color_ori
  end
  
  #--------------------------------------------------------------------------
  # * Frame update
  #--------------------------------------------------------------------------
  def update
    # No scroll = no need to update
    return if @actorsize <= 10
    if @wait > 0
      @wait -= 1
      return
    end
    @pps += @const::SCROLL_SPEED
    speed = 0
    if @pps > 1
      speed = @pps.truncate
      @pps = @pps - speed
    else
      return
    end
    if @direction == DOWN
      new_y = @score.src_rect.y + speed
      if new_y > (@actorsize - 10) * 33
        @score.src_rect.y = (@actorsize - 10) * 33
        @wait = @const::SCROLL_WAIT
        @direction = UP
      else
        @score.src_rect.y += speed
      end
    elsif @direction == UP
      new_y = @score.src_rect.y - speed
      if new_y < 0
        @score.src_rect.y = 0
        @wait = @const::SCROLL_WAIT
        @direction = DOWN
      else
        @score.src_rect.y -= speed
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    @score.dispose
    super
  end
end
