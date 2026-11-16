#==============================================================================
# ** Arrow_Actor
#------------------------------------------------------------------------------
#  This arrow cursor is used to choose an actor. This class inherits from the
#  Arrow_Base class.
#==============================================================================

class Arrow_Actor < Arrow_Base
  #--------------------------------------------------------------------------
  # * Get Actor Indicated by Cursor
  #--------------------------------------------------------------------------
  def actor
    return $game_party.actors[@index]
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # Cursor right
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @index += 1
      @index %= $game_party.actors.size
    end
    # Cursor left
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @index += $game_party.actors.size - 1
      @index %= $game_party.actors.size
    end
    # Set sprite coordinates
    if self.actor != nil
      self.x = self.actor.screen_x
      self.y = self.actor.screen_y
    end
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    # Display actor status in help window
    @help_window.set_actor(self.actor)
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  #
  def mouse_update
    if Mouse.trigger?(Mouse::LEFT_CLICK) && @my > 288
      owner.fireEvent(MouseEvent.new(self, Mouse::LEFT_CLICK, @index))
    end
    # Get mouse position
    mx, my = Mouse.pos
    # Checks that the mouse have moved
    return if @mx == mx && @my == my
    # Store new position
    @mx, @my = mx, my
    # Pass Through Actors
    for actor in $game_party.actors
      # Gets Paddings
      w, h = actor.battler_width / 2, actor.battler_height
      # If Within Mouse Padding Range
      if mx.between?(actor.screen_x - w, actor.screen_x + w) &&
         my.between?(actor.screen_y - h, actor.screen_y + 10)
        # Set Index
        @index = $game_party.actors.index(actor)
      end
    end
  end
end
