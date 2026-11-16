module Audio
  @@play_music = true
  @@play_sound_effects = true
  
  class << self
    def music?
      @@play_music == true
    end
    
    def sound_effects?
      @@play_sound_effects == true
    end
    
    def toggle_music
      @@play_music = !@@play_music
      if @@play_music
        start_music
      else
        Audio.bgm_stop(false)
        Audio.me_stop
      end
    end
    
    def toggle_sound_effects
      @@play_sound_effects = !@@play_sound_effects
      if @@play_sound_effects
        start_bgs
      else
        Audio.bgs_stop(false)
        Audio.se_stop
      end
    end
    
    # __King__ 2011/04/28
    def toggle_off_music
      @@play_music = false
    end
    
    def toggle_off_sound_effects
       @@play_sound_effects = false
    end
    # __King__ end
    
    def start_music
      unless @@last_played_bgm.nil?
        Audio.bgm_play(*@@last_played_bgm)
      end
    end
    def start_bgs
      unless @@last_played_bgs.nil?
        Audio.bgs_play(*@@last_played_bgs)
      end
    end
    
    alias_method :zeriab_play_bgm_play, :bgm_play
    alias_method :zeriab_play_bgm_stop, :bgm_stop
    alias_method :zeriab_play_bgm_fade, :bgm_fade
    alias_method :zeriab_play_me_play, :me_play
    def bgm_play(*args)
      @@last_played_bgm = args
      zeriab_play_bgm_play(*args) if music?
    end
    def bgm_stop(destroy = true)
      @@last_played_bgm = nil if destroy
      zeriab_play_bgm_stop()
    end
    def bgm_fade(*args)
      @@last_played_bgm = nil
      zeriab_play_bgm_fade(*args)
    end
    
    def me_play(*args)
      zeriab_play_me_play(*args) if music?
    end
    
    alias_method :zeriab_play_bgs_play, :bgs_play
    alias_method :zeriab_play_bgs_stop, :bgs_stop
    alias_method :zeriab_play_bgs_fade, :bgs_fade
    alias_method :zeriab_play_se_play, :se_play
    def bgs_play(*args)
      @@last_played_bgs = args
      zeriab_play_bgs_play(*args) if sound_effects?
    end
    def bgs_stop(destroy = true)
      @@last_played_bgs = nil if destroy
      zeriab_play_bgs_stop()
    end
    def bgs_fade(*args)
      @@last_played_bgs = nil
      zeriab_play_bgs_fade(*args)
    end
    def se_play(*args)
      zeriab_play_se_play(*args) if sound_effects?
    end
  end
end