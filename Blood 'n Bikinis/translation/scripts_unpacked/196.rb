#==============================================================================
# ** Game_Quests
#------------------------------------------------------------------------------
#  This class handles quests. It's a wrapper for the built-in class "Array."
#  Refer to "$game_quests" for the instance of this class.
#  
#  The quest potion 0 is considered to be the main quest. ($game_quests[0])
#==============================================================================

class Game_Quests
  # Adds a method to read the data
  attr_reader     :data
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @data = []
    @main_quest = Game_Quest.new
  end # def
  #--------------------------------------------------------------------------
  # * Get Quest
  #     quest_id : quest ID
  #--------------------------------------------------------------------------
  def [](quest_id)
    return @data[quest_id]
  end # def
  #--------------------------------------------------------------------------
  # * Set Quest
  #     quest_id : quest ID
  #     quest    : the quest
  #--------------------------------------------------------------------------
  def []=(quest_id, quest)
    if quest.is_a?(Game_Quest) && quest_id % @data.size == 0
      @data[quest_id] = quest
    end  # if
  end # def
  #--------------------------------------------------------------------------
  # * Add Quest
  #     quest : the quest
  #--------------------------------------------------------------------------
  def add(quest)
    if quest.is_a?(Game_Quest)
      @data.push(quest)
    end # if
  end # def
    #-------------------------------------------------------------------------- 
  # * Resets the quests 
  #-------------------------------------------------------------------------- 
  def reset 
    for quest in @data 
      quest.reset 
    end # if 
  end # def 
  #--------------------------------------------------------------------------
  # * Gets active quests. Newest will be listed first
  #   Note: The main quest if active will always have position 0. (result[0])
  #--------------------------------------------------------------------------
  def get_active_quests
    result = []
    # Goes through the quests
    for i in 1...@data.size
      element = @data[i]
      # Updates the element
      element.update
      # Checks if element is active and not completed
      if element.active && !element.completed
        # Pushes the active element into the results
        result.push(element)
      end # if
    end # for
    # Checks if the main quest is active and not completed (index 0 in @data)
    @data[0].update
    if @data[0].active && !@data[0].completed
      result.push(@data[0])
    end # if
    # Reverse result so the main quest have index 0 followed by the newest
    # quest at index 1, the second newest at index 2 and so on.
    result.reverse!
    # Returns the resulting array
    return result
  end # def
  #--------------------------------------------------------------------------
  # * Gets completed quests. Newest will be listed first
  #   Note: The main quest will always be on position 0. (result[0])
  #--------------------------------------------------------------------------
  def get_completed_quests
    result = []
    # Goes through the quests
    for i in 1...@data.size
      element = @data[i]
      # Updates the element
      element.update
      # Checks if element is completed.
      if element.completed
        # Pushes the active element into the results
        result.push(element)
      end # if
    end # for
    # Checks if the main quest is active and not completed (index 0 in @data)
    if @data[0].completed
      result.push(@data[0])
    end # if
    # Reverse result so the main quest have index 0 followed by the newest
    # quest at index 1, the second newest at index 2 and so on.
    result.reverse!
    # Returns the resulting array
    return result
  end # def
end # class

# The global variable used for storing quests
$game_quests = Game_Quests.new