#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs menu screen processing.
#==============================================================================

class Scene_Top10 < Scene_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     menu_index : command cursor's initial position
  #--------------------------------------------------------------------------
  def initialize(scene=Scene_Map.new)
    @scene = scene
  end
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Get valid actors
    @actors = []
    for i in 2..999
      actor = $game_actors[i]
      @actors << actor  if !actor.nil? && !actor.disabled_for_party
    end
    # Text array
    @texts =  []
    # Make top10 window
    @top10_window = Window_Top10.new
    @top10_window.x = (640-@top10_window.width)
    @top10_window.y = (480-@top10_window.height)
    # Make top10 bar window
    @top10_bar_window = Window_Top10_Bar.new
    # Make command window
    @commands = [ "Obedience",
                 "Love",
                 "Main Menu"]
    @command_changes = {"obedience" => "dexterity",
                        "love" => "intelligence",
                        "speed" => "agility",
                        "kills_by_hits" => "melee_kills",
                        "kills_by_spells" => "skill_kills"}
    @text_changes = {"kill ratio" => "Ratio of kills per battle"}
    @command_window = Window_Command.new(160, @commands)
    @command_window.index = 0
    @command_window.height = @top10_window.height
    @command_window.y = (480-@command_window.height)
    @last_index = @command_window.index
    # Add as a mouse enabled window
    mouse_windows << @command_window
    # Set owner
    @command_window.owner = self
    # Refreshes the top10 window
    sort!
    @top10_window.refresh(@actors, @texts, get_command(0))
    # Scene Objects
    @scene_objects = [@command_window, @top10_window,@top10_bar_window]
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Update mouse
      mouse_update
      # Updates Scene Objects
      @scene_objects.each { |x| x.update }
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose Scene Objects
    @scene_objects.each { |x| x.dispose }
  end
  #--------------------------------------------------------------------------
  # * Get Command
  #--------------------------------------------------------------------------
  def get_command(index)
    command = @commands[index].downcase
    if @text_changes.has_key?(command)
      return @text_changes[command]
    else
      return @commands[index]
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update the actor window
    @top10_window.update
    # If index was changed
    if @last_index != @command_window.index
      @last_index = @command_window.index
      sort! #sorts the actors
      i = @command_window.index
      @top10_window.refresh(@actors, @texts, get_command(i))
    end
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch scene
      $scene = Scene_Menu.new(5)
      return
    end
    # If C button was pressed
    if (Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK)) &&
       (@command_window.index == @commands.size - 1)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch scene
      $scene = Scene_Menu.new(5)
      return
    end
    # Update windows
    @top10_window.update
  end
  #--------------------------------------------------------------------------
  # * Sorts @actors accordingly to the command
  #   Updates @texts as well
  #--------------------------------------------------------------------------
  def sort!
    begin
      str = @commands[@command_window.index].downcase
      str.gsub!(' ') {'_'}
      @actors.sort! {|a,b| a.name <=> b.name}
      if @command_changes.has_key?(str)
        info_str = eval("sort_with_#{@command_changes[str]}")
      else
        info_str = eval("sort_with_#{str}")
      end
      @texts = []
      for actor in @actors
        @texts.push(eval(info_str))
      end
    rescue
      @texts = []
    end
  end
  
  def fireEvent(event)
    # Ignore
  end
  
  private
  
  def sort_with_kills
    @actors.sort! {|a,b| b.kills <=> a.kills}
    "actor.kills"
  end
  def sort_with_melee_kills
    @actors.sort! {|a,b| b.kill <=> a.kill}
    "actor.kill"
  end
  def sort_with_skill_kills
    @actors.sort! {|a,b| b.killzz <=> a.killzz}
    "actor.killzz"
  end
  def sort_with_hp
    @actors.sort! {|a,b| b.maxhp <=> a.maxhp}
    "actor.maxhp"
  end
  def sort_with_mp
    @actors.sort! {|a,b| b.maxsp <=> a.maxsp}
    "actor.maxsp"
  end
  def sort_with_strength
    @actors.sort! {|a,b| b.str <=> a.str}
    "actor.str"
  end
  def sort_with_dexterity
    @actors.sort! {|a,b| b.dex <=> a.dex}
    "actor.dex"
  end
  def sort_with_intelligence
    @actors.sort! {|a,b| b.int <=> a.int}
    "actor.int"
  end
  def sort_with_agility
    @actors.sort! {|a,b| b.agi <=> a.agi}
    "actor.agi"
  end
  def sort_with_defeats
    @actors.sort! {|a,b| $game_variables[DEATH_START_ID + b.id - 1]<=>
                         $game_variables[DEATH_START_ID + a.id - 1]}
    "$game_variables[DEATH_START_ID + actor.id - 1]"
  end
  def sort_with_melee_ratio
    @actors.sort! {|a,b| b.ratio(1) <=> a.ratio(1)}
    "actor.ratio_s(100, 1)"
  end
  def sort_with_item_ratio
    @actors.sort! {|a,b| b.ratio(2) <=> a.ratio(2)}
    "actor.ratio_s(100, 2)"
  end
  def sort_with_skill_ratio
    @actors.sort! {|a,b| b.ratio(4) <=> a.ratio(4)}
    "actor.ratio_s(100, 4)"
  end
#  def sort_with_
#    @actors.sort! {|a,b| b.maxhp <=> a.maxhp}
#  end
end
