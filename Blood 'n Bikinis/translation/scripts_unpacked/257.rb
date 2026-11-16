#==============================================================================
# ** Main
#------------------------------------------------------------------------------
#  After defining each class, actual processing begins here.
#==============================================================================

##
# Prints out an error message in a fashion that is relatively human readable
#
def printErrorMessage(err)
  print "              Crash detected, attempting to recover\n" +
        "If this error continuous to occur press " +
        "and hold F8 to exit\n" + 
        "-"*69 + "\n" +
        err.class.to_s + ": " + err.message + "\n\n" + 
        err.backtrace.join("\n")
end
    
begin
  # Start up modules relying on the settings
  Mouse.start_up

  #----------------------------------------------------------------------    
  # Set Up System Variables
  #----------------------------------------------------------------------  
  encrypt = 0      # 0=off, 1=on 
  debug = 1        # 0=off, 1=on  
  fullscreen = !(Utility.read_ini('fullscreen') == '0')   # 0=off, 1=on
  
  utils_file = System::DLL_FILE
  
  #----------------------------------------------------------------------    
  # Set Up Save Games System
  #----------------------------------------------------------------------
  
  # Full screen binding
  IS_FULL_SCREEN   = Win32API.new(System::DLL_FILE, "IsFullScreen", ["V"], "I")

  # Make sure all important folders & files exist
  raise "#{utils_file}.dll not found. Please reinstall #{System::GAME_NAME}" if !File.exists?(utils_file + '.dll') 
  
  # Load the System database & create a new game system
  $data_system = load_data("Data/System.rxdata")
  $game_system = Game_System.new
  
  # Check for local saves setting. If set then the Saves folder in the current
  # directory is used (and created if needed)
  # The import searches for saves in the Import folder in the current directory
  if Utility.read_ini('local_saves') == '1'
    $appPath = 'Saves'
    #System::IMPORT_FULL_PATH = "Import"
  else
    # Create Environment Variable containing the short-name of the 
    # Application Data folder. Use 'Saves' directory if it fails.
    begin
      SET_ENV = Win32API.new(utils_file, "AVSetEnv", ["V"], "I") 
      env = SET_ENV.call
      raise "#{utils_file}: AVSetEnv failed!" if (!env)
        
      path = " " * 256
      path = ENV['AV_APPDATA'].rstrip
      $appPath = path.to_s + System::SAVE_APP_PATH
#      if FileTest.exist?(path.to_s + System::IMPORT_SAVE_PATH)
#        System::IMPORT_FULL_PATH = path.to_s + System::IMPORT_SAVE_PATH
#     else 
#        System::IMPORT_FULL_PATH  = path.to_s + "\\BOTM_Saves" 
#        System::IMPORT_GAME_NAME.replace('BOTM')
#      end
    rescue
      $appPath = 'Saves'
      System::IMPORT_FULL_PATH = "Import"
    end
  end  
  
  # Create Your Folder
  if !File.exists?($appPath)  
    Dir.mkdir($appPath) 
  end
  
  #---------------------------------------
  # Set up general information about game
  #---------------------------------------
  Font.default_name = ["Impact", "Arial", "Verdana", "Times New Roman"]
  Font.default_size = 20
  
  # Make scene object (title screen)
  $scene = Scene_Splash.new
  
  # Change frame rate and freeze graphics
  Graphics.frame_rate = System::MAP_FRAME_RATE
  Graphics.freeze
  
  # Check for keyboard events
  $showm = Win32API.new 'user32', 'keybd_event', %w(l l l l), ''
  
  #------------------------------------
  # Debug Settings
  #------------------------------------    
  if (debug == 0)
    CreateMonitor = Win32API.new(utils_file, "CreateMonitor", ["V"], "I") 
    monitor = CreateMonitor.call 
  end 
 
  
  
  #------------------------------------
  # Encryption Settings
  #------------------------------------ 
  if (encrypt == 1)
    GetSecurityCode = Win32API.new('Utils', "GetSecurityCode", ["V"], "I") 
    security = GetSecurityCode.call
 
    $scene = nil if security != 15382
  end

  #------------------------------------
  # Full Screen Settings
  #------------------------------------  
  if fullscreen
    Utility.toggle_fullscreen
  end

  #------------------------------------
  # Start game
  #------------------------------------ 
  # Call main method as long as $scene is effective
  while $scene != nil
    begin
      $scene.main
    rescue StandardError => err
      printErrorMessage(err)
      if Input::press?(Input::A)
        raise
      end
      if Input::press?(Input::F8)
        $scene = nil
      end
    end
  end

  #------------------------------------
  # End game
  #------------------------------------  
  
  # Save screen size settings
  #fullscreen = !(Utility.read_ini('fullscreen') == '0')   # 0=off, 1=on
  #if fullscreen != (IS_FULL_SCREEN.call == 1)
   # fullscreen = fullscreen ? 0 : 1
    #Utility.write_ini('fullscreen',fullscreen)
  #end
  
  # Get rid of graphics
  Graphics.transition(1)
  

#------------------------------------
# Error handling
#------------------------------------  

# Error message when file cannot be opened
rescue Errno::ENOENT
  filename = $!.message.sub("No such file or directory - ", "")
  print("File #{filename} was not found.")
  
  end
  

# Exit the game because there is no need to evaluate the disabled stuff