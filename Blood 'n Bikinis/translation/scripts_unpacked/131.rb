DEATH_START_ID = 2000

#==============================================================================
# Game_Actor
#==============================================================================

class Game_Actor
 
 def hp=(val)
   $game_variables[DEATH_START_ID + self.id - 1] += 1 if val <= 0 && @hp != val
   super(val)
 end
 
end