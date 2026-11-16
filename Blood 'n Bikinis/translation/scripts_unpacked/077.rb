#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This class holds functionality common to most if not all scenes.
#  Mouse functionality is an example
#==============================================================================

module Mouse_Windows
  attr_sec_reader :mouse_windows, '[]'
  
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
      next unless window.active && window.visible
      # Check if the mouse is over the window
      if mouse_inside_window?(window)
        # If the mouse have moved
        if moved
          # Calculate relative coordinates
          rx = mx - window.x
          ry = my - window.y
          window.mouse_move(rx, ry)
        end
        # Let the window update with the mouse over it
        window.mouse_update
      end
    end
  end
  
  ##
  # Check if the mouse is inside the given window
  #
  def mouse_inside_window?(window)
    mx, my = @mx, @my
    return mx >= window.x && mx < (window.x + window.width) &&
           my >= window.y && my < (window.y + window.height)
  end
  
  ##
  # Events can be fired on scenes
  #
  def fireEvent(event)
    return unless $DEBUG
    raise StandardError.new("fireEvent(*args) was not overwritten in #{self.class}")
  end
end