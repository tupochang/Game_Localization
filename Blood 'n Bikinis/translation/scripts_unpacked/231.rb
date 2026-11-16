module ArmorSetup
  def self.run
    # For you to see the default values. You can change these now
    #$data_armors[0].hp_plus = 0
    #$data_armors[0].sp_plus = 0
    #$data_armors[0].regen_hp_per_turn = 0
    #$data_armors[0].regen_sp_per_turn = 0
    #$data_armors[0].sp_multiplier = 1.0
    #$data_armors[0].hit_multiplier = 1
    #$data_armors[0].hit_multiplier_fixed = 1
    #$data_armors[0].first_strike = false
    #$data_armors[0].first_strike_on_attack = false
    #$data_armors[0].counter = false
    #$data_armors[0].counter_spell = false
    #$data_armors[0].cursed = false

   
    # Let's have an example
    # Sets the armor with id 003 in the database to give first strike
    # It is most important that you omit any 0s before the number.
    # Including them can give in many cases give errors
    
    $data_armors[43].cursed = true
    $data_armors[64].cursed = true
    $data_armors[76].first_strike = true
    $data_armors[81].counter = true
    $data_armors[81].hit_multiplier = 2
    $data_armors[90].hit_multiplier_fixed = 2
    $data_armors[90].counter = true
    $data_armors[175].first_strike_on_attack = true
    $data_armors[181].regen_hp_per_turn = 6
    



  end
end