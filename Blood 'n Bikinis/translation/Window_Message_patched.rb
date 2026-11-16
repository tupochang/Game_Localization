# ----------------------------
class Window_Message < Window_Selectable_Type_2
  attr_accessor :autoclosetime
  attr_accessor :op
  attr_accessor :face_window
# ----------------------------
  def initialize
    super(150, 304, 480, 160)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.visible = false
    self.z = 9998
    @mx = @my = -1
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    @autoclosetime = -1
    @op = 255
    @refreshflag = false
    self.active = false
    self.index = -1
    @face_window = Window_Base.new(10, 304, 140, 160)
    @face_window.contents = Bitmap.new(140 - 32, 140 - 32)
    @face_window.visible = false
    @face_window.z = self.z
  end
# ----------------------------
  def dispose
    terminate_message
    $game_temp.message_window_showing = false
    if @input_number_window != nil
      @input_number_window.dispose
    end
    @face_window.dispose
    super
  end
# ----------------------------
  def terminate_message
    self.active = false
    self.pause = false
    self.index = -1
    self.contents.clear
    @contents_showing = false
    if $game_temp.message_proc != nil
      $game_temp.message_proc.call
    end
    $game_temp.message_text = nil
    $game_temp.message_proc = nil
    $game_temp.choice_start = 99
    $game_temp.choice_max = 0
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_proc = nil
    $game_temp.num_input_start = 99
    $game_temp.num_input_variable_id = 0
    $game_temp.num_input_digits_max = 0
    if @gold_window != nil
      @gold_window.dispose
      @gold_window = nil
    end
    @face_window.contents.clear
#    $game_temp.message_actor_id = 0   ##
  end
# ----------------------------
  def opacity=(val)
    super
    @face_window.opacity = val
  end
  def back_opacity=(val)
    super
    @face_window.back_opacity = val
  end
  def contents_opacity=(val)
    super
    @face_window.contents_opacity = val
  end
  def visible=(val)
    super
    unless @face_window.nil?
      @face_window.visible = val
    end
  end
  def y=(val)
    super
    unless @face_window.nil?
      @face_window.y = val
    end
  end
# ----------------------------
  def check_faceset
    actor_id = $game_temp.message_actor_id
    if actor_id.nil? || actor_id < 1
      face_window.contents.clear
    else
      face_window.draw_actor_face($game_actors[actor_id], 54, 101) 
    end
  end
