#==============================================================================
# ** Window_EquipLeft
#------------------------------------------------------------------------------
#  This window displays actor parameter changes on the equipment screen.
#==============================================================================

class Window_EquipLeft < Window_Base
  # --------------------------------
  attr_accessor :mode
  attr_accessor :changes
  # --------------------------------
  def initialize(actor)
    super(0, 64, 272, 416)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = "Arial"
    self.contents.font.size = 24
    self.z += 100
    @actor = actor
    @mode = 0
    @changes = [0, 0, 0, 0, 0, 0, 0, 0]
    @elem_text = ""
    @stat_text = ""
    refresh
  end
  # --------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    self.contents.font.size = 23
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 180, 0)
    draw_actor_parameter(@actor, 4, 64, 0)
    draw_actor_parameter(@actor, 4, 96, 1)
    draw_actor_parameter(@actor, 4, 144, 2)
    draw_actor_parameter(@actor, 4, 176, 3)
    draw_actor_parameter(@actor, 4, 288, 4)
    draw_actor_parameter(@actor, 4, 208, 5)
    draw_actor_parameter(@actor, 4, 256, 6)
    self.contents.font.color = system_color
    #if @mode == 0
    #  self.contents.draw_text(4, 256, 200, 32, "Elemental Attack")
     # self.contents.draw_text(4, 320, 200, 32, "Status Attack")
    #end
    #if @mode == 1
     # self.contents.draw_text(4, 256, 200, 32, "Elemental Defense")
     # self.contents.draw_text(4, 320, 200, 32, "Status Defense")
    #end
    #self.contents.font.color = normal_color
    #self.contents.font.size = System::Menu::EFFECT_FONT_SIZE
    # Elemental effects
    #if @elem_text.is_a?(Array)
     # self.contents.draw_text(12, 283, 230, 20, @elem_text[0])
     # self.contents.draw_text(12, 303, 230, 20, @elem_text[1])
    #end
    # State effects
    #if @stat_text.is_a?(Array)
    #  self.contents.draw_text(12, 347, 230, 20, @stat_text[0])
    #  self.contents.draw_text(12, 367, 230, 20, @stat_text[1])
    #end
    self.contents.font.size = 23
    if @new_atk != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 64, 40, 32, "¨", 1)
      if @changes[0] == 0
        self.contents.font.color = normal_color
      elsif @changes[0] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 64, 36, 32, @new_atk.to_s, 2)
    end
    if @new_pdef != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 96, 40, 32, "¨", 1)
      if @changes[1] == 0
        self.contents.font.color = normal_color
      elsif @changes[1] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 96, 36, 32, @new_pdef.to_s, 2)
    end
    if @new_mdef != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 144, 40, 32, "¨", 1)
      if @changes[2] == 0
        self.contents.font.color = normal_color
      elsif @changes[2] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 144, 36, 32, @new_mdef.to_s, 2)
    end
    if @new_str != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 176, 40, 32, "¨", 1)
      if @changes[3] == 0
        self.contents.font.color = normal_color
      elsif @changes[3] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 176, 36, 32, @new_str.to_s, 2)
    end
     if @new_dex != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 288, 40, 32, "¨", 1)
      if @changes[4] == 0
        self.contents.font.color = normal_color
      elsif @changes[4] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 288, 36, 32, @new_dex.to_s, 2)
    end
      if @new_agi != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 208, 40, 32, "¨", 1)
      if @changes[5] == 0
        self.contents.font.color = normal_color
      elsif @changes[5] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 208, 36, 32, @new_agi.to_s, 2)
    end
      if @new_int != nil
      self.contents.font.color = system_color
      self.contents.draw_text(160, 256, 40, 32, "¨", 1)
      if @changes[6] == 0
        self.contents.font.color = normal_color
      elsif @changes[6] == -1
        self.contents.font.color = down_color
      else
        self.contents.font.color = up_color
      end
      self.contents.draw_text(200, 256, 36, 32, @new_int.to_s, 2)
    end
  end
 # --------------------------------
 def set_new_parameters(new_atk, new_pdef, new_mdef, new_str, new_dex,
    new_agi, new_int, new_eva, elem_text, stat_text)
    flag = false
    if new_atk != @new_atk || new_pdef != @new_pdef || new_mdef != @new_mdef
      flag = true
    end
    if new_str != @new_str || new_dex != @new_dex || new_agi != @new_agi || new_int != @new_int
      flag = true
    end
     if new_eva != @new_eva || elem_text != @elem_text || stat_text != @stat_text
      flag = true
    end
      @new_atk = new_atk
      @new_pdef = new_pdef
      @new_mdef = new_mdef
      @new_str = new_str
      @new_dex = new_dex
      @new_agi = new_agi
      @new_int = new_int
      @new_eva = new_eva
      @elem_text = elem_text
      @stat_text = stat_text
      if flag
        refresh
      end
  end
end