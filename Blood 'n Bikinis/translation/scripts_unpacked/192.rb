#==============================================================================
# * Window_Base
#------------------------------------------------------------------------------
#  Defines the draw_quest_icon method in Window_Base
#==============================================================================

class Window_Base
  #--------------------------------------------------------------------------
  # * Draw Quest Icon
  #     icon_name : filename of the icon
  #     x         : draw spot x-coordinate
  #     y         : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_quest_icon(icon_name, x, y)
    begin
      bitmap = RPG::Cache.picture(icon_name)
    rescue
      bitmap = RPG::Cache.picture(Data_Quest::PATH + Data_Quest::DEFAULT_ICON)
    end
    cw = 80
    ch = 80
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x, y, bitmap, src_rect)
  end # def
  
end # class