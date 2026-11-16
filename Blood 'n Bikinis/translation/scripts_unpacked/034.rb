#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This class is for all in-game windows.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     x      : window x-coordinate
  #     y      : window y-coordinate
  #     width  : window width
  #     height : window height
  #--------------------------------------------------------------------------
  attr_accessor :owner
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Dispose if window contents bit map is set
    if self.contents != nil
      self.contents.dispose
    end
    super
  end
  #--------------------------------------------------------------------------
  # * Get Text Color
  #     n : text color number (0-7)
  #--------------------------------------------------------------------------
  def text_color(n)
    case n
    when 0
      return Color.new(255, 255, 255, 255)
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  #--------------------------------------------------------------------------
  # * Get Normal Text Color
  #--------------------------------------------------------------------------
  def normal_color
    return Color.new(255, 255, 255, 255)
  end
  #--------------------------------------------------------------------------
  # * Get Disabled Text Color
  #--------------------------------------------------------------------------
  def disabled_color
    return Color.new(255, 255, 255, 128)
  end
  #--------------------------------------------------------------------------
  # * Get System Text Color
  #--------------------------------------------------------------------------
  def system_color
    return Color.new(192, 224, 255, 255)
  end
  #--------------------------------------------------------------------------
  # * Get Crisis Text Color
  #--------------------------------------------------------------------------
  def crisis_color
    return Color.new(255, 255, 64, 255)
  end
  #--------------------------------------------------------------------------
  # * Get Knockout Text Color
  #--------------------------------------------------------------------------
  def knockout_color
    return Color.new(255, 64, 0)
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    super
    # Reset if windowskin was changed
    if $game_system.windowskin_name != @windowskin_name
      @windowskin_name = $game_system.windowskin_name
      self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Graphic
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_graphic(actor, x, y)
    bitmap = RPG::Cache.character("Faces/" + actor.character_name, actor.character_hue)
    cw = bitmap.width / 4
    ch = bitmap.height / 4
    src_rect = Rect.new(0, 0, cw, ch)
    self.contents.blt(x - cw / 2, y - ch, bitmap, src_rect)
  end
  #--------------------------------------------------------------------------
  # * Draw Name
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_name(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 120, 32, actor.name)
  end
  #--------------------------------------------------------------------------
  # * Draw Class
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_class(actor, x, y)
    self.contents.font.color = normal_color
    self.contents.draw_text(x, y, 250, 32, actor.class_name) #236/32
  end
  #--------------------------------------------------------------------------
  # * Draw Level
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_level(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, "Lv")
    self.contents.font.color = normal_color
    self.contents.draw_text(x+16, y, 24, 32, actor.level.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Make State Text String for Drawing
  #     actor       : actor
  #     width       : draw spot width
  #     need_normal : Whether or not [normal] is needed (true / false)
  #--------------------------------------------------------------------------
   def make_battler_state_text(battler, width, need_normal)
    # Get width of brackets
    brackets_width = self.contents.text_size("").width
    # Make text string for state names
    text = ""
    counter = 0
    for i in battler.states.sort.sort {|x, y| r = $data_states[y].rating <=> $data_states[x].rating; r == 0 ? x <=> y : r}
      if $data_states[i].rating >= 1
        counter = counter + 1
          if counter >= 5
        text = text + '/...'
        break
          else
        if text == ""
        text = $data_states[i].name
        else
        text = text + "/" + $data_states[i].name
        end
          end
      end
     end 
    # If text string for state names is empty, make it [normal]
    if text == ""
      if need_normal
        text = "OK"
      end
    else
      # Attach brackets
      text = text
    end
    # Return completed text string
    return text
  end
  
  def make_battler_state_text_monster(battler, width, need_normal)
    # Get width of brackets
    brackets_width = self.contents.text_size("").width
    # Make text string for state names
    text = ""
    counter = 0
    for i in battler.states.sort.sort {|x, y| r = $data_states[y].rating <=> $data_states[x].rating; r == 0 ? x <=> y : r}
      if $data_states[i].rating >= 5
        if text == ""
        text = $data_states[i].name
        else
        text = text + "/" + $data_states[i].name
        end
          end
      end
    # If text string for state names is empty, make it [normal]
    if text == ""
      if need_normal
        text = "OK"
      end
    else
      # Attach brackets
      text = text
    end
    # Return completed text string
    return text
  end
  
  #--------------------------------------------------------------------------
  # * Draw State
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_state(actor, x, y, width = 240)
    text = make_battler_state_text(actor, width, true)
    self.contents.font.color = actor.hp == 0 ? knockout_color : normal_color
    self.contents.draw_text(x, y, width, 32, text)
  end
  #--------------------------------------------------------------------------
  # * Draw EXP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_actor_exp(actor, x, y)
    self.contents.font.color = system_color
    self.contents.draw_text(x+32, y, 24, 32, "EXP")
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 24, y, 84, 32, actor.exp_s, 2)
    self.contents.draw_text(x + 108, y, 12, 32, "/", 1)
    self.contents.draw_text(x + 120, y, 84, 32, actor.next_exp_s)
  end
  #--------------------------------------------------------------------------
  # * Draw HP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_hp(actor, x, y, width = 144)
    # Draw "HP" text string
    self.contents.font.color = text_color(5) #system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.hp)
    # Calculate if there is draw space for MaxHP
    if width - 32 >= 108
      hp_x = x + width - 128 # original value 108
      flag = true
    elsif width - 32 >= 48
      hp_x = x + width - 128 # original value: 48
      flag = false
    end
    # Draw HP
    self.contents.font.color = actor.hp == 0 ? knockout_color :
      actor.hp <= actor.maxhp / 4 ? crisis_color : normal_color
    self.contents.draw_text(hp_x, y, 48, 32, actor.hp.to_s, 2)
    # Draw MaxHP
    if flag
      self.contents.font.color = text_color(3) #normal_color
      self.contents.draw_text(hp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(hp_x + 60, y, 48, 32, actor.maxhp.to_s)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw SP
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     width : draw spot width
  #--------------------------------------------------------------------------
  def draw_actor_sp(actor, x, y, width = 144)
    # Draw "SP" text string
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 32, 32, $data_system.words.sp)
    # Calculate if there is draw space for MaxHP
    if width - 32 >= 108
      sp_x = x + width - 128
      flag = true
    elsif width - 32 >= 48
      sp_x = x + width - 128
      flag = false
    end
    # Draw SP
    self.contents.font.color = actor.sp == 0 ? knockout_color :
      actor.sp <= actor.maxsp / 4 ? crisis_color : normal_color
    self.contents.draw_text(sp_x, y, 48, 32, actor.sp.to_s, 2)
    # Draw MaxSP
    if flag
      self.contents.font.color = text_color(3) #normal_color
      self.contents.draw_text(sp_x + 48, y, 12, 32, "/", 1)
      self.contents.draw_text(sp_x + 60, y, 48, 32, actor.maxsp.to_s)
    end
  end
  #-------------------------------------------------------------------------- 
  # * Draw Face 
  #     actor : actor 
  #     x     : draw spot x-coordinate 
  #     y     : draw spot y-coordinate 
  #-------------------------------------------------------------------------- 
  def draw_actor_face(actor, x, y) 
    bitmap = RPG::Cache.character("Faces/" + actor.character_name, actor.character_hue) 
    src_rect = Rect.new(0, 0,160,112) #96 instead of 128
    self.contents.blt(x - 96 / 2, y - 102, bitmap, src_rect) 
  end 
  #--------------------------------------------------------------------------
  # * Draw Parameter
  #     actor : actor
  #     x     : draw spot x-coordinate
  #     y     : draw spot y-coordinate
  #     type  : parameter type (0-6)
  #--------------------------------------------------------------------------
  def draw_actor_parameter(actor, x, y, type)
    case type
    when 0
      parameter_name = $data_system.words.atk
      parameter_value = actor.atk
    when 1
      parameter_name = $data_system.words.pdef
      parameter_value = actor.pdef
    when 2
      parameter_name = $data_system.words.mdef
      parameter_value = actor.mdef
    when 3
      parameter_name = $data_system.words.str
      parameter_value = actor.str
    when 4
      parameter_name = $data_system.words.dex
      parameter_value = actor.dex
    when 5
      parameter_name = $data_system.words.agi
      parameter_value = actor.agi
    when 6
      parameter_name = $data_system.words.int
      parameter_value = actor.int
    end
    self.contents.font.color = system_color
    self.contents.draw_text(x, y, 120, 32, parameter_name)
    self.contents.font.color = normal_color
    self.contents.draw_text(x + 120, y, 36, 32, parameter_value.to_s, 2)
  end
    # --------------------------------
  def up_color
    return Color.new(74, 210, 74)
  end
  # --------------------------------
  def down_color
    return Color.new(170, 170, 170)
  end
  #--------------------------------------------------------------------------
  # * Draw Item Name
  #     item : item
  #     x    : draw spot x-coordinate
  #     y    : draw spot y-coordinate
  #--------------------------------------------------------------------------
  def draw_item_name(item, x, y, color_curse = false)
    if item == nil
      return
    end
    bitmap = RPG::Cache.icon(item.icon_name)
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24))
    if color_curse && item.cursed
      self.contents.font.color = disabled_color
    else
      self.contents.font.color = normal_color
    end
    self.contents.draw_text(x + 28, y, 212, 32, item.name)
  end
  
  ##
  # Update mouse position
  # Mouse enabled subclasses should overwrite this method
  #
  def mouse_move(mx, my)
    return unless $DEBUG
    raise StandardError.new("mouse_move(mx, my) was not overwritten in #{self.class}")
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  # Note: The mouse is over the window
  #
  def mouse_update
    return unless $DEBUG
    raise StandardError.new("mouse_update was not overwritten in #{self.class}")
  end
  
  ##
  # Check if the mouse is over the contents, i.e. not over the window border
  #
  def over_contents?(mx, my)
    return mx >= 16 && mx < width - 16 && 
           my >= 16 && my < height - 16
  end
end
