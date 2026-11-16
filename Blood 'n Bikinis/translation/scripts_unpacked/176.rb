class Window_Option < Window_Base
  attr_accessor :focus
  attr_reader :command_window
  def initialize(text, current = false)
    super(0,0,System::Options::WIDTH-160,52) #56
    @command_window = Window_Option_Command.new(160, current)
    self.contents = Bitmap.new(System::Options::WIDTH-192, 17)
    self.contents.draw_text(0,0, System::Options::WIDTH-192, 17, text)
    @current_index = current ? 0 : 1
  end
  
  def x=(val)
    super
    unless @command_window.nil?
      @command_window.x += self.x + (System::Options::WIDTH-160)
    end
  end
  def y=(val)
    super
    unless @command_window.nil?
      @command_window.y = val
    end
  end
  def z=(val)
    super
    unless @command_window.nil?
      @command_window.z = val + 1
    end
  end
  def width
    return super + 160
  end
  def dispose
    super
    @command_window.dispose
  end
  
  def update
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.cursor_se)
      toggle 
    elsif Input.trigger?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      @command_window.index = 0
    elsif Input.trigger?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      @command_window.index = 1
    end
    @command_window.update
  end
  def mouse_move(*args)
    unless focus
      owner.fireEvent(MouseEvent.new(self, :take_focus, nil))
      self.focus = true
    end
  end
  def mouse_update
    toggle if Mouse.trigger?(Mouse::LEFT_CLICK)
  end
  
  def toggle
    @command_window.index = (@command_window.index == 1) ? 0 : 1
  end
  
  def changed?
    @current_index != @command_window.index
  end
end
