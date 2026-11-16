##
# Encapsulates the achievements and the communication with Steam
#
module Achievements  
  ##
  # This maps easily used symbols to the steam api name for the achievements
  # 
  SymbolToAPIName = {}
  SymbolToAPIName[:FW1] = 'FW1' #
  SymbolToAPIName[:FW2] = 'FW2' #
  SymbolToAPIName[:FW3] = 'FW3' #
  SymbolToAPIName[:FW4] = 'FW4' #
  SymbolToAPIName[:FW5] = 'FW5' #
  SymbolToAPIName[:FW6] = 'FW6' #
  SymbolToAPIName[:Laura] = 'Laura' #
  SymbolToAPIName[:Sandy] = 'Sandy' #
  SymbolToAPIName[:Cindy] = 'Cindy' #
  SymbolToAPIName[:Nancy] = 'Nancy' #
  SymbolToAPIName[:Isa] = 'Isa' #
  SymbolToAPIName[:Karine] = 'Karine' #
  SymbolToAPIName[:Alison] = 'Alison' #
  SymbolToAPIName[:Orange] = 'Orange' #
  SymbolToAPIName[:KM1] = 'KM1' #
  SymbolToAPIName[:KM2] = 'KM2' #
  SymbolToAPIName[:KC] = 'KC' #
  SymbolToAPIName[:KA] = 'KA' #
  SymbolToAPIName[:IL] = 'IL' #
  SymbolToAPIName[:CS] = 'CS' #


  
  
  SwitchToSymbol = {}

  # SwitchToSymbol[104] = :A4

end

Achievements.init_achievement_data
