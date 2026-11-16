#------------------------------------------------------------------------------
# * Instructions :
#
#    Place this script anywhere above main.
#    The image file 'pause' present in Graphics/Pictures is used.
#    Note: No picture is shown if there is no 'pause' in Graphics/Pictures.
#==============================================================================
 
#=============================================================================
# ** Reset class (because it won't be defined until F12 is pressed otherwise)
#=============================================================================
class Reset < Exception
 
end
#=============================================================================
# ** Module Graphics
#=============================================================================
module Graphics
  class << self
     #-------------------------------------------------------------------------
     # * Aliases Graphics.update and Graphics.transition
     #-------------------------------------------------------------------------
     unless self.method_defined?(:zeriab_f12_pause_update)
        alias_method(:zeriab_f12_pause_update, :update)
        alias_method(:zeriab_f12_pause_transition, :transition)
     end
     #-------------------------------------------------------------------------
     # Change the update method so F12 toggles pause
     #-------------------------------------------------------------------------
     def update(*args)
        # Try to update normally
        begin
           zeriab_f12_pause_update(*args)
           return
        rescue Reset
           # Do nothing
        end
        # F12 has been pressed
        done = false
        # Store frame count
        frame_count = Graphics.frame_count
        # Show pause image
        @sprite = Sprite.new
        @sprite.z = 9999
        begin
           @sprite.bitmap = RPG::Cache.picture('pause')
        rescue
           @sprite.bitmap = Bitmap.new(32,32)
        end
        # Keep trying to do the update
        while !done
           begin
              zeriab_f12_pause_update(*args)
              done = true
           rescue Reset
              # Do Nothing
           end
        end
        # F12 has been released, update until it is pressed again
        while done
           begin
              zeriab_f12_pause_update(*args)
           rescue Reset
              done = false
           end
        end
        # F12 has been pressed, keep trying to update
        while !done
           begin
              zeriab_f12_pause_update(*args)
              done = true
           rescue Reset
              # Do nothing
           end
        end
        # F12 has been released, dispose pause image
        @sprite.dispose
        # Set proper frame count
        Graphics.frame_count = frame_count
     end
     #-------------------------------------------------------------------------
     # Changes the transition so it is cut short if F12 is pressed
     #-------------------------------------------------------------------------
     def transition(*args)
        done = false
        # Keep trying to do the transition
        while !done
           begin
              zeriab_f12_pause_transition(*args)
              done = true
           rescue Reset
              # Set transition length to 0 frames.
              args[0] = 0
           end
        end
     end
  end
end