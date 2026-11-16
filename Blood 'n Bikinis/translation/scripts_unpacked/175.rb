class Window_Accept < Window_Horizontal_Command
  attr_accessor :focus
  def initialize
    super(System::Options::WIDTH, ['ACCEPT', 'CANCEL'])
  end
  def update
    if focus
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        self.focus = false
        owner.fireEvent(MouseEvent.new(self, :shift_focus, :up))
      elsif Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        self.focus = false
        owner.fireEvent(MouseEvent.new(self, :shift_focus, :down))
      else
        super
      end
    end
  end
  def mouse_move(*args)
    unless focus
      owner.fireEvent(MouseEvent.new(self, :take_focus, nil))
      self.focus = true
    end
    super
  end
end
