#==============================================================================
# ** Game_Quest
#------------------------------------------------------------------------------
#  Manages the process in the quests.
#==============================================================================

class Game_Quest
  attr_reader :completed
  attr_reader :active
  attr_reader :current_quest
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     quest : Must be a Data_Quest
  #--------------------------------------------------------------------------
  def initialize
    @data = []
    # Completed quest
    @completed_quest = []
    # A quest is not completed in the start
    @completed = false
    # Neither is it active
    @active = false
    # Updates
    update
  end # def
  
    #-------------------------------------------------------------------------- 
  # * Resets the quest 
  #-------------------------------------------------------------------------- 
  def reset 
        # Remove the current quest
    @current_quest = nil
    # A quest is not completed in the start 
    @completed = false 
    # Neither is it active 
    @active = false 
    # Updates 
    update 
  end # def 
  
  #--------------------------------------------------------------------------
  # * Updates the current_quest
  #--------------------------------------------------------------------------
  def update
    # Return if the quest have completed
    return if @completed
    #------------------------------------------------------------------------
    # Checks if the quest is completed. Assumes that @completed_quest only has 
    # 2 (or more) elements if the first element is a Data_Quest and the second
    # is a Quest_Criteria.
    #------------------------------------------------------------------------
    if (@completed_quest.size > 1) && @completed_quest[1].check
      @completed = true
      @current_quest = @completed_quest[0]
      # No need to update the quest further
      return
    end # if
    # Checks the status of the quest
    for i in 0...@data.size
      # Runs through the elements backwards.
      j = @data.size - (i + 1)
      # Checks if the conditions for the quest part are met
      if @data[j][1].check
        # Sets the current_quest to the quest which conditions are met
        @current_quest = @data[j][0]
        # Checks if the quest should be considered completed
        if i == 0 and @completed_quest.size <= 1
          @completed = true
          @completed_quest = @data[j]
        end # if
        break
      end # if
    end # for
    # Checks if the quest should be actived
    if !@active && @current_quest.is_a?(Data_Quest)
      @active = true  # Is actived
    end
  end # def
  
  #--------------------------------------------------------------------------
  # * Add a quest (quest part)
  #     quest : Must be a Data_Quest
  #--------------------------------------------------------------------------
  def add_quest(quest, condition)
    if quest.is_a?(Data_Quest) && condition.is_a?(Quest_Criteria)
      @data.push([quest,condition])
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Set the completed quest part
  #     quest : Must be a Data_Quest
  #--------------------------------------------------------------------------
  def set_completed_quest(quest, condition)
    if quest.is_a?(Data_Quest)
      @completed_quest = [quest, condition]
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Error handling
  #     string : A String containing the error message
  #--------------------------------------------------------------------------
  def error(err)
    # Only prints the error message if the game is played through the editor
    if $DEBUG
      print err
    end # if 
  end # def
end # class