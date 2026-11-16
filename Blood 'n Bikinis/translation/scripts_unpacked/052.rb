#==============================================================================
# ** Window_SaveFile
#------------------------------------------------------------------------------
#  This window displays save files on the save and load screens.
#==============================================================================

class Window_SaveFile < Window_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :selected                 # selected
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     file_index : save file index (0-3)
  #     offset     : displacement of the window compared to the file_index
  #--------------------------------------------------------------------------
  def initialize(file_index, offset = 0)
    super(0, 64 + ((file_index + offset) % 4) * 104, 640, 104)
    self.contents = Bitmap.new(width - 32, height - 32)
    update_status(file_index, offset)
    refresh
    @selected = false
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def update_status(file_index, offset)
    self.y = 64 + ((file_index + offset) % 4) * 104
    @file_index = file_index
    @filename = $appPath + "/" + "Save#{@file_index + 1}.rxdata"
    @time_stamp = Time.at(0)
    begin
      @file_exist = FileTest.exist?(@filename)
      if @file_exist
        file = File.open(@filename, "r")
        @time_stamp = file.mtime
        comp_info = Marshal.load(file)
        file.close
        save_info = Marshal.load(Zlib::Inflate.inflate(comp_info))
        unless check_game(save_info.game) 
          @file_exist = false
          return
        end
        @characters = save_info.summary.characters
        @frame_count = save_info.summary.playing_time
        @total_sec = @frame_count / Graphics.frame_rate
      end
    rescue
      @file_exist = false
    end
  end
  ##
  # Check that the game info is proper
  #
  def check_game(game)
    return game.game == System::GAME_NAME || game.game.to_s.downcase == "botm"
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    self.contents.font.size = 27
    # Draw file number
    self.contents.font.color = normal_color
    if @file_index > 0
      name = "File#{@file_index + 1}"
    else
      name = "Autosave"
    end
    self.contents.draw_text(4, 0, 600, 32, name)
    @name_width = contents.text_size(name).width
    # If save file exists
    if @file_exist
      begin
        # Draw character
        for i in 0...@characters.size
          bitmap = RPG::Cache.character(@characters[i][0], @characters[i][1])
          cw = bitmap.rect.width / 4
          ch = bitmap.rect.height / 4
          src_rect = Rect.new(0, 0, cw, ch)
          x = 300 - @characters.size * 32 + i * 64 - cw / 2
          self.contents.blt(x, 68 - ch, bitmap, src_rect)
        end
        # Draw play time
        hour = @total_sec / 60 / 60
        min = @total_sec / 60 % 60
        sec = @total_sec % 60
        time_string = sprintf("%02d:%02d:%02d", hour, min, sec)
        self.contents.font.color = normal_color
        self.contents.draw_text(4, 8, 600, 32, time_string, 2)
        # Draw timestamp
        self.contents.font.color = normal_color
        time_string = @time_stamp.strftime("%Y/%m/%d %H:%M")
        self.contents.draw_text(4, 40, 600, 32, time_string, 2)
      rescue
        # Ignore the save if something went wrong while drawing the chars
        @file_exist = false
      end
    end
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Set Selected
  #     selected : new selected (true = selected, false = unselected)
  #--------------------------------------------------------------------------
  def selected=(selected)
    @selected = selected
    update_cursor_rect
  end
  #--------------------------------------------------------------------------
  # * Cursor Rectangle Update
  #--------------------------------------------------------------------------
  def update_cursor_rect
    if @selected
      self.cursor_rect.set(0, 0, @name_width + 8, 32)
    else
      self.cursor_rect.empty
    end
  end
end
