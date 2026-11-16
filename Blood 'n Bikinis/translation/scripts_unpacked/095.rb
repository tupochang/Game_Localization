#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Main processing
  #--------------------------------------------------------------------------
  def main
    Graphics.frame_rate = System::BATTLE_FRAME_RATE
    @frame_start_count = Graphics.frame_count
    # Initializes the battle
    init_battle
    # Creates the Windows
    create_windows
    # Start pre-battle phase
    start_phase1
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Mouse update
      mouse_update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Cleans up after the battle
    clean_up_battle
    # Change frame count so it fits with the map frame_rate
    map_frame_rate = System::MAP_FRAME_RATE
    # Calculates the amount of frames used in the battle
    battle_frame_count = @frame_start_count - Graphics.frame_count
    # Normalizes the frame count
    normalized_frame_count = battle_frame_count * map_frame_rate / System::BATTLE_FRAME_RATE
    # Substract difference in frames
    delta_frame_count = battle_frame_count - normalized_frame_count
    Graphics.frame_count -= delta_frame_count if delta_frame_count > 0
    # Change the frame_rate to the map frame_rate
    Graphics.frame_rate = System::MAP_FRAME_RATE
  end
  #--------------------------------------------------------------------------
  # * Initializes the battle
  #--------------------------------------------------------------------------
  def init_battle
    # Initialize each kind of temporary battle data
    $game_temp.in_battle = true
    $game_temp.battle_turn = -1
    $game_temp.battle_event_flags.clear
    $game_temp.battle_abort = false
    $game_temp.battle_main_phase = false
    $game_temp.battleback_name = $game_map.battleback_name
    $game_temp.forcing_battler = nil
    # Initialize battle event interpreter
    $game_system.battle_interpreter.setup(nil, 0)
    # Reset states
    for actor in $game_party.actors
      actor.reset_state_change
    end
    # Prepare troop
    @troop_id = $game_temp.battle_troop_id
    $game_troop.setup(@troop_id)
    @execute_now_battlers = Linked_List.new
    @boss = nil
  end
  #--------------------------------------------------------------------------
  # * Creates the windows for the battle screen
  #--------------------------------------------------------------------------
  def create_windows
    # Make actor command window
    
    s1 = $data_system.words.attack
    s2 = $data_system.words.skill
    s3 = $data_system.words.guard
    s4 = $data_system.words.item
    @actor_command_window = Window_Command.new(160, [s1, s2, s3, s4]) 
    @actor_command_window.y = 0 #BvZ
    @actor_command_window.back_opacity = 160
    @actor_command_window.active = false
    @actor_command_window.visible = false
    # Make other windows
    @party_command_window = Window_PartyCommand.new
    @help_window = Window_Help.new
    @help_window.back_opacity = 160
    @help_window.visible = false
    @status_window = Window_BattleStatus.new
    @message_window = Window_Message.new
    # Add as a mouse enabled window
    mouse_windows << @actor_command_window
    mouse_windows << @party_command_window
    mouse_windows << @message_window
    # Set owners
    @actor_command_window.owner = self
    @party_command_window.owner = self
    # Make state windows
    @state_windows = []
    for actor in $game_party.actors
      @state_windows << Window_StateChange.new(actor)
    end
    @state_enemy_windows = []
    for battler in $game_troop.enemies
      @state_enemy_windows << Window_StateEnemyChange.new(battler)
    end
    @update_state_windows = false
    # Make sprite set
    @spriteset = Spriteset_Battle.new
    # Initialize wait count
    @wait_count = 0
    # Execute transition
    if $data_system.battle_transition == ""
      Graphics.transition(20)
    else
      Graphics.transition(40, "Graphics/Transitions/" +
        $data_system.battle_transition)
    end
  end
  #--------------------------------------------------------------------------
  # * Update state windows
  #--------------------------------------------------------------------------
  def update_state_windows
    for actor in $game_party.actors
      if !(actor.state_change_plus.empty? && 
           actor.state_change_minus.empty?) &&
           @state_windows[actor.index] != nil?
        @state_windows[actor.index].refresh
        actor.reset_state_change
        @state_windows[actor.index].visible = true
        @update_state_windows = true
        actor.state_changes = false
      end
    end
    for battler in $game_troop.enemies
      if !(battler.state_change_plus.empty? &&
           battler.state_change_minus.empty?) &&
           @state_enemy_windows[battler.index] != nil &&
           battler.exist?
        @state_enemy_windows[battler.index].refresh
        battler.reset_state_change
        @state_enemy_windows[battler.index].visible = true
        @update_enemy_state_windows = true
        battler.state_changes = false
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Cleans up when the battle ends
  #--------------------------------------------------------------------------
  def clean_up_battle
    # Refresh map
    $game_map.refresh
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @actor_command_window.dispose
    @party_command_window.dispose
    @help_window.dispose
    @status_window.dispose
    @message_window.dispose
    if @skill_window != nil
      @skill_window.dispose
    end
    if @item_window != nil
      @item_window.dispose
    end
    if @result_window != nil
      @result_window.dispose
    end
    if @state_windows != nil
      for window in @state_windows
        window.dispose unless window.nil?
      end
    end
    if @state_enemy_windows != nil
      for window in @state_enemy_windows
        window.dispose unless window.nil?
      end
    end
    # Dispose of sprite set
    @spriteset.dispose
    # If switching to title screen
    if $scene.is_a?(Scene_Title)
      # Fade out screen
      Graphics.transition
      Graphics.freeze
    end
    # If switching from battle test to any screen other than game over screen
    if $BTEST and not $scene.is_a?(Scene_Gameover)
      $scene = nil
    end
  end
  
  ##
  # Return the index of the current active battler. (-1 with no active battler)
  #
  def get_active_battler_index
    unless @active_battler.nil?
      return @active_battler.index
    end
    return -1
  end
  ##
  # Return the index of the current active battler. (-1 with no active battler)
  #
  def get_active_battler_id
    unless @active_battler.nil?
      return @active_battler.id
    end
    return -1
  end
  
  ##
  # Check if the current battler is an enemy
  #
  def is_active_battler_enemy?
    if @active_battler.is_a?(Game_Enemy)
      return true
    end
    return false
  end
  
  ##
  # Register this battle as a boss fight
  #
  def boss_fight(key)
    @boss = key
  end
  
  ##
  # Events can be fired on scenes
  #
  def fireEvent(event)
    phase2_trigger if event.sender == @party_command_window
    phase3_basic_trigger if event.sender == @actor_command_window
    phase3_skill_trigger if event.sender == @skill_window
    phase3_item_trigger if event.sender == @item_window
    phase3_actor_trigger if event.sender == @actor_arrow
    phase3_enemy_trigger if event.sender == @enemy_arrow
  end
end