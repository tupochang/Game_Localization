#==============================================================================
# ** Game_Weapons
#------------------------------------------------------------------------------
#  This class handles weapons. It's a wrapper for the built-in class "Array."
#  Refer to "$game_system.weapons" for the instance of this class.
#==============================================================================

class Game_Weapons
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    if $data_weapons.nil?
      @data = []
    else
      @data = Array.new($data_weapons.size) # Size is known
    end
  end
  #--------------------------------------------------------------------------
  # * Get Weapon
  #     weapon_id : weapon ID
  #--------------------------------------------------------------------------
  def [](weapon_id)
    if @data[weapon_id] != nil
      return @data[weapon_id]
    else
      if $data_weapons[weapon_id] != nil
        @data[weapon_id] = Game_Weapon.new($data_weapons[weapon_id])
        return @data[weapon_id]
      end
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Set Weapon
  #     weapon_id : weapons ID
  #     weapon    : a Game_Weapon
  #--------------------------------------------------------------------------
  def []=(weapon_id, weapon)
    @data[weapon_id] = weapon
  end
end
