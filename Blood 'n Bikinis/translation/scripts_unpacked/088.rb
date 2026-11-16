#==============================================================================
# ** Scene_Load
#------------------------------------------------------------------------------
#  This class performs load screen processing.
#==============================================================================

class Scene_Load < Scene_File
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Remake temporary object
    $game_temp = Game_Temp.new
    # Timestamp selects new file
    $game_temp.last_file_index = 0
    latest_time = Time.at(0)
    for i in 0...System::SAVEFILE_AMOUNT
      filename = make_filename(i)
      if FileTest.exist?(filename)
        file = File.open(filename, "r")
        if file.mtime > latest_time
          latest_time = file.mtime
          $game_temp.last_file_index = i
        end
        file.close
      end
    end
   @scene = "Load"
  end
  #--------------------------------------------------------------------------
  # * Cancel Processing
  #--------------------------------------------------------------------------
  def on_cancel
    # Play cancel SE
    $game_system.se_play($data_system.cancel_se)
    # Switch to title screen
    $scene = Scene_Title.new
  end
  #--------------------------------------------------------------------------
  # * Read Save Data
  #     array : array containing the necessary objects
  #--------------------------------------------------------------------------
  def read_save_data(array)
    # Read character data for drawing save file
    characters = array.shift
    # Read frame count for measuring play time
    Graphics.frame_count = array.shift
    # Read each type of game object
    $game_system        = Marshal.load(array.shift)
    $game_switches      = Marshal.load(array.shift)
    $game_variables     = Marshal.load(array.shift)
    $game_self_switches = Marshal.load(array.shift)
    $game_screen        = Marshal.load(array.shift)
    $game_actors        = Marshal.load(array.shift)
    $game_party         = Marshal.load(array.shift)
    $game_troop         = Marshal.load(array.shift)
    $game_map           = Marshal.load(array.shift)
    $game_player        = Marshal.load(array.shift)
    $game_itembag       = Marshal.load(array.shift)
    # If magic number is different from when saving
    # (if editing was added with editor)
    if $game_system.magic_number != $data_system.magic_number
      # Load map
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # Refresh party members
    $game_party.refresh
  end
  #--------------------------------------------------------------------------
  # * Decision Processing
  #--------------------------------------------------------------------------
  def on_decision(filename)
    # If file doesn't exist
    unless FileTest.exist?(filename)
      return
    end
    begin
      # Read save file
      file = File.open(filename, "rb")
      # Read save information
      comp_info = Marshal.load(file)
      # Unpack save information
      save_info = Marshal.load(Zlib::Inflate.inflate(comp_info))
      # Ensure proper version (Safety)
      return unless check_game(save_info.game)
      # Read save data
      save_data = Marshal.load(file)
      file.close
      # Unpack and apply save data
      array = Marshal.load(Zlib::Inflate.inflate(save_data))
      read_save_data(array)
      # Restore BGM and BGS
      $game_system.bgm_play($game_system.playing_bgm)
      $game_system.bgs_play($game_system.playing_bgs)
      # Update map (run parallel process event)
      $game_map.update
      # Switch to map screen
      $scene = Scene_Map.new
      # Run common event
      Utility.run_common_event(Game_Actor::COMMON_EVENT_ON_LOAD)
    rescue Errno::EACCES
      Dialog_OK.show('Permission to load the save file was denied')
      raise if $DEBUG
    rescue StandardError => err
      if save_info.game.version > System::VERSION
        Dialog_OK.show(['An error occured while trying to load the save.',
                        "Please install a newer version of #{System::VISUAL_GAME_NAME}"])
      else
        Dialog_OK.show(['Save file is corrupt. You cannot use this save.', 
                       'There is unfortunately not much you can do about this'])
      end
      raise if $DEBUG
    end
  end
  ##
  # Check that the game info is proper
  #
  def check_game(game)
    return false unless game.game == System::GAME_NAME || game.game.to_s.downcase == "botm"
    if game.version > System::VERSION
      return Dialog_YesNo.show(false, 'This save was made with a later version of the game.',
                                      'Loading it may lead to unstable game play.',
                                      'Do you want to proceed?')
    end
    return true
  end
  #--------------------------------------------------------------------------
  # * Read Save Data
  #     array : array containing the necessary objects
  #--------------------------------------------------------------------------
  def read_save_data(array)
    # Read character data for drawing save file
    characters = array.shift
    # Read frame count for measuring play time
    Graphics.frame_count = array.shift
    # Read each type of game object
    $game_system        = array.shift
    $game_switches      = array.shift
    $game_variables     = array.shift
    $game_self_switches = array.shift
    $game_screen        = array.shift
    $game_actors        = array.shift
    $game_party         = array.shift
    $game_troop         = array.shift
    $game_map           = array.shift
    $game_player        = array.shift
    $game_itembag       = array.shift
    # If magic number is different from when saving
    # (if editing was added with editor)
    if $game_system.magic_number != $data_system.magic_number
      # Load map
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    # Refresh party members
    $game_party.refresh
                ## STEAM ACHIEVEMENTS ##
    steam_check_all_achievements
  end
end
