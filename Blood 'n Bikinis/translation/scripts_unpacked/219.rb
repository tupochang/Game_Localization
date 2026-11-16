class Window_MultiChoice < Window_Command
  BITMAP = Bitmap.new(32,32)
  def initialize(commands, indices, cancel = nil)
    ms = 0
    for command in commands
      s = BITMAP.text_size(command).width
      ms = s > ms ? s : ms
    end
    
    super(ms+60, commands)
    @indices = indices
    @cancel = cancel
    message_window = $scene.instance_eval('@message_window')
    if message_window.is_a?(Window)
      self.opacity = 160#message_window.opacity
      self.x = message_window.x
      self.y = message_window.y - self.height
      if self.y < 0
        self.height += self.y
        self.y = 0
      end
    end
  end
  
  def done?
    # If cancel
    if Input.trigger?(Input::B)
      if @cancel
        # Play cursor SE
        $game_system.se_play($data_system.cursor_se)
        @index = @cancel
        return true
      else
        # Play buzzer SE
        $game_system.se_play($data_system.buzzer_se)
        return false
      end
    end
    # If ok
    if Input.trigger?(Input::C)
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      return true
    end
  end
end