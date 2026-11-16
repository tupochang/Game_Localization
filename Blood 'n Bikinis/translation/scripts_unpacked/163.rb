module Graphics
  class << self
    #-------------------------------------------------------------------------
    # * Aliases Graphics.update
    #-------------------------------------------------------------------------
    unless self.method_defined?(:zeriab_time_update)
      alias_method(:zeriab_time_update, :update)
    end
    #-------------------------------------------------------------------------
    # Change the update method so F12 toggles pause
    #-------------------------------------------------------------------------
    def update(*args)
      zeriab_time_update(*args)
      playtime_tick
    end
    
    def playtime_tick
      @playtime = 0.0 if @playtime.nil?
      @playtime += 1.0 / frame_rate
    end
    
    def playtime
      @playtime
    end
    
    def playtime_reset
      @playtime = 0.0
    end
  end
end
