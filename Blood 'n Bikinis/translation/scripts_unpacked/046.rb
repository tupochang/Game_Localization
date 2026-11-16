#==============================================================================
# ** Window_SkillStatus
#------------------------------------------------------------------------------
#  This window displays the skill user's status on the skill screen.
#==============================================================================

class Window_SkillStatus < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 64, 640, 64)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    self.contents.font.size = 18
    draw_actor_name(@actor, 4, 0)
    draw_actor_state(@actor, 142, 0)
    draw_actor_hp(@actor, 400, 0)
    draw_actor_sp(@actor, 508, 0)
  end
end
