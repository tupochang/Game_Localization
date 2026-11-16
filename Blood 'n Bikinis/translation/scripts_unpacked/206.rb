##
# Zeriab's small script add-ons
# Extension to RPG::Weapon
#
module RPG
  class Weapon
    attr_sec_accessor :hp_plus, 0
    attr_sec_accessor :sp_plus, 0
    attr_sec_accessor :regen_hp_per_turn, 0
    attr_sec_accessor :regen_sp_per_turn, 0
    attr_sec_accessor :sp_multiplier, 1.0
    attr_sec_accessor :hit_multiplier, 1
    attr_sec_accessor :hit_multiplier_fixed, 1
    attr_sec_accessor :first_strike, false
    attr_sec_accessor :first_strike_on_attack, false
    attr_sec_accessor :counter, false
    attr_sec_accessor :counter_spell, false
    attr_sec_accessor :cursed, false
    attr_sec_accessor :auto_state_id, 0
    
    attr_sec_accessor :damage_range, 100..200
    attr_sec_accessor :damage_range_variable, 0
  end
end