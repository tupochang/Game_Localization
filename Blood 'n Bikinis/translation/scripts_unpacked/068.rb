#==============================================================================
# ** Arrow_Enemy
#------------------------------------------------------------------------------
#  This arrow cursor is used to choose enemies. This class inherits from the 
#  Arrow_Base class.
#==============================================================================

class Arrow_Enemy < Arrow_Base
  def initialize(*args)
    super
    @index = 1
    if self.enemy.nil?
      @index = 0
    end
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Indicated by Cursor
  #--------------------------------------------------------------------------
  def enemy
    return $game_troop.enemies[@index]
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # Skip if indicating a nonexistant enemy
    $game_troop.enemies.size.times do
      break if self.enemy.exist?
      @index += 1
      @index %= $game_troop.enemies.size
    end
    # Cursor right
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += 1
        @index %= $game_troop.enemies.size
        break if @index > 0 && self.enemy.exist?
      end
    end
    # Cursor left
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_troop.enemies.size.times do
        @index += $game_troop.enemies.size - 1
        @index %= $game_troop.enemies.size
        break if @index > 0 && self.enemy.exist?
      end
    end
    # Set sprite coordinates
    if self.enemy != nil
      self.x = self.enemy.screen_x
      self.y = self.enemy.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    # Display enemy name and state in the help window
    @help_window.set_enemy(self.enemy)
  end
  
  ##
  # Update mouse position
  #
  def mouse_move(mx, my)
    # Pass Through Enemies
    for enemy in $game_troop.enemies
      # Skip if Non-Existing Enemy
      next unless enemy.exist?
      # Gets Paddings
      w, h = enemy.battler_width / 2, enemy.battler_height
      # If Within Mouse Padding Range
      if mx.between?(enemy.screen_x - w, enemy.screen_x + w) &&
         my.between?(enemy.screen_y - h, enemy.screen_y + 10)
        # Set Index
        @index = $game_troop.enemies.index(enemy)
        break
      end
    end
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  #
  def mouse_update
    if Mouse.trigger?(Mouse::LEFT_CLICK) && @my < 320
      owner.fireEvent(MouseEvent.new(self, Mouse::LEFT_CLICK, @index))
    end
    mx, my = Mouse.pos
    return if @mx == mx && @my == my
    @mx, @my = mx, my
    # Pass Through Enemies
    for enemy in $game_troop.enemies
      # Skip if Non-Existing Enemy
      next unless enemy.exist?
      # Gets Paddings
      w, h = enemy.battler_width / 2, enemy.battler_height
      # If Within Mouse Padding Range
      if mx.between?(enemy.screen_x - w, enemy.screen_x + w) &&
         my.between?(enemy.screen_y - h, enemy.screen_y + 10)
        # Set Index
        index = $game_troop.enemies.index(enemy)
        @index = index if index > 0
        break
      end
    end
  end
end
