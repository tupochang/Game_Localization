module WeaponSetup
  def self.run
    # For you to see the default values. You can change these now
    #$data_weapons[0].hp_plus = 0
    #$data_weapons[0].sp_plus = 0
    #$data_weapons[0].regen_hp_per_turn = 0
    #$data_weapons[0].regen_sp_per_turn = 0
    #$data_weapons[0].sp_multiplier = 1.0
    #$data_weapons[0].hit_multiplier = 1
    #$data_weapons[0].hit_multiplier_fixed = 1
    #$data_weapons[0].first_strike = true
    #$data_weapons[0].first_strike_on_attack = true
    #$data_weapons[0].counter = true
    #$data_weapons[0].counter_spell = true
    #$data_weapons[0].cursed = true
    #$data_weapons[0].auto_state_id = 0
    #$data_weapons[0].damage_range = 100..200
    #$data_weapons[0].damage_range_variable = 0  (0 = range disabled,
    #                                             1 = range enabled with no variable)
    
    # Let's have an example
    # Sets the weapon with id 003 in the database to have first strike
    # It is most important that you omit any 0s before the number.
    # Including them can give in many cases give errors
    
$data_weapons[16].first_strike_on_attack = true
$data_weapons[32].first_strike_on_attack = true
$data_weapons[41].first_strike_on_attack = true
$data_weapons[57].first_strike_on_attack = true
$data_weapons[65].hit_multiplier = 5
$data_weapons[67].hit_multiplier = 4

$data_weapons[106].hit_multiplier = 2
$data_weapons[107].hit_multiplier = 3
$data_weapons[108].hit_multiplier = 3
$data_weapons[109].hit_multiplier = 2
$data_weapons[109].regen_hp_per_turn = 116
    
    # Weapon 5 dealing 250-350 + whatever is in variable no. 4 in damage

$data_weapons[16].damage_range = 470..600
$data_weapons[16].damage_range_variable = 1101
$data_weapons[32].damage_range = 300..385
$data_weapons[32].damage_range_variable = 1102
$data_weapons[41].damage_range = 400..500
$data_weapons[41].damage_range_variable = 1105
$data_weapons[53].damage_range = 600..870
$data_weapons[53].damage_range_variable = 1107
$data_weapons[65].damage_range = 280..303
$data_weapons[65].damage_range_variable = 1109
$data_weapons[67].damage_range = 242..265
$data_weapons[67].damage_range_variable = 1111

  end
end