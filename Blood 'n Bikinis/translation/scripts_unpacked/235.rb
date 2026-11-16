module SkillSetup
  def self.run
    # How to change the various stats. Default are as stated in the database
    # 'id' is the number of the enemy in the database
    #$data_skills[id].name = "Finger of Death"
    #$data_skills[id].description = "The ultimate killing spell"
    #$data_skills[id].scope = 1 # (0: none, 1: one enemy, 2: all enemies, 3: one ally, 4: all allies, 5: 1 ally--HP 0, 6: all allies--HP 0, 7: the user)
    #$data_skills[id].occasion = 3 # when can you use it (0: always, 1: only in battle, 2: only from the menu, 3: never)
    #$data_skills[id].common_event_id = 0  # 0 = no common event (the id of the common event which will be called)
    #$data_skills[id].sp_cost = 50
    #$data_skills[id].power = 2000
    #$data_skills[id].atk_f = 2400
    #$data_skills[id].eva_f = 5000
    #$data_skills[id].str_f = 32000
    #$data_skills[id].dex_f = 17
    #$data_skills[id].agi_f = 4350
    #$data_skills[id].int_f = 1502
    #$data_skills[id].hit = 50
    #$data_skills[id].pdef_f = 300
    #$data_skills[id].mdef_f = 500
    #$data_skills[id].variance = 20
    
        $data_skills[16].first_strike = true
        $data_skills[52].first_strike = true
        $data_skills[54].first_strike = true
        $data_skills[87].first_strike = true
        $data_skills[104].first_strike = true
        $data_skills[114].first_strike = true
        $data_skills[116].first_strike = true
        $data_skills[118].first_strike = true
        $data_skills[146].first_strike = true
        $data_skills[171].first_strike = true
        $data_skills[173].first_strike = true
        $data_skills[223].first_strike = true
        $data_skills[232].first_strike = true
        $data_skills[319].first_strike = true
    
    # Let's have an example
    # Sets the skill with id 008 in the database to have a power of 2500
  end
end