##
# Zeriab's small script add-ons
# Extension to RPG::Actor
#
module RPG
  class Actor
    attr_sec_accessor :prevent_death_skill, false
    attr_sec_accessor :defense_divider, 3
    attr_sec_accessor :hit_multiplier, 1
    attr_sec_accessor :hit_multiplier_fixed, 1
    attr_sec_accessor :first_strike, false
    attr_sec_accessor :first_strike_on_attack, false
    attr_sec_accessor :counter, false
    attr_sec_accessor :counter_spell, false
  end
end