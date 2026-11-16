#==============================================================================
# ** Dialog system
#------------------------------------------------------------------------------
# Zeriab
# Version 1.01
# 2007-11-17 (Year-Month-Day)
#------------------------------------------------------------------------------
# * Description :
#
#   A small framework like script for dialogs
#------------------------------------------------------------------------------
# * License :
#
#   Copyright (C) 2007  Zeriab
#
#   This program is free software: you can redistribute it and/or modify
#   it under the terms of the GNU Lesser Public License as published by
#   the Free Software Foundation, either version 3 of the License, or
#   (at your option) any later version.
#
#   This program is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#   GNU Lesser Public License for more details.
#
#   For the full license see <http://www.gnu.org/licenses/> 
#   The GNU General Public License: http://www.gnu.org/licenses/gpl.txt
#   The GNU Lesser General Public License: http://www.gnu.org/licenses/lgpl.txt
#------------------------------------------------------------------------------
# * Instructions :
#
#   You can place this script pretty much anyway you like.
#   Place it above any other Dialogs you might be using.
#   Increase the STARTING_Z_VALUE if you have trouble with the dialog not
#   on top.
#==============================================================================
class Dialog
  STARTING_Z_VALUE = 6000 # Default value is 1500
  @@z_value = STARTING_Z_VALUE + 1
  attr_accessor :value
  attr_writer :marked_to_close
  #--------------------------------------------------------------------------
  # * Getter with 'false' as default value
  #--------------------------------------------------------------------------
  def marked_to_close
    @marked_to_close = false  if @marked_to_close.nil?
    return @marked_to_close
  end
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def mark_to_close
    self.marked_to_close = true
  end
  #--------------------------------------------------------------------------
  # * Show the dialog
  #   Returns the value from the dialog
  #--------------------------------------------------------------------------
  def self.show(*args, &block)
    dialog = self.new(*args, &block)
    dialog.marked_to_close = false
    return dialog.main
  end
  #--------------------------------------------------------------------------
  # * Initialization
  #--------------------------------------------------------------------------
  def initialize(*args, &block)
    # For subclasses to overwrite
  end
  #--------------------------------------------------------------------------
  # * Main processing
  #--------------------------------------------------------------------------
  def main
    # Increase z_value to deal with nested calls
    @@z_value += 100
    # Create the dimmed background
    create_background
    # Create Windows
    main_window
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Frame update
      update
      # Abort loop if the dialog should close
      if marked_to_close
        break
      end
    end
    # Dispose of windows
    main_dispose
    # Dispose of background
    dispose_background
    # Update input information
    Input.update
    # Decrease z_value to deal with nested calls
    @@z_value -= 100
    # Returns the acquired value
    return self.value
  end
  #--------------------------------------------------------------------------
  # * Create the dimmed background
  #--------------------------------------------------------------------------
  def create_background
    bitmap = Bitmap.new(640,480)
    bitmap.fill_rect(0,0,640,480,Color.new(0,0,0,128))
    @background_sprite = Sprite.new
    @background_sprite.z = @@z_value
    @background_sprite.bitmap = bitmap
  end
  #--------------------------------------------------------------------------
  # * Create the windows
  #--------------------------------------------------------------------------
  def main_window
    # For the subclasses to override
    # Remember to set their z.value to at least STARTING_Z_VALUE + 1
  end
  #--------------------------------------------------------------------------
  # * Dispose the background
  #--------------------------------------------------------------------------
  def dispose_background
    @background_sprite.dispose
  end
  #--------------------------------------------------------------------------
  # * Dispose the windows
  #--------------------------------------------------------------------------
  def main_dispose
    # For the subclasses to override
    # Dispose your windows here
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # For the subclasses to override
    if Input.trigger?(Input::B)
      mark_to_close
    end
  end
end