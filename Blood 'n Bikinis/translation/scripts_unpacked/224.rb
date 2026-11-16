module System
  # Salt (Let this be in the 0-255 range)
  SALT = 164
  # Game name
  GAME_NAME = "BnB"
  # Game name
  VISUAL_GAME_NAME = "BB"
  # Save path (in the application data)
  SAVE_APP_PATH = "\\#{GAME_NAME}_Saves"
  # DLL file name without the .dll extension
  DLL_FILE = "BBUtils"
  # Ini file name
  INI_FILENAME = GAME_NAME + ".ini"
  # Version
  VERSION = "v1.0"  
  # The framerate on map
  MAP_FRAME_RATE = 50 # 50
  # The framerate in battles
  BATTLE_FRAME_RATE = 80 # 80
  # Amount of save files
  SAVEFILE_AMOUNT = 25
  # Variable determining minimum amount of steps before an encounter
  MINIMUM_STEPS_VARIABLE = 1
  # The transparancy of text shadows
  SHADOW_TRANSPARANCY = 188
  # Double Lines
  EXTRA_DESCRIPTION_LINES = 2
  
  module Menu
    # The font size used for writing the elemental and state effects
    EFFECT_FONT_SIZE = 18
    
    # Index to icon map. Only the menu items that have a mapping will get a icon
    INDEX_TO_ICON = {}
    INDEX_TO_ICON[0] = 'items'
    INDEX_TO_ICON[1] = 'spell-01-likeaboss'
    INDEX_TO_ICON[2] = 'casualclothes'  
    INDEX_TO_ICON[3] = 'info'  
    INDEX_TO_ICON[4] = 'team'
    INDEX_TO_ICON[5] = 'girls'  
    INDEX_TO_ICON[6] = 'save'
    INDEX_TO_ICON[7] = 'exit'  
    INDEX_TO_ICON[8] = 'options'  
    ICON_TEXT_OFFSET = 28
  end
  
 
  ##
  # Mouse constants
  #
  module Mouse
    # Default mouse icon
    DEFAULT_ICON = 'cursor1'
    # Default offset for mouse text
    DEFAULT_OFFSET_X = 15
    DEFAULT_OFFSET_Y = 15
    # Number of frames to wait between each scroll
    SCROLL_WAIT = 6
    # Frames to wait between each repeat
    REPEAT_WAIT = 4
    # Frames to wait from the first repeat to the following repeats
    REPEAT_START_WAIT = 20
  end
  
  ##
  # Battle constants
  #
  module Battle
    # How long the state change window for allies (heroes) will stay visible
    ALLY_STATE_WAIT = 85
    # How long the state change window for enemies will stay visible
    ENEMY_STATE_WAIT = 145
    # Common event to run after battle
    BATTLE_END_COMMON_EVENT = 4
        # <Z> Variable to set battle result
    BATTLE_END_RESULT_VARIABLE = 31 #results (0:win 1:lose 2:escape)
    # </Z>
    # Enemies on whom counter spell does not work
    ENEMY_NO_COUNTER_SPELL = []
    # Minimum rating required before states are shown when add/removed
    VISIBLE_STATE_RATING_MINIMUM = 1
    # Common event to run on battle turns end where combat is still in progress
    COMMON_EVENT_ON_TURN_END = 5
  end
  
  ##
  # Hall of Fame
  #
  module Hall_Of_Fame
    # The max amount of actors to display in the hall of fame
    MAX_ACTORS = 10
    # The amount of frames to wait before scrolling begins
    WAIT_BEFORE_SCROLL = 5000
    # The amount of frames to wait at the bottom and top
    SCROLL_WAIT = 500
    # Scroll speed in pixels per second
    SCROLL_SPEED = 0.5
  end  
end

##
# Constants in the Game_Actor class
#
class Game_Actor < Game_Battler
  # The id of the switch which will activate common event on equip
  COMMON_EVENT_ON_EQUIP_SWITCH = 38
  # The id of the common event which will run on equip
  COMMON_EVENT_ON_EQUIP = 11
  # The id of the common event which will run on level
  COMMON_EVENT_ON_LEVEL = 10
  # The id of the common event which will run on load
  COMMON_EVENT_ON_LOAD = 9
end

#==============================================================================
# ** Constants for the anti lag script
#==============================================================================

class Game_Event
  SPECIAL_UPDATE_IDS = {} #{[1,1]=>'A',
                          # [1,2]=>'N'}
  NEVER_UPDATE_NAME_PATTERNS = ['[N]'] # [N] in the event name => not updated
  ALWAYS_UPDATE_NAME_PATTERNS = ['[A]'] # [A] in the event name => always updated 
end

class Game_Map
  ALWAYS_UPDATE = false #true
  BUFFER_SIZE = 4
  TILES_VERTICAL = 15
  TILES_HORIZONTAL = 20
  COMMON_EVENTS_TO_UPDATE = [12,195,205,313] #[common_event_id1, common_event_id2, ...]
end