#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_MenuStatus < Window_Selectable_Type_2
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, 500, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    refresh
    self.active = false
    self.index = -1
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh 
    self.contents.clear 
    self.contents.font.name = ["Verdana", "Arial", "Times New Roman"]
    self.contents.font.size = 13
    @item_max = $game_party.actors.size 
    for i in 0...$game_party.actors.size 
      x = 94 
      y = i * 112
      actor = $game_party.actors[i] 
      draw_actor_face(actor, x - 55, y + 102) 
      draw_actor_name(actor, x+78, y+12) 
      draw_actor_class(actor, x + 90, y + 28) 
      draw_actor_level(actor, x+242, y+12) 
      draw_actor_state(actor, x + 90, y + 76) 
      draw_actor_exp(actor, x+210, y + 60) 
      draw_actor_hp(actor, x + 78, y + 44) 
      draw_actor_sp(actor, x + 78, y + 60) 
    end 
  end 

  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
    else
      self.cursor_rect.set(0, @index * 112, self.width - 26, 112)
    end
  end
  
  ##
  # Get the height of the elements
  #
  def element_height
    return 112
  end
end
