class Game_Armor
  ATTRIBUTES = ['id', 
                'name', 
                'icon_name', 
                'description', 
                'kind',
                'auto_state_id', 
                'price', 
                'pdef', 
                'mdef', 
                'eva', 
                'str_plus',
                'dex_plus', 
                'agi_plus', 
                'int_plus', 
                'guard_element_set',
                'guard_state_set', 
                'regen_hp_per_turn', 
                'regen_sp_per_turn',
                'sp_multiplier', 
                'first_strike', 
                'counter', 
                'counter_spell',
                'cursed', 
                'hit_multiplier', 
                'hit_multiplier_fixed', 
                'hp_plus',
                'sp_plus', 
                'first_strike_on_attack']

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
  def initialize(data_armor)
    @data = data_armor
  end
  
end

class RPG::Armor
  for attribute in Game_Armor::ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    def #{attribute}=(val)
      index = $data_armors.index(self)
      $game_system.armors[index].#{attribute} = val
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
end