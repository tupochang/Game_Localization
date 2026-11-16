#------------------------------------------------------------------------
# Show two splashscreens when your game loads
#------------------------------------------------------------------------
class Scene_Splash < Scene_Base
  
  #--------------------------------------------------------------------------
  # ? Initialize the scene
  #--------------------------------------------------------------------------   
  def main
  
    # Load the System database & create a new game  
    $data_system = load_data("Data/System.rxdata")
    $game_system = Game_System.new
    
    # Initialize some transition stuff
    @show = true
    @hide = false
    @n = 0
    @splash_numb = 2
    
    # Define info about each splash screen 
    @sprite1 = Sprite.new
    @sprite1.bitmap = intro1
    @sprite1.opacity = 0
    
    @sprite2 = Sprite.new
    @sprite2.bitmap = intro2
    @sprite2.opacity = 0
    
    # Update graphics and input
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update 
      if $scene != self
        break
      end
    end
    
    # Discard your graphics when you leave this scene 
    Graphics.freeze
    @sprite1.dispose
    @sprite2.dispose
    
    if Utility.read_ini('Mouse') == ''
      Graphics.transition
      $data_system        = load_data("Data/System.rxdata")
      # Make system object
      $game_system = Game_System.new
      val = Dialog_YesNo.show(true, 'Enable mouse control?')
      if val
        Utility.write_ini('Mouse', '1')
        Dialog_OK.show('Mouse has been enabled! You can disable the mouse ' + 
                       "script manually in #{System::INI_FILENAME}")
        Mouse.turn_on
      else
        Utility.write_ini('Mouse', '0')
        Dialog_OK.show('Mouse has been disabled! You can enable the mouse ' +
                       "script manually in #{System::INI_FILENAME}")
      end
    end
    
     
  end
  
  #--------------------------------------------------------------------------
  # ? Update the contents in this scene
  #-------------------------------------------------------------------------- 
  
  def update
   
   # If SPACEBAR is pressed, go to to title screen
   if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK)
     $scene = Scene_Title.new
   end
  
   # Change the opacity of the graphics
   transition 
   
   # Update graphics
   @sprite1.update
   @sprite2.update
   
  end
  
  #--------------------------------------------------------------
  # Transition through splash screens
  #--------------------------------------------------------------  
  def transition
        
    # Fade in a splashscreen
    if @show == true
       @n += 2
       if @n > 255
         @hide = true
         @show = false
         @n = 255
       end
     end
     
    # Fade out a splashscreen and load the next one
    if @hide == true
       @n -= 2
       if @n < 0
         @hide = false
         @show = true
         @splash_numb -= 1
         @n = 0
       end
     end       
    
    # Choose which action to perform in this scene
    case @splash_numb      
      when 0
        $scene = Scene_Title.new
      when 1
        @sprite2.opacity = @n
      when 2
        @sprite1.opacity = @n
    end       
  end 
 
  ##
  # Retrieve the first splash picture
  #
  def intro1
    if FileTest.exist?("Graphics/Pictures/Splash1.png")
      return Bitmap.new("Graphics/Pictures/Splash1.png")
    else
      return Bitmap.new("Graphics/Pictures/Intro-1")
    end
  end
  
  ##
  # Retrieve the second splash picture
  #
  def intro2
    if FileTest.exist?("Graphics/Pictures/Splash2.png")
      return Bitmap.new("Graphics/Pictures/Splash2")
    else
      return Bitmap.new("Graphics/Pictures/Intro-2")
    end
  end
end