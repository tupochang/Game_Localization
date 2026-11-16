#==============================================================================
# ** Scene_Save
#------------------------------------------------------------------------------
#  This class performs save screen processing.
#==============================================================================

class Scene_Save < Scene_File
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    @scene = "Save"
    # Check for autosave slot index
    if $game_temp.last_file_index <= 0
      # Start in slot 2 instead (The first that can be saved to)
      $game_temp.last_file_index = 1
    end
  end
  #--------------------------------------------------------------------------
  # * Decision Processing
  #--------------------------------------------------------------------------
  def on_decision(filename)
    if @file_index == 0
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play save SE
    $game_system.se_play($data_system.save_se)
    # Save to that filename
    save(filename)
    # If called from event
    if $game_temp.save_calling
      # Clear save call flag
      $game_temp.save_calling = false
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    # Switch to menu screen
    $scene = Scene_Menu.new(6)
  end
  # Save
  def save(filename)
    # Make the save data
    raw_data = Marshal.dump(make_save_data)
    # Make save information
    raw_info = Marshal.dump(make_save_info)
    # Compress save data and info
    save_info = Zlib::Deflate.deflate(raw_info)
    save_data = Zlib::Deflate.deflate(raw_data)
    # Write save data
    begin
      File.open(filename, "wb") {|file|
      Marshal.dump(save_info, file)
      Marshal.dump(save_data, file)}
    rescue Errno::EACCES
      Dialog_OK.show(['Permission to write to the save file was denied.',
                     'Please check the permission on the save file folder and on any save files you have.',
                     'Running the game in protected mode can mean that you cannot overwrite old saves.'])
      raise if $DEBUG
      return
    rescue Errno::ENOSPC
      Dialog_OK.show('There is not enough free space left to save the file.')
      raise if $DEBUG
      return
    rescue StandardError => err
      Dialog_OK.show(['An unidenfied error occurred while saving the file.',
                     'Try saving again in the same slot or another.'])
      raise if $DEBUG
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Cancel Processing
  #--------------------------------------------------------------------------
  def on_cancel
    # Play cancel SE
    $game_system.se_play($data_system.cancel_se)
    # If called from event
    if $game_temp.save_calling
      # Clear save call flag
      $game_temp.save_calling = false
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    # Switch to menu screen
    $scene = Scene_Menu.new(6)
  end
  ##
  # Make save information
  #
  def make_save_info
    # Game info
    game = Save_Info::Game.new
    game.game = System::GAME_NAME
    game.version = System::VERSION
    game.magic_number = $data_system.magic_number
    # Save summary
    summary = Save_Info::Summary.new
    summary.playing_time = Graphics.frame_count
    summary.characters = @characters
    summary.switches = $game_switches
    summary.variables = $game_variables
    # Info element
    info = Save_Info.new
    info.game = game
    info.summary = summary
    return info
  end
  #--------------------------------------------------------------------------
  # * Make Save Data
  #--------------------------------------------------------------------------
  def make_save_data
    # The array containing the information
    array = []
    # Make character data for drawing save file
    @characters = []
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      @characters.push([actor.character_name, actor.character_hue])
    end
    # Write character data for drawing save file
    array << @characters
    # Wrire frame count for measuring play time
    array << Graphics.frame_count
    # Increase save count by 1
    $game_system.save_count += 1
    # Save magic number
    # (A random value will be written each time saving with editor)
    $game_system.magic_number = $data_system.magic_number
    # Write each type of game object
    array << $game_system
    array << $game_switches
    array << $game_variables
    array << $game_self_switches
    array << $game_screen
    array << $game_actors
    array << $game_party
    array << $game_troop
    array << $game_map
    array << $game_player
    array << $game_itembag
    return array
  end
end
