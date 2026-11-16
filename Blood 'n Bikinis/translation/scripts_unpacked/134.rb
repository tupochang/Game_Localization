#==============================================================================
# Variable Debug Window by Zeriab
# Version: 1.0
#
# Special thanks to Blizzard for his Location names with a window script
#==============================================================================

#==============================================================================
# Window_VariableDebug
#==============================================================================
DEBUG_VARIABLE_NUMBER = 1   # The number of the variable to show
SHOW_VARIABLE_DEBUG = false#$DEBUG  # Change to false to hide

if SHOW_VARIABLE_DEBUG
  class Window_VariableDebug < Window_Base
    
    def initialize
      super(0, 0, 128, 64)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = "Rough Draft"
      self.back_opacity = 128
      self.x = 640 - self.width
      refresh
    end
    
    def refresh
      @var = $game_variables[DEBUG_VARIABLE_NUMBER]
      self.contents.clear
      self.contents.draw_text(0, 0, 128, 32, "#{@var}")
    end
    
    def update
      if $game_variables[DEBUG_VARIABLE_NUMBER] != @var
        refresh
      end
    end
  end
  
  #==============================================================================
  # Spriteset_Map
  #==============================================================================
  
  class Spriteset_Map
  
    alias init_vardebug_later initialize
    def initialize
      init_vardebug_later
      @vardebug = Window_VariableDebug.new
    end
   
    alias upd_vardebug_later update
    def update
      if @vardebug != nil
        unless @vardebug.disposed?
          @vardebug.update
        else
          @vardebug = nil
        end
      end
      upd_vardebug_later
    end
   
    alias dispose_vardebug_later dispose
    def dispose
      dispose_vardebug_later
      unless @vardebug == nil
        @vardebug.dispose
      end
      @vardebug = nil
    end
    
  end
end