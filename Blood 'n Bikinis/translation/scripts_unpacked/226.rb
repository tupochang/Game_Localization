module System
  ##
  # Options settings
  #
  module Options
    # Options menu width. Change to fit with different text lengths
    WIDTH = 386
    
    # Color for current settings
    CURRENT_COLOR = Color.new(128, 255, 128, 255)
    OTHER_COLOR = Color.new(128, 128, 128, 128)
    
    # The text of the 3 standard
    TEXT_FULLSCREEN = 'FULL SCREEN'
    TEXT_PLAY_BGM = 'MUSIC ON'
    TEXT_PLAY_SE = 'SFX ON'
    
    # Extra options, [text, switch_id]
    EXTRA = [["MOUSE ON", 39], ["MESSAGES ON", 46], ["GORE ON", 74]]
  end
end