# ----------------------------
   def refresh
    @face_window.update
    check_faceset
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.name = ["Microsoft JhengHei", "Arial", "Verdana"]
    self.contents.font.size = 25
    x = y = 0
    @cursor_width = 0
    @autoclosetime = -1
    @refreshflag = true
    lineheight = 32
    active = ""
    a = ""
    centerflag = false
    rightflag = false
    bannerflag = false
    if $game_temp.choice_start == 0
      x = 8
    end
    if $game_temp.message_text != nil
      text = $game_temp.message_text
      begin
        last_text = text.clone
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
      end until text == last_text
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      text.gsub!(/\\\\/) { "\000" }
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      text.gsub!(/\\[Gg]/) { "\002" }
      text.gsub!(/\\[Ii]\[([0-9]+)\]/) { "\003[#{$1}]" }
      text.gsub!(/\\[Ff]\[([0-9]+)\]/) { "\004[#{$1}]" }
      text.gsub!(/\\[Aa]\[([0-9]+)\]/) { "\005[#{$1}]" }
      text.gsub!(/\\[Xx]/) { "\006" }
      text.gsub!(/\\[Rr]/) { "\007" }
      text.gsub!(/\\[Dd]/) { "\011" }
      text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\023[#{$1}]" }
      text.gsub!(/\\[Bb]/) { "\017" }
      text.gsub!(/\\[Ww]\[([0-9]+)\]/) { "\014[#{$1}]" }
      text.gsub!(/\\[Mm]\[([0-9]+)\]/) { "\015[#{$1}]" }
      text.gsub!(/\\[Oo]\[([0-9]+)\]/) { "\016[#{$1}]" }
      text.gsub!(/\\[Jj]\[([0-9]+)\]/) { "\013[#{$1}]" }
      text.gsub!(/\\[Hh]\[([0-9]+)\]/) { "\021[#{$1}]" }
      text.gsub!(/\\[Kk]\[([0-9]+)\]/) { "\022[#{$1}]" }
      while ((c = text.slice!(/./m)) != nil)
        if c.size == 1
          lead = c[0]
          extra = lead >= 0xF0 && lead <= 0xF7 ? 3 :
                  lead >= 0xE0 && lead <= 0xEF ? 2 :
                  lead >= 0xC0 && lead <= 0xDF ? 1 : 0
          extra.times { c << text.slice!(/./m) if text.size > 0 }
        end
        if c == "\000"
          c = "\\"
        end
        if c == "\001"
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          next
        end
        if c == "\002"
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = self.opacity
            @gold_window.back_opacity = self.back_opacity
          end
          next
        end
          if c == "\003"
          text.sub!(/\[([0-9]+)\]/, "")
          item_sub = $1.to_i
          c = $game_system.items[item_sub].name
          l = self.contents.text_size(c).width
          draw_item_name($game_system.items[item_sub], x, y * 32 + 1)
          x = x + l + 24
          next
        end
        if c == "\004"
          text.sub!(/\[([0-9]+)\]/, "")
          fontize = $1.to_i
          case fontize
            when 1 
              self.contents.font.name = "Arial"
            when 2 
              self.contents.font.name = ["Arial"]
            when 3 
              self.contents.font.name = ["Arial"]
            when 4 
              self.contents.font.name = ["Arial"]
          end
          next
        end
        if c == "\005"
          text.sub!(/\[([0-9]+)\]/, "")
          @autoclosetime = $1.to_i
          next
        end
        if c == "\006"
          centerflag = true
          next
        end
        if c == "\007"
          rightflag = true
          next
        end
        if c == "\011"
          self.contents.font.name = "Arial"
          self.contents.font.size = 18
          self.contents.font.color = normal_color
          lineheight = 32
          next
        end
        if c == "\014"
          text.sub!(/\[([0-9]+)\]/, "")
          w_sub = $1.to_i
          c = $game_system.weapons[w_sub].name
          l = self.contents.text_size(c).width
          bitmap = RPG::Cache.icon($game_system.weapons[w_sub].icon_name)
          self.contents.blt(x+4, y * 32+ 4, bitmap, Rect.new(0, 0, 24, 24))
          x += 28
          self.contents.draw_text(x+4, 32 * y, l+32, lineheight, c)
          x = x + l
          next
        end
        if c == "\015"
          text.sub!(/\[([0-9]+)\]/, "")
          a_sub = $1.to_i
          c = $game_system.armors[a_sub].name
          l = self.contents.text_size(c).width
          bitmap = RPG::Cache.icon($game_system.armors[a_sub].icon_name)
          self.contents.blt(x+4, y * 32+ 4, bitmap, Rect.new(0, 0, 24, 24))
          x += 28
          self.contents.draw_text(x+4, 32 * y, l+32, lineheight, c)
          x = x + l
          next
        end
          if c == "\016"
          text.sub!(/\[([0-9]+)\]/, "")
          @op = $1.to_i
          next
        end
        if c == "\017"
          bannerflag = true
          next
        end
        if c == "\018"
          text.sub!(/\[([0-9]+)\]/, "")
          jump = $1.to_i	
          x += jump
          next
        end
          if c == "\021"
          text.sub!(/\[([0-9]+)\]/, "")
          lineheight = $1.to_i
          next
        end
        if c == "\022"
          text.sub!(/\[([0-9]+)\]/, "")
          skill_sub = $1.to_i
          c = $game_system.skills[skill_sub].name
          l = self.contents.text_size(c).width
          bitmap = RPG::Cache.icon($game_system.skills[skill_sub].icon_name)
          self.contents.blt(x+4, y * 32+ 4, bitmap, Rect.new(0, 0, 24, 24))
          x += 28
          self.contents.draw_text(x+4, 32 * y, l+32, lineheight, c)
          x = x + l
          next
        end
        if c == "\023"
          text.sub!(/\[([0-9]+)\]/, "")
          bigness = $1.to_i
          self.contents.font.size = bigness
          next
        end
        if c == "\n"
          if centerflag == true
            x = 448 - x
            x = x / 2
            self.contents.draw_text(x, 32 * y, 448-x, lineheight, a)
          end
          if rightflag == true
            x = 448 - x
            self.contents.draw_text(x, 32 * y, 448-x, lineheight, a)
          end
          if bannerflag == true
            x = 448 - x
            x = x / 2
            self.contents.draw_text(x, 44, 448-x, lineheight, a)
          end
          a = ""
          centerflag = false
          rightflag = false
          bannerflag = false
          if y >= $game_temp.choice_start
            @cursor_width = [@cursor_width, x].max
          end
          y += 1
          x = 0
          if y >= $game_temp.choice_start
            x = 8
          end
          next
        end
        if centerflag == false && rightflag == false && bannerflag == false
        self.contents.draw_text(4 + x, 32 * y, 40, lineheight, c)
        x += self.contents.text_size(c).width
      else
        a += c
        x += self.contents.text_size(c).width
        end
      end
    end
    if $game_temp.choice_max > 0
      @item_max = $game_temp.choice_max
      self.active = true
      self.index = 0
    end
    if $game_temp.num_input_variable_id > 0
      digits_max = $game_temp.num_input_digits_max
      number = $game_variables[$game_temp.num_input_variable_id]
      @input_number_window = Window_InputNumber.new(digits_max)
      @input_number_window.number = number
      @input_number_window.x = self.x + 8
      @input_number_window.y = self.y + $game_temp.num_input_start * 32
    end
  end
# ----------------------------
  def reset_window
    if $game_temp.in_battle
      self.y = 16
    else
      case $game_system.message_position
      when 0
        self.y = 16
      when 1
        self.y = 160
      when 2
        self.y = 304
      end
    end
    if $game_system.message_frame == 0
      self.opacity = 255
    else
      self.opacity = 0
    end
    self.back_opacity = 242
  end
# ----------------------------  
  def update
    super
    if @refreshflag && @fade_in == false
      self.contents_opacity = @op
     end
    if @autoclosetime == 0
    @autoclosetime = -1
     terminate_message
   end
    if @autoclosetime >= 1
    @autoclosetime -= 1
    end
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity >= @op
        @fade_in = false
      end
      return
    end
    if @input_number_window != nil
      @input_number_window.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] =
          @input_number_window.number
        $game_map.need_refresh = true
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    if @contents_showing
      if $game_temp.choice_max == 0
        self.pause = true
      end
      if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
        if $game_temp.choice_max > 0 and $game_temp.choice_cancel_type > 0
          $game_system.se_play($data_system.cancel_se)
          $game_temp.choice_proc.call($game_temp.choice_cancel_type - 1)
          terminate_message
        end
      end
      if normal_trigger?
        if $game_temp.choice_max > 0
          $game_system.se_play($data_system.decision_se)
          $game_temp.choice_proc.call(self.index)
        end
        @op = 255
        terminate_message
      end
      return
    end
    if @fade_out == false and $game_temp.message_text != nil
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      refresh
      Graphics.frame_reset
      self.visible = true
      self.contents_opacity = 0
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    if self.visible
      @fade_out = true
      self.opacity -= 48
      if self.opacity == 0
        self.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      return
    end
  end
# ----------------------------
  def update_cursor_rect
    if @index >= 0
      n = $game_temp.choice_start + @index
      self.cursor_rect.set(8, n * 32, @cursor_width, 32)
    else
      self.cursor_rect.empty
    end
  end
  
  ##
  # Check for normal trigger
  #
  def normal_trigger?
    return true if Input.trigger?(Input::C)
    if Mouse.trigger?(Mouse::LEFT_CLICK)
      return true if $game_temp.choice_max <= 0
      index = calculate_index(@mx - 16, @my - 16)
      return true if index >= 0 && index < @item_max
    end
  end
  
  ##
  # Update mouse (Only called if mouse is enabled)
  #
  def mouse_update
    # Do nothing
  end
  
  ##
  # Calculates the index from the x and y coordinate
  # Assumes (0,0) to be upper-left corner of the contents
  #
  def calculate_index(x, y)
    return -1 if x > @cursor_width + 8
    ey = (y - $game_temp.choice_start * 32) / element_height
    return (ey + top_row) * @column_max
  end
end