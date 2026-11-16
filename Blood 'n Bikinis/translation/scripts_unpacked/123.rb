##
# Save_Info is a header of a save file describing properties of the save and
# contains the data necessary for presentation in the save/load menu.
# The idea is to load as little as possible of the save file for presentation.
# The header should therefore be as little as possible.
#
class Save_Info
  # Info about the game which created the save
  attr_accessor :game
  class Game
    attr_accessor :game         # Shows which game it is
    attr_accessor :version      # The version of the game used to save the file
    attr_accessor :magic_number # Magic number of the save
    attr_accessor :misc         # Miscellaneous data
  end
  
  # A summary of the save for presentation in the save menu
  attr_accessor :summary
  class Summary
    attr_accessor :playing_time # Playing time
    attr_accessor :characters   # Characters in party
    attr_accessor :switches     # Game switches
    attr_accessor :variables    # Game variables
    attr_accessor :misc         # Miscellaneous data
  end
  
  # A miscellaneous accessor, just in case
  attr_accessor :misc
end