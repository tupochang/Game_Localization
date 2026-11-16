module OptionSetup
  def self.run

    play_music = !(Utility.read_ini('Play_Music') == '0')
    play_sound_effects = !(Utility.read_ini('Play_Sound_Effects') == '0')
    disable_mouse = !(Utility.read_ini('Disable Mouse') == '0')
    #fast_battles = !(Utility.read_ini('Brighten Dark Areas') == '0')
    #text_display = !(Utility.read_ini('Always Show What Items Do') == '0')
    
    Audio.toggle_off_music if play_music == false
    Audio.toggle_off_sound_effects if play_sound_effects == false
    
    return if $game_switches == nil
    
    for key, switch_id in System::Options::EXTRA
      case key
      when "Disable Mouse"
        $game_switches[switch_id] = disable_mouse
      #when "Brighten Dark Areas"
      #  $game_switches[switch_id] = fast_battles
      #when "Always Show What Items Do"
       # $game_switches[switch_id] = text_display
      end
      #p key, $game_switches[switch_id]
    end
 
  end
  
  def self.save(fullscreen=nil)
    play_music = Audio.music? ? '1' : '0'
    play_sound_effects = Audio.sound_effects? ? '1' : '0'
    
    for key, switch_id in System::Options::EXTRA
      case key
      when "Disable Mouse"
        disable_mouse = $game_switches[switch_id] ? '1' : '0'

      end
    end
  #p fullscreen
    Utility.write_ini('Fullscreen', fullscreen) if fullscreen != nil
    Utility.write_ini('Play_Music', play_music)
    Utility.write_ini('Play_Sound_Effects', play_sound_effects)
    Utility.write_ini('Disable Mouse', disable_mouse)

    
  end 
  

end