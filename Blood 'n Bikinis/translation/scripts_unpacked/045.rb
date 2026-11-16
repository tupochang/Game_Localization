#==============================================================================
# ** Window_Skill
#------------------------------------------------------------------------------
#  This window displays usable skills on the skill and battle screens.
#==============================================================================

class Window_Skill < Window_Selectable_Type_2
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 128, 640, 352)
    @actor = actor
    @column_max = 2
    refresh
    self.index = 0
    # If in battle, move window to center of screen
    # and make it semi-transparent
    if $game_temp.in_battle
      self.y = 64
      self.height = 336 #BvZ
      self.back_opacity = 160
    end
  end
  #--------------------------------------------------------------------------
  # * Acquiring Skill
  #--------------------------------------------------------------------------
  def skill
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    for i in 0...@actor.skills.size
      skill = $game_system.skills[@actor.skills[i]]
      if skill != nil
        @data.push(skill)
      end
    end
    # If item count is not 0, make a bit map and draw all items
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    skill = @data[index]
    if @actor.skill_can_use?(skill.id)
      self.contents.font.color = normal_color
    else
      if @actor.sp_costf(skill) == 999 # EDIT COSTF
        self.contents.font.color = text_color(2)
      elsif @actor.sp_costf(skill) == 998
        self.contents.font.color = text_color(5)
      elsif @actor.sp_costf(skill) == 997
        self.contents.font.color = text_color(3)
        elsif @actor.sp_costf(skill) == 996
        self.contents.font.color = text_color(4)
        elsif @actor.sp_costf(skill) == 995
        self.contents.font.color = normal_color
        elsif @actor.sp_costf(skill) == 994
        self.contents.font.color = disabled_color
        else
        self.contents.font.color = disabled_color
        end
    end
    x = 4 + index % 2 * (288 + 32)
    y = index / 2 * 32
    rect = Rect.new(x, y, self.width / @column_max - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(skill.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 204, 32, skill.name, 0)
    if @actor.sp_costf(skill) < 994 # EDIT COST 999-998-997-996-995-994 MP
    self.contents.draw_text(x + 232, y, 48, 32, @actor.sp_cost(skill).to_s, 2)
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.skill == nil ? "" : self.skill.description)
  end
end
