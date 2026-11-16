class Game_Weapon
  ATTRIBUTES = ['price',
                'atk', 
                'pdef', 
                'mdef', 
                'str_plus', 
                'dex_plus',
                'agi_plus', 
                'int_plus', 
                'element_set', 
                'plus_state_set',
                'minus_state_set', 
                'id', 
                'name', 
                'icon_name', 
                'counter_spell', 
                'description', 
                'animation1_id', 
                'animation2_id',
                'regen_hp_per_turn', 
                'regen_sp_per_turn', 
                'sp_multiplier',
                'hit_multiplier', 
                'first_strike', 
                'first_strike_on_attack',
                'counter', 
                'cursed', 
                'damage_range', 
                'damage_range_variable',
                'auto_state_id', 
                'hit_multiplier_fixed', 
                'hp_plus', 
                'sp_plus']
  
  for attribute in ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    attr_writer :#{attribute}
    def #{attribute}
      if @#{attribute}.nil?
        return @data.#{attribute}
      else
        return @#{attribute}
      end
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(data_weapon)
    @data = data_weapon
  end
  
end


class RPG::Weapon
  for attribute in Game_Weapon::ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    def #{attribute}=(val)
      index = $data_weapons.index(self)
      $game_system.weapons[index].#{attribute} = val
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
end