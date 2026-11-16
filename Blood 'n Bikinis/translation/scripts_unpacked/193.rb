#==============================================================================
# ** Data_Quest
#------------------------------------------------------------------------------
#  A quest object.
#  Stores information about the particular quest.
#  All icons are assumed to be stored in the same directory
#==============================================================================

class Data_Quest
  # The path in the pictures folder
  PATH = "Quest/Icons/"
  # The name of the default icon
  DEFAULT_ICON = "default_icon.png"
  
  # The following are of the String class.
  attr_reader   :owner          # Who
  attr_reader   :location       # Where
  attr_reader   :goal           # What
  attr_reader   :info           # details

  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @owner = ""
    @location = ""
    @goal = ""
    @info = ""
    @icon = DEFAULT_ICON
  end # def
  
  #--------------------------------------------------------------------------
  # * Gets the name and location of the icon in the picture folder
  #--------------------------------------------------------------------------
  def get_icon
    return PATH + @icon
  end # def
  
  #--------------------------------------------------------------------------
  # * Set Owner
  #     string : A string containing the owner
  #--------------------------------------------------------------------------
  def owner=(string)
    if string.is_a?(String)
      @owner = string
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Set Location
  #     string : A string containing the location
  #--------------------------------------------------------------------------
  def location=(string)
    if string.is_a?(String)
      @location = string
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Set Goal
  #     string : A string containing the goal
  #--------------------------------------------------------------------------
  def goal=(string)
    if string.is_a?(String)
      @goal = string
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Set Info
  #     string : A string containing the information
  #--------------------------------------------------------------------------
  def info=(string)
    if string.is_a?(String)
      @info = string
    end # if
  end # def
  
  #--------------------------------------------------------------------------
  # * Set Info
  #     string : A string containing the filename of the icon
  #              No change is done if the file does not exists
  #--------------------------------------------------------------------------
  def icon=(string)
    if string.is_a?(String)
      @icon = string
    end # if
  end # def
end # class