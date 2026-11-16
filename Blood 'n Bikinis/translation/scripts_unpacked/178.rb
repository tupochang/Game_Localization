class Windows_Options
  include Mouse_Windows  
  attr_sec_accessor :focus, true
  attr_reader :height
  attr_reader :owner
  attr_sec_reader :x
  attr_sec_reader :y
  attr_sec_reader :width, 'System::Options::WIDTH'
  def initialize
    @fullscreen_window = Window_Option.new(System::Options::TEXT_FULLSCREEN, Input.is_fullscreen)
    @bgm_window = Window_Option.new(System::Options::TEXT_PLAY_BGM, Audio.music?)
    @se_window = Window_Option.new(System::Options::TEXT_PLAY_SE, Audio.sound_effects?)
    mouse_windows << @fullscreen_window
    mouse_windows << @bgm_window
    mouse_windows << @se_window
    @extra_windows = []
    for text, switch_id in System::Options::EXTRA
      window = Window_Option.new(text, $game_switches[switch_id])
      mouse_windows << window
      @extra_windows << window
    end
    @height = 0
    mouse_windows.each {|window| @height += window.height}
    mouse_windows.each {|window| window.owner = self}
    @current_window = @fullscreen_window
    mouse_windows.each {|window| window.command_window.update}
  end
  
  def y=(val)
    @y = val
    cy = val
    for window in @mouse_windows
      window.y = cy
      cy += window.height
    end
  end
  
  def x=(val)
    @x = val
    @mouse_windows.each {|window| window.x = @x}
  end
  
  def z=(val)
    @z = val
    @mouse_windows.each {|window| window.z = @z}
  end
  
  def owner=(object)
    @owner = object
  end
  
  def disposed?
    @disposed == true
  end
  
  def dispose
    @disposed = true
    @mouse_windows.each {|window| window.dispose}
  end
  
  def active
    true
  end
  
  def visible
    true
  end
  
  def apply_effects
    changed = false
    fullscreen = nil # __King__ 2011_04_28
    if @fullscreen_window.changed?
      fullscreen = (IS_FULL_SCREEN.call == 1) ? '0' : '1' # __King__ 2011_04_28
      Utility.toggle_fullscreen
      changed = true
    end
    if @bgm_window.changed?
      Audio.toggle_music
      changed = true
    end
    if @se_window.changed?
      Audio.toggle_sound_effects
      changed = true
    end
    @extra_windows.each_with_index do |window, index|
      if window.changed?
        switch_id = System::Options::EXTRA[index][1]
        $game_switches[switch_id] = !$game_switches[switch_id]
        changed = true
      end
    end
    if changed
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      OptionSetup.save(fullscreen)  # __King__ 2011_04_28
    else
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
    end
  end
  
  def update
    if focus
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        if @current_window == @fullscreen_window
          mouse_windows.each {|window| window.focus = false}
          self.focus = false
          owner.fireEvent(MouseEvent.new(self, :shift_focus, :up))
        else
          index = mouse_windows.index(@current_window)
          @current_window = mouse_windows[index - 1]
        end
      elsif Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        if @current_window == mouse_windows[-1]
          mouse_windows.each {|window| window.focus = false}
          self.focus = false
          owner.fireEvent(MouseEvent.new(self, :shift_focus, :down))
        else
          index = mouse_windows.index(@current_window)
          @current_window = mouse_windows[index + 1]
        end
      else
      @current_window.update      
      end
    end
  end
  
  # Take focus if necessary
  def mouse_move(*args)
    unless focus
      owner.fireEvent(MouseEvent.new(self, :take_focus, nil))
      self.focus = true
    end
  end
  
  def fireEvent(event)
    if event.trigger == :take_focus
      @current_window = event.sender
      mouse_windows.each {|window| window.focus = false unless window == @current_window}
    end
  end
  
  def focus_top
    @current_window = @fullscreen_window
  end
  
  def focus_bottom
    @current_window = mouse_windows[-1]
  end
end