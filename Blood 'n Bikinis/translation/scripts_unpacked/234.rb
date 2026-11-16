module ActorSetup
  def self.run
    # For you to see the default values. You can change these 
    #$data_actors[0].prevent_death_skill = false
    #$data_actors[0].defense_divider = 3
    #$data_actors[id].hit_multiplier = 1
    #$data_actors[id].hit_multiplier_fixed = 1
    #$data_actors[id].first_strike = false
    #$data_actors[id].first_strike_on_attack = false
    #$data_actors[id].counter = false
    #$data_actors[id].counter_spell = false
    #$data_actors[1].common_event_on_attack = 8
    
    # Let's have an example
    # Sets the actor with id 012 in the database to prevent death skills.

$data_actors[1].defense_divider = 3
$data_actors[2].defense_divider = 3
$data_actors[3].defense_divider = 3
$data_actors[4].defense_divider = 5
$data_actors[5].defense_divider = 4
$data_actors[6].defense_divider = 3
$data_actors[7].defense_divider = 3
$data_actors[8].defense_divider = 6
$data_actors[9].defense_divider = 4

$data_actors[1].common_event_on_attack = 217
$data_actors[2].common_event_on_attack = 218
$data_actors[3].common_event_on_attack = 221
$data_actors[4].common_event_on_attack = 220
$data_actors[5].common_event_on_attack = 219
$data_actors[6].common_event_on_attack = 224
$data_actors[7].common_event_on_attack = 222
$data_actors[8].common_event_on_attack = 223
$data_actors[9].common_event_on_attack = 225


    
  end
end