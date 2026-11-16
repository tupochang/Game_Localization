#==============================================================================
# ** Game_Armors
#------------------------------------------------------------------------------
#  This class handles armors. It's a wrapper for the built-in class "Array."
#  Refer to "$game_system.armors" for the instance of this class.
#==============================================================================

class Game_Armors
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    if $data_armors.nil?
      @data = []
    else
      @data = Array.new($data_armors.size)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Armor
  #     armor_id : armor ID
  #--------------------------------------------------------------------------
  def [](armor_id)
    if @data[armor_id] != nil
      return @data[armor_id]
    else
      if $data_armors[armor_id] != nil
        @data[armor_id] = Game_Armor.new($data_armors[armor_id])
        return @data[armor_id]
      end
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Set Armor
  #     armor_id : armor ID
  #     armor    : a Game_Armor
  #--------------------------------------------------------------------------
  def []=(armor_id, armor)
    @data[armor_id] = armor
  end
end
