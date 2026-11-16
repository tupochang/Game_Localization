#==============================================================================
# ** Quest_Criteria
#------------------------------------------------------------------------------
#  This class simple gets a criteria and tells if it is fulfilled or not.
#  Used in Game_Quest to determine how much the quest has progressed
#
#  Variable condition:
#  ["variable", variable_number, condition, number]
#  -------------------
#  The "variable" just tells the script that you want to check a variable
#  The variable_number is the number on the variable you want to use.
#  Condition is which condition you want to check.
#    "<" - less than
#    "<=" - less than or equal   ("=<" will give you an error)
#    "==" - equal  ("=" is converted to "==")
#    ">=" - greater than or equal   ("=>" will give you an error)
#    ">" - greater than
#    "!=" - not equal
#  The number is the number you want to check with.
#  For example:
#  ["variable", 4, ">", 3] - Variable number 4 must be bigger than 3
#  ["variable", 2, "==", 5] - Variable number 2 must be equal 5
#
#
#  Switch Condition:
#  ["switch", switch_number, state]
#  -------------------------------------
#  The "switch" just tells the script that you want to check a switch
#  The switch_number is the number on the switch you want to use.
#  The state is what the state of the switch should be for the conditions to
#  be fulfilled. Write 'true' if the switch must be ON and 'false' if the
#  switch must be OFF
#
#  For example:
#  ["switch", 7, true] - Switch number 7 must be true
#  ["switch", 3, false] - Switch number 3 must be false
#
#
#  Use the 'check' method to see if all conditions are met. If they are then
#  'true' will be returned, otherwise 'false'
#==============================================================================

class Quest_Criteria
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(*args)
    # Each argument is considered as a condition and is stored in @conditions
    @conditions = args
  end # def
  
  #--------------------------------------------------------------------------
  # * Checks the conditions. Returns true if all the conditions are met
  #--------------------------------------------------------------------------
  def check
    # Goes through the conditions
    for condition in @conditions
      # Creates a begin-rescue block to catch errors.
      begin
        break   if !condition.is_a?(Array) && !condition[0].is_a?(String)
        case condition[0].downcase   # The first field in the array
        when "variable"
          # Converts '=' into '==' to avoid changing the variable
          condition[2] = "=="   if condition[2] == "="
          command = "$game_variables[#{condition[1]}] #{condition[2]} " + 
                    "#{condition[3]}"
          return false    unless eval(command)
        when "switch"
          return false    unless $game_switches[condition[1]] == condition[2]
        end
      rescue Exception => err
        # Prints an error message if and only if $DEBUG is true
        # The erroneous condition is considered to be "true"
        if $DEBUG
          output = "Quest_Criteria:Check\n\n"+ err.type.to_s + "\n" +
                   err.to_s + "\n\n" + "Backtrace(10):\n\n" +
                   err.backtrace[0...10].join("\n").to_s
          print output
        end
      end # begin
    end # for
    # Returns true if no condition is false.
    return true
  end # def
end # class