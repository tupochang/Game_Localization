#==============================================================================
# ** Game_Skills
#------------------------------------------------------------------------------
#  This class handles armors. It's a wrapper for the built-in class "Array."
#  Refer to "$game_system.skills" for the instance of this class.
#==============================================================================

class Game_Skills
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    if $data_skills.nil?
      @data = []
    else
      @data = Array.new($data_skills.size)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def [](skill_id)
    if @data[skill_id] != nil
      return @data[skill_id]
    else
      if $data_skills[skill_id] != nil
        @data[skill_id] = Game_Skill.new($data_skills[skill_id])
        return @data[skill_id]
      end
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Set Armor
  #     skill_id : skill ID
  #     skill    : a Game_Skill
  #--------------------------------------------------------------------------
  def []=(skill_id, skill)
    @data[skill_id] = skill
  end
end
