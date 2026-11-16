##
# Zeriab's small script add-ons
# Extension to RPG::State
#
module RPG
  class State
    attr_sec_accessor :berserk, false
    attr_sec_accessor :slip, 0.10
  end
end