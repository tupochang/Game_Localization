#==============================================================================
# Easy Party Switcher by Blizzard
# Version 1.51b
# Date: 21.05.2006
# Date v1.1: 25.05.2006
# Date v1.2b: 27.05.2006
# Date v1.5b: 3.11.2006
# Date v1.51b: 29.11.2006
# 
# 
# This is the official Party Switcher of:
# Project Phoenix
# 
# 
# Special Thanks to:
# Zeriab for pointing out a few glitches and shortening the code. =D
# 
# 
# IMPORTANT NOTE:
# 
# Be sure to set the MAX_PARTY to the maximum size of your party.
# There is already a preconfiguration of 4.
# 
# 
# Compatibility:
# 
# 99% chance of full compatibility with SDK, not tested altough. Can cause
# incompatibility with Party Change Systems. WILL corrupt your old savegames.
# 
# 
# Features:
# 
# - Set party members for "not _available" (shown transparent in the reserve)
# - Remove party members from the reserve list ("disabled_for_party")
# - Set party members, who MUST be in the party (shown transparent in the
#   current party, "must_be_in_party")
# - option either to wipe the party (for multi-party use) or only remove every
#   member (except 1) from the party.
# - Easy to use and easy to switch party members
# - also supports small parties (2 or 3 members) and large parties (5 or more)
# 
# v1.5b:
# 
# - better, shorter and more efficient code (less memory use, less CPU use)
# - fixed potential bugs
# 
# 
# How to use:
# 
# To call this script, make a "Call script" command in an event. The syntax is:
# 
# $scene = Scene_PartySwitcher.new
# or
# $scene = Scene_PartySwitcher.new(XXX)
# or
# $scene = Scene_PartySwitcher.new(XXX, 1)
# or
# $scene = Scene_PartySwitcher.new(XXX, YYY, ZZZ)
# 
# - If you use the first syntax, no extra feature will be applied and you can
# switch the party as you wish.
# - If you use the second syntax, you can replace XXX for 1 to remove all party
# members except one (either one, who must be in the party or a random one), or
# replace XXX with 2, to cause a wipe party. Wiping a party will disable the
# of the current members and a NEW party of the remaining members must be
# formed. If you replace it with 3, the current party configuration will be
# stored for a later fast switch-back.
# - If you use the third sytnax, you can use the XXX as described above or just
# set it to 0 to disable it. Also the "1" in the syntax will reset any
# disabled_for_party and is made to be used after multi-party use.
# - If you use the fourth syntax you can replace ZZZ with 1 to replace the
# party with a stored one AND store the current or replace it with 2 to replace
# the party with a stored one, but without storing the current. USE THIS ONLY
# IF YOU ASSUME TO HAVE A STORED PARTY READY! You can simply test if there is
# a store party by putting this code into the conditional branch script:
# 
# $game_system.stored_party != nil
# 
# This syntax will not open the Party Switcher and it will override the
# commands XXX and YYY, so you can replace these with any number.
# 
# - Character faces go into a "Faces" folder in "Characters" and they have the
# same name as the character spritesets have.
# 
# 
# Other syntaxes:
# $game_actors[XXX].not_available = true/false
# $game_actors[XXX].disabled_for_party = true/false
# $game_actors[XXX].must_be_in_party = true/false
# 
# - not_available will disable the possibility of an already unlocked character
# to be in th current party.
# - disabled for party will cause the character NOT to appear in the party
# switch screen.
# - must_be_in_party will cause the character to be automatically moved into
# the current party, while switching parties and also he cannot be put in the
# reserve.
# 
# 
# Additional note:
# 
# For your own sake, do not apply the attribute "must_be_in_party" to a
# character at the same time with "not_available" or "disabled_for_party" as
# this WILL disrupt your party and party switch system.
# 
#==============================================================================

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# START Conficuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

MAX_PARTY = 4 # how many party members do you use

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# END Conficuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#==============================================================================
# Game_Actor
#==============================================================================

class Game_Actor < Game_Battler

  attr_accessor   :must_be_in_party
  attr_accessor   :disabled_for_party
  attr_accessor   :not_available

  alias setup_eps_later setup
  def setup(actor_id)
    @must_be_in_party = false
    @disabled_for_party = false
    @not_available = false
    setup_eps_later(actor_id)
  end
 
end

#==============================================================================
# Game_System
#==============================================================================

class Game_System

  attr_accessor :stored_party
 
end

#==============================================================================
# Game_Party
#==============================================================================

class Game_Party

  attr_accessor :actors
 
end

#==============================================================================
# Window_Base
#==============================================================================

class Window_Base

  def draw_actor_face2(actor, x, y)
    if actor != nil && actor.character_name != nil && actor.character_name != ''
      bitmap = RPG::Cache.character("Faces/" + actor.character_name, actor.character_hue)
      cw = 120
      ch = 80
      src_rect = Rect.new(0, 0, cw, ch)
      if actor.not_available or actor.must_be_in_party
        self.contents.blt(x, y, bitmap, src_rect, 128)
      else
        self.contents.blt(x, y, bitmap, src_rect)
      end
    end
  end
 
end

#==============================================================================
# Window_Current
#==============================================================================

class Window_Current < Window_Selectable_Type_2

  def initialize
    if MAX_PARTY > 4
      super(0, 0, 240 + 32, 480)
    else
      super(0, 0, 240 + 32, MAX_PARTY * 120)
    end
    @item_max = MAX_PARTY
    self.contents = Bitmap.new(width - 32, 480 - 32 + (@item_max - 4) * 120)
    if $fontface != nil
      self.contents.font.name = $fontface
    elsif $defaultfonttype != nil
      self.contents.font.name = $defaultfonttype
    end
    self.contents.font.size = 24
    refresh
    self.active = false
    self.index = -1
  end
  
  def refresh
    self.contents.font.name = ["Arial", "Times New Roman"]
    self.contents.font.size = 13
    self.contents.clear
    for i in 0...$game_party.actors.size
      x = 0
      y = i * 120 - 4
      actor = $game_party.actors[i]
      self.contents.font.color = normal_color
      if actor != nil
        draw_actor_face2(actor, x, y + 8)
        draw_actor_name(actor, x + 160, y)
        draw_actor_level(actor, x + 96, y)
        draw_actor_hp(actor, x + 96, y + 32)
        draw_actor_sp(actor, x + 96, y + 64)
      end
    end
  end

  def setactor(index_1, index_2)
    temp = $game_party.actors[index_1]
    $game_party.actors[index_1] = $game_party.actors[index_2]
    $game_party.actors[index_2] = temp
    refresh
  end

  def getactor(index)
    return $game_actors[$game_party.actors[index].id]
  end
 
  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    x = 0
    y = (@index / @column_max) * 120 - self.oy
    self.cursor_rect.set(x, y, self.width - 32, 88)
  end
 
  def clone_cursor
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    x = 0
    y = (@index / @column_max) * 120
    src_rect = Rect.new(0, 0, self.width, 88)
    bitmap = RPG::Cache.windowskin("Cursor_Current")
    self.contents.blt(x, y, bitmap, src_rect, 192)
  end
 
  def top_row
    return self.oy / 116
  end

  def top_row=(row)
    row = row % row_max
    self.oy = row * 120
  end

  def page_row_max
    return (self.height / 120)
  end

  ##
  # Get the height of the elements
  #
  def element_height
    return 120
  end
end

#==============================================================================
# Window_Reserve
#==============================================================================

class Window_Reserve < Window_Selectable_Type_2
 
  def initialize
    super(0, 0, 400 - 32, 320)
    setup
    @column_max = 3
    if (@item_max / @column_max) >= 3
      self.contents = Bitmap.new(width - 32, @item_max / @column_max * 96)
    else
      self.contents = Bitmap.new(width - 32, height - 32)
    end
    if $fontface != nil
      self.contents.font.name = $fontface
    elsif $defaultfonttype != nil
      self.contents.font.name = $defaultfonttype
    end
    self.contents.font.size = 24
    self.active = false
    self.index = -1
    refresh
  end
 
  def setup
    @actors = []
    for i in 1...$data_actors.size
      unless $game_party.actors.include?($game_actors[i])
        unless $game_actors[i] == nil or $game_actors[i].disabled_for_party
          @actors.push($game_actors[i])
        end
      end
    end
    @item_max = (@actors.size + $game_party.actors.size + 3) / 3 * 3
  end
 
  def refresh
    self.contents.clear
    for i in 0... @actors.size
      draw_face(i)
    end
  end
 
  def draw_face(i)
    x = (i % 3) * 112 + 16
    y = (i / 3) * 96 - 8
    self.contents.font.color = normal_color
    draw_actor_face2(@actors[i], x - 32, y + 18) # EDIT POSITION
  end
   
  def getactor(index)
    return @actors[index]
  end
 
  def setactor(index_1, index_2)
    temp = @actors[index_1]
    @actors[index_1] = @actors[index_2]
    @actors[index_2] = temp
    refresh
  end

  def setparty(index_1, index_2)
    temp = @actors[index_1]
    @actors[index_1] = $game_party.actors[index_2]
    $game_party.actors[index_2] = temp
    refresh
  end

  def update_cursor_rect
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    x = (@index % @column_max) * 112 + 8
    y = (@index / @column_max) * 96 - self.oy
    self.cursor_rect.set(x, y, 96, 96)
  end

  def clone_cursor
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    x = (@index % @column_max) * 112 + 8
    y = (@index / @column_max) * 96
    src_rect = Rect.new(0, 0, 96, 96)
    bitmap = RPG::Cache.windowskin("Cursor_Reserve")
    self.contents.blt(x, y, bitmap, src_rect, 192)
  end
 
  def top_row
    return self.oy / 96
  end

  def top_row=(row)
    row = row % row_max
    self.oy = row * 96
  end 

  def page_row_max
    return (self.height - 32) / 96
  end

  ##
  # Get the width of the elements
  #
  def element_width
    return 112
  end
  ##
  # Get the height of the elements
  #
  def element_height
    return 96
  end
end

#==============================================================================
# Window_HelpStatus
#==============================================================================

class Window_HelpStatus < Window_Base

  def initialize(gotactor)
    super(0, 0, 400 - 32, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    if $fontface != nil
      self.contents.font.name = $fontface
    elsif $defaultfonttype != nil
      self.contents.font.name = $defaultfonttype
    end
    self.contents.font.size = 24
    refresh(gotactor)
    self.active = false
  end
 
  def refresh(actor)
    self.contents.font.name = ["Arial", "Times New Roman"]
    self.contents.font.size = 13
    self.contents.clear
    if actor != nil
      x = 0
      y = 0
      self.contents.font.color = normal_color
      if actor.not_available
        self.contents.draw_text(x + 8, y, 160, 32, "not avail. (visit castle to recruit)", 0)
      end
      draw_actor_face2(actor, x, y + 40)
      draw_actor_name(actor, x + 160, y + 32)
      draw_actor_level(actor, x + 96, y + 32)
      draw_actor_hp(actor, x + 96, y + 64)
      draw_actor_sp(actor, x + 96, y + 96)
    end
  end

end

#==============================================================================
# Window_Warning
#==============================================================================

class Window_Warning < Window_Base

 def initialize
    super(0, 0, 320, 96)
    self.visible = false
    self.contents = Bitmap.new(width - 32, height - 32)
    if $fontface != nil
      self.contents.font.name = $fontface
    elsif $defaultfonttype != nil
      self.contents.font.name = $defaultfonttype
    end
    self.contents.font.size = 24
    self.x = 320 - (width / 2)
    self.y = 240 - (height / 2)
    self.z = 9999
    self.contents.font.color = normal_color
    self.contents.draw_text(0, 0, 288, 32, "You cannot remove", 1)
    self.contents.draw_text(0, 32, 288, 32, "the last party member!", 1)
  end

end

#==============================================================================
# Scene_PartySwitcher
#==============================================================================

class Scene_PartySwitcher < Scene_Base
 
  def initialize(wipe_party = 0, reset = 0, store = 0)
    @wipe_party = wipe_party
    @store = store
    @reset = reset
    @current_window_temp = 0
    @reserve_window_temp = 0
    @scene_flag = false
    @temp_window = ""
  end
 
  def main
    if @store != 0
      swap_parties
      $scene = Scene_Map.new
      $game_player.refresh
      return
    end
    case @wipe_party
    when 1 then setup_forced_party
    when 2 then wipe_party
    when 3
      $game_system.stored_party = $game_party.actors
      wipe_party
    end
    @current_window = Window_Current.new
    @current_window.index = 0
    @current_window.active = true
    @reserve_window = Window_Reserve.new
    @reserve_window.x = 240 + 32
    @reserve_window.y = 160
    # Add as mouse enabled windows
    mouse_windows << @current_window
    mouse_windows << @reserve_window
    # Set owners
    @current_window.owner = self
    @reserve_window.owner = self
    # Create warning window
    @warning_window = Window_Warning.new
    @help_window = Window_HelpStatus.new(@reserve_window.getactor(0))
    @help_window.x = 240 + 32
    if @reset == 1
      for i in 1...$data_actors.size
        $game_actors[i].not_available = false
      end
    end
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      mouse_update
      update
      break if $scene != self
    end
    Graphics.freeze
    @current_window.dispose
    @reserve_window.dispose
    @help_window.dispose
    $game_party.actors.compact!
    $game_player.refresh
  end
 
  def update
    check = @reserve_window.index
    if @reserve_window.active
      reserve_update
      @reserve_window.update
    end
    if check != @reserve_window.index
      if @reserve_window.active
        actor = @reserve_window.getactor(@reserve_window.index)
      elsif @current_window.active 
        actor = @reserve_window.getactor(@reserve_window_temp)
      end
      if @temp_window == "Current" or @temp_window == ""
        @help_window.refresh(actor)
      end
    end
    if @current_window.active
      current_update
      @current_window.update
    end
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      $game_system.se_play($data_system.cancel_se)
      unless @scene_flag
        if $game_switches[284] == true
         $scene = Scene_Map.new
        elsif $game_switches[285] == true
         $scene = Scene_Item.new
       else
         Utility.run_common_event(192) 
         $scene = Scene_Menu.new(4)
        end
      else
        @temp_window = ""
        @scene_flag = false
        if @reserve_window.active
          actor = @reserve_window.getactor(@reserve_window.index)
        elsif @current_window.active
          actor = @reserve_window.getactor(@reserve_window_temp)
        end
        if @temp_window == "Current" or @temp_window == ""
          @help_window.refresh(actor)
        end
        @current_window.refresh
        @reserve_window.refresh
      end
      return
    end
    if Input.trigger?(Input::A) || Mouse.trigger?(Mouse::MIDDLE_CLICK)
      $game_party.actors.compact!
      @current_window.refresh
    end
  end
   
  def current_update
    if Input.trigger?(Input::C)
      current_trigger
      return
    end
    if Input.trigger?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      current_switch
    end
  end
  
  def current_trigger
    unless @scene_flag
      $game_system.se_play($data_system.decision_se)
      @scene_flag = true
      @temp_actor_index = @current_window.index
      @temp_window = "Current"
      @current_window.clone_cursor
    else
      switch_members
    end
  end
  
  def current_switch
    @current_window.active = false
    @reserve_window.active = true
    @current_window_temp = @current_window.index
    actor = @reserve_window.getactor(@reserve_window_temp)
    @current_window.index = -1
    @reserve_window.index = @reserve_window_temp
    @help_window.refresh(actor) unless @scene_flag
    return
  end
 
  def reserve_update
    if Input.trigger?(Input::C)
      reserve_trigger
      return
    end
    if (@reserve_window.index % 3) == 0
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        reserve_switch
      end
    end
  end
  
  def reserve_trigger
    unless @scene_flag
      $game_system.se_play($data_system.decision_se)
      @scene_flag = true
      @temp_actor_index = @reserve_window.index
      @temp_window = "Reserve"
      @reserve_window.clone_cursor
    else
      switch_members
    end
  end
  
  def reserve_switch
      @reserve_window.active = false
      @current_window.active = true
      @reserve_window_temp = @reserve_window.index
      @reserve_window.index = -1
      @current_window.index = @current_window_temp
  end
 
  def switch_members
    if @temp_window == "Reserve" and @reserve_window.active
      @reserve_window.setactor(@temp_actor_index, @reserve_window.index)
      actor = @reserve_window.getactor(@reserve_window.index)
      @help_window.refresh(actor)
    end
    if @temp_window == "Current" and @current_window.active
      @current_window.setactor(@temp_actor_index, @current_window.index)
    end
    if @temp_window == "Reserve" and @current_window.active
      actor1 = @current_window.getactor(@current_window.index)
      actor2 = @reserve_window.getactor(@temp_actor_index)
      if call_warning(@current_window.index, actor2)
        if actor1 != nil and actor1.must_be_in_party
          $game_system.se_play($data_system.buzzer_se)
          @scene_flag = false
          @temp_window = ""
          actor = @reserve_window.getactor(@reserve_window_temp)
          @current_window.refresh
          @reserve_window.refresh
          @help_window.refresh(actor)
          return
        end
        if actor2 != nil and actor2.not_available
          $game_system.se_play($data_system.buzzer_se)
          @scene_flag = false
          @temp_window = ""
          actor = @reserve_window.getactor(@reserve_window_temp)
          @current_window.refresh
          @reserve_window.refresh
          @help_window.refresh(actor)
          return
        end
        @reserve_window.setparty(@temp_actor_index, @current_window.index)
        @current_window.refresh
        actor = @reserve_window.getactor(@reserve_window_temp)
        @help_window.refresh(actor)
      else
        warning
      end
    end
    if @temp_window == "Current" and @reserve_window.active
      actor1 = @current_window.getactor(@temp_actor_index)
      actor2 = @reserve_window.getactor(@reserve_window.index)
      if call_warning(@temp_actor_index, actor2)
        if actor1 != nil and actor1.must_be_in_party
          $game_system.se_play($data_system.buzzer_se)
          @scene_flag = false
          @temp_window = ""
          actor = @reserve_window.getactor(@reserve_window.index)
          @current_window.refresh
          @reserve_window.refresh
          @help_window.refresh(actor)
          return
        end
        if actor2 != nil and actor2.not_available
          $game_system.se_play($data_system.buzzer_se)
          @scene_flag = false
          @temp_window = ""
          actor = @reserve_window.getactor(@reserve_window.index)
          @current_window.refresh
          @reserve_window.refresh
          @help_window.refresh(actor)
          return
        end
        @reserve_window.setparty(@reserve_window.index, @temp_actor_index)
        @current_window.refresh
        actor = @reserve_window.getactor(@reserve_window.index)
        @help_window.refresh(actor)
      else
        warning
      end
    end
    $game_system.se_play($data_system.decision_se)
    @scene_flag = false
    @temp_window = ""
    return
  end
   
  def wipe_party
    for i in 0...$game_party.actors.size
      $game_party.actors[i].not_available = true if $game_party.actors[i] != nil
    end
    $game_party.actors = []
    for i in 1...$data_actors.size
      actor = $game_actors[i]
      if actor != nil and actor.must_be_in_party and not actor.not_available
        $game_party.actors[$game_party.actors.size] = actor
      end
    end
    if $game_party.actors == []
      for i in 1...$data_actors.size
        actor = $game_actors[i]
        unless actor == nil or actor.not_available or actor.disabled_for_party
          $game_party.actors[$game_party.actors.size] = actor
          return
        end
      end
    end
  end
 
  def setup_forced_party
    $game_party.actors = []
    for i in 1...$data_actors.size
      actor = $game_actors[i]
      if actor != nil and actor.must_be_in_party and
           not actor.disabled_for_party and not actor.not_available
        $game_party.actors[$game_party.actors.size] = actor
      end
    end
  end  

  def swap_parties
    $game_party.actors.compact!
    temp_actors = $game_party.actors
    for actor in temp_actors
      actor.not_available = true
    end
    $game_system.stored_party.compact!
    for actor in $game_system.stored_party
      actor.not_available = false
    end
    $game_party.actors = $game_system.stored_party
    $game_system.stored_party = nil
    $game_system.stored_party = temp_actors if @store == 1
  end
 
  def call_warning(index, actor2)
    actor1 = $game_party.actors[index]
    if actor1 != nil and actor2 == nil
      count = 0
      for actor in $game_party.actors
        count += 1 unless actor == nil
      end
      return false if count <= 1
    end
    return true
  end
 
  def warning
    $game_system.se_play($data_system.buzzer_se)
    @warning_window.visible = true
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK) ||
         Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
        Mouse.update
        @warning_window.visible = false
        @current_window.refresh
        @reserve_window.refresh
        break
      end
    end
    return
  end
 
  ##
  # Update the mouse
  #
  def mouse_update
    # Do nothing if the mouse is not enabled
    return unless Mouse.enabled
    mx, my = Mouse.pos
    # Check if the mouse position has changed
    if @mx == mx && @my == my
      moved = false
    else
      moved = true
      @mx = mx
      @my = my
    end
    # Go through the mouse enabled windows
    for window in mouse_windows
      # Remove disposed windows
      if window.disposed?
        mouse_windows.delete(window)
        next
      end
      # Ignore inactive and invisible windows
      next unless window.visible
      # Check if the mouse is over the window
      if mouse_inside_window?(window)
        # If the mouse have moved
        if moved
          unless window.active
            reserve_switch if window == @current_window
            current_switch if window == @reserve_window
          end
          # Store reserve window index
          if (window == @reserve_window)
            index = @reserve_window.index
          end
          # Calculate relative coordinates
          rx = mx - window.x
          ry = my - window.y
          window.mouse_move(rx, ry)
          # If different actor has been selected
          if (window == @reserve_window &&
              @reserve_window != index)
            actor = @reserve_window.getactor(@reserve_window.index)
            @help_window.refresh(actor)
          end
        end
        # Let the window update with the mouse over it
        window.mouse_update
      end
    end
  end
  
  ##
  # Events can be fired on scenes
  #
  def fireEvent(event)
    current_trigger if event.sender == @current_window
    reserve_trigger if event.sender == @reserve_window
  end
end