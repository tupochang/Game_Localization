##
# Zeriab's small script add-ons
# Extension to RPG::Enemy
#
module RPG
  class Enemy
    attr_sec_accessor :defense_divider, 3
    attr_sec_accessor :hit_multiplier, 1
    attr_sec_accessor :hit_multiplier_fixed, 1
    attr_sec_accessor :first_strike, false
    attr_sec_accessor :first_strike_on_attack, false
    attr_sec_accessor :counter, false
    attr_sec_accessor :counter_spell, false
    
    # <Z>                                                          # 2016-04-11
    attr_sec_accessor :hit_weapon_id, 0
    # </Z>
    
    attr_sec_accessor :damage_range, 100..200
    attr_sec_accessor :damage_range_variable, 0
  end
end