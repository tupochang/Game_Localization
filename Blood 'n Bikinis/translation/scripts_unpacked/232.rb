module EnemySetup
  def self.run
    # How to change the various stats. Default are as stated in the database
    # 'id' is the number of the enemy in the database
    #$data_enemies[id].maxhp = 25000
    #$data_enemies[id].maxsp = 15000
    #$data_enemies[id].str = 5000
    #$data_enemies[id].dex = 6000
    #$data_enemies[id].agi = 1500
    #$data_enemies[id].int = 2500
    #$data_enemies[id].atk = 3000
    #$data_enemies[id].pdef = 12000
    #$data_enemies[id].mdef = 1000
    #$data_enemies[id].eva = 4250
    #$data_enemies[id].exp = 150000
    #$data_enemies[id].gold = 250000
    #$data_enemies[id].defense_divider = 3
    #$data_enemies[id].hit_multiplier = 1
    #$data_enemies[id].hit_multiplier_fixed = 1
    #$data_enemies[id].first_strike = false
    #$data_enemies[id].first_strike_on_attack = false
    #$data_enemies[id].counter = false
    #$data_enemies[id].counter_spell = false
    #$data_enemies[id].damage_range = 100..200
    #$data_enemies[id].damage_range_variable = 0  (0 = range disabled,
    #                                             -1 = range enabled with no variable)
    #$data_enemies[5].common_event_on_attack = 8
    # Enemy 5 dealing 250-350 + whatever is in variable no. 4 in damage
    #$data_enemies[5].damage_range = 250..350
    #$data_enemies[5].damage_range_variable = 4.
   

    # Let's have an example
    # Sets the strength of enemy with id 003 in the database to 15000
    # It is most important that you omit any 0s before the number.
    # Including them can in many cases give errors
    
    $data_enemies[12].hit_multiplier = 3
    $data_enemies[14].hit_multiplier_fixed = 2
    $data_enemies[15].hit_multiplier = 2
    $data_enemies[18].counter = true
    $data_enemies[20].counter_spell = true
    $data_enemies[21].counter = true
    $data_enemies[23].hit_multiplier = 3
    $data_enemies[23].first_strike_on_attack = true
    $data_enemies[30].hit_multiplier = 3
    $data_enemies[31].hit_multiplier = 4
    $data_enemies[38].counter = true
    $data_enemies[40].first_strike_on_attack = true
    $data_enemies[45].hit_multiplier = 3
    $data_enemies[51].hit_multiplier = 2
    $data_enemies[56].counter = true

    $data_enemies[7].damage_range = 70..74
    $data_enemies[7].damage_range_variable = -1

    $data_enemies[22].damage_range = 110..150
    $data_enemies[22].damage_range_variable = -1
    
    $data_enemies[29].damage_range = 110..150
    $data_enemies[29].damage_range_variable = -1
    
    $data_enemies[30].damage_range = 40..70
    $data_enemies[30].damage_range_variable = -1
    
    $data_enemies[45].damage_range = 65..80
    $data_enemies[45].damage_range_variable = -1
    
    $data_enemies[47].damage_range = 200..400
    $data_enemies[47].damage_range_variable = -1
    
    
    $data_enemies[1].common_event_on_attack = 189
    $data_enemies[2].common_event_on_attack = 189
    $data_enemies[3].common_event_on_attack = 189
    $data_enemies[4].common_event_on_attack = 189
    $data_enemies[5].common_event_on_attack = 189
    $data_enemies[6].common_event_on_attack = 189
    $data_enemies[7].common_event_on_attack = 189
    $data_enemies[8].common_event_on_attack = 189
    $data_enemies[9].common_event_on_attack = 189
    $data_enemies[10].common_event_on_attack = 189
    $data_enemies[11].common_event_on_attack = 189
    $data_enemies[12].common_event_on_attack = 189
    $data_enemies[13].common_event_on_attack = 189
    $data_enemies[14].common_event_on_attack = 189
    $data_enemies[15].common_event_on_attack = 189
    $data_enemies[16].common_event_on_attack = 189
    $data_enemies[17].common_event_on_attack = 189
    $data_enemies[18].common_event_on_attack = 189
    $data_enemies[19].common_event_on_attack = 189
    $data_enemies[20].common_event_on_attack = 189
    $data_enemies[21].common_event_on_attack = 189
    $data_enemies[22].common_event_on_attack = 189
    $data_enemies[23].common_event_on_attack = 189
    $data_enemies[24].common_event_on_attack = 189
    $data_enemies[25].common_event_on_attack = 189
    $data_enemies[26].common_event_on_attack = 189
    $data_enemies[27].common_event_on_attack = 189
    $data_enemies[28].common_event_on_attack = 189
    $data_enemies[29].common_event_on_attack = 189
    $data_enemies[30].common_event_on_attack = 189
    $data_enemies[31].common_event_on_attack = 189
    $data_enemies[32].common_event_on_attack = 189
    $data_enemies[33].common_event_on_attack = 189
    $data_enemies[34].common_event_on_attack = 189
    $data_enemies[35].common_event_on_attack = 189
    $data_enemies[36].common_event_on_attack = 189
    $data_enemies[37].common_event_on_attack = 189
    $data_enemies[38].common_event_on_attack = 189
    $data_enemies[39].common_event_on_attack = 189
    $data_enemies[40].common_event_on_attack = 189
    $data_enemies[41].common_event_on_attack = 189
    $data_enemies[42].common_event_on_attack = 189
    $data_enemies[43].common_event_on_attack = 189
    $data_enemies[44].common_event_on_attack = 189
    $data_enemies[45].common_event_on_attack = 189
    $data_enemies[46].common_event_on_attack = 189
    $data_enemies[47].common_event_on_attack = 189
    $data_enemies[48].common_event_on_attack = 189
    $data_enemies[49].common_event_on_attack = 189
    $data_enemies[50].common_event_on_attack = 189
    $data_enemies[51].common_event_on_attack = 189
    $data_enemies[52].common_event_on_attack = 189
    $data_enemies[53].common_event_on_attack = 189
    $data_enemies[54].common_event_on_attack = 189
    $data_enemies[55].common_event_on_attack = 189
    $data_enemies[56].common_event_on_attack = 189
    $data_enemies[57].common_event_on_attack = 189
    $data_enemies[58].common_event_on_attack = 189
    $data_enemies[59].common_event_on_attack = 189
    $data_enemies[60].common_event_on_attack = 189
    $data_enemies[61].common_event_on_attack = 189
    $data_enemies[62].common_event_on_attack = 189
    $data_enemies[63].common_event_on_attack = 189
    $data_enemies[64].common_event_on_attack = 189
    $data_enemies[65].common_event_on_attack = 189
    $data_enemies[66].common_event_on_attack = 189
    $data_enemies[67].common_event_on_attack = 189
    $data_enemies[68].common_event_on_attack = 189
    $data_enemies[69].common_event_on_attack = 189    
    $data_enemies[70].common_event_on_attack = 189
     
    $data_enemies[40].hit_weapon_id = 99
    $data_enemies[41].hit_weapon_id = 100
    $data_enemies[42].hit_weapon_id = 101
    $data_enemies[46].hit_weapon_id = 102
    $data_enemies[47].hit_weapon_id = 103
    $data_enemies[56].hit_weapon_id = 105
    $data_enemies[57].hit_weapon_id = 108
    $data_enemies[58].hit_weapon_id = 106
    $data_enemies[59].hit_weapon_id = 107
    $data_enemies[62].hit_weapon_id = 110
    $data_enemies[66].hit_weapon_id = 109

  end
end