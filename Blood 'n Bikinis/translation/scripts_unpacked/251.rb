module Achievements
  STEAM_CALLBACK_POLLING_WAIT = 20
  STEAM_ACHIEVEMENTS_POLLING_WAIT = 60
  STEAM_ACHIEVEMENTS_VERSION = '1.0'
  STEAM_TEMP_FILENAME = 'Steamdata.tmp'
  
  SteamAchievementSaveData = Struct.new(:data, :version)
  
  module_function
  def update
    # Steam callback polling
    if !@callback_received
      @steam_callback_wait ||= STEAM_CALLBACK_POLLING_WAIT
      @steam_callback_wait -= 1
      if @steam_callback_wait <= 0
        @steam_callback_wait = STEAM_CALLBACK_POLLING_WAIT
        Achievements.callback_received
      end
    else
      if !@callback_processed
        @callback_processed = true
        Achievements.process_first_callback
      elsif pending_achievements?
        # Try to push achievements data
        @steam_achievement_wait ||= STEAM_ACHIEVEMENTS_POLLING_WAIT
        @steam_achievement_wait -= 1
        if @steam_achievement_wait <= 0
          @steam_achievement_wait = STEAM_ACHIEVEMENTS_POLLING_WAIT
          Achievements.push_achievements
        end
      end
    end
  end

  ##
  # Process currently unlocked achievements
  #
  def process_first_callback
    @done_achievements ||= {}
    for achievement_symbol in SymbolToAPIName.keys
      if Achievements.unlocked?(achievement_symbol)
        @done_achievements[achievement_symbol] = true
      end
    end
  end
  
  def pending_achievements?
    return !@pending_achievements.nil? && !@pending_achievements.empty?
  end
  
  def push_achievements
    remove_list = []
    for achievement_symbol in @pending_achievements
      if Achievements.unlocked?(achievement_symbol)
        # Success -> No further unlock attempts needed
        remove_list << achievement_symbol
        @done_achievements[achievement_symbol] = true
      else
        # Try to unlock
        Achievements.steamapi_unlock(achievement_symbol)
      end
    end
    # Remove all good achievements
    @pending_achievements -= remove_list unless remove_list.empty?
  end
  
  def unlock(achievement_symbol)
    # Do not try to unlock the achievements we already know is unlocked
    if @done_achievements[achievement_symbol] != true
      unless @pending_achievements.include?(achievement_symbol)
        @pending_achievements << achievement_symbol 
      end
      push_achievements
    end
    true
  end
  
  def init_achievement_data
    # Init pending achievements
    @pending_achievements ||= []
    @done_achievements = {}
    filename = temp_data_filename
    if FileTest.exist?(filename)
      begin
        save_data = nil
        File.open(filename, "rb") do |file|
          save_data = Marshal.load(file)
        end
        compressed_data = save_data.data
        raw_data = Zlib::Inflate.inflate(compressed_data)
        @pending_achievements = Marshal.load(raw_data)
      rescue
        # Ignore the file - At worst some achievements will not be triggered
        if $DEBUG
          p "Non-critical error: Unable to load #{filename}"
        end
      end
    end
    # Force the callback to start (So we reduce the waiting time later)
    Achievements.unlocked?(SymbolToAPIName.keys[0])
  end
  
  def save_achievement_data
    if !@pending_achievements.nil?
      # Make the save data
      raw_data = Marshal.dump(@pending_achievements)
      # Compress save data
      compressed_data = Zlib::Deflate.deflate(raw_data)
      save_data = SteamAchievementSaveData.new(compressed_data, STEAM_ACHIEVEMENTS_VERSION)
      filename = temp_data_filename
      File.open(filename, "wb") {|file|
        Marshal.dump(save_data, file)
      }
    end
  end
  
  def temp_data_filename
    STEAM_TEMP_FILENAME
  end
end


##
# Hook into Graphics.update method
#
module Graphics
  class << self
    unless self.method_defined?(:zeriab_achievement_update)
      alias_method(:zeriab_achievement_update, :update)
    end
    ##
    # Poll 
    #
    def update(*args)
      Achievements.update
      zeriab_achievement_update(*args)
      ## STEAM ACHIEVEMENTS ##
      if !@playtime_first_hour
        if ach_playtime(:first_hour, 1)
          @playtime_first_hour = true
        end
      end
      if !@playtime_long_playing
        if ach_playtime(:long_playing, 10)
          @playtime_long_playing = true
        end
      end
    end
    def ach_playtime(symbol, hours)
      if $game_map && 
         frame_count % 120 == 0 &&
         frame_count / frame_rate >= 3600 * hours
        Achievements.unlock(symbol)
        return true
      end
      return false
    end
  end
end