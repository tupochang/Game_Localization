class Window_StateEnemyChange < Window_Base
  def initialize(enemy)
    super(0, 0, 128, 32)
    self.x = enemy.screen_x
    self.y = enemy.screen_y
    self.visible = false
    self.z = 99
    self.opacity = 0
    @enemy = enemy
    @wait = 0
  end
  
  def retrieve_visible(states)
    visible_states = []
    for state_id in states
      state = $data_states[state_id]
      if state.rating >= System::Battle::VISIBLE_STATE_RATING_MINIMUM
        visible_states << state_id
      end
    end
    visible_states
  end
  
  def hide
    self.visible = false
    @wait = 0
    update
  end
  
  def refresh
    @state_plus = @enemy.state_change_plus.uniq
    @state_minus = @enemy.state_change_minus.uniq
    
    # Ignore states with too low a rating
    @state_plus = retrieve_visible(@state_plus)
    @state_minus = retrieve_visible(@state_minus)

    # Hide window when no visible states
    if (@state_plus.empty? && @state_minus.empty?)
      hide
      return
    end
    
    #intersection = @state_plus & @state_minus
    #@state_plus = @state_plus - intersection
    #@state_minus = @state_minus
    
    @wait = System::Battle::ENEMY_STATE_WAIT
    count = @state_plus.size + @state_minus.size - 1
    self.height = count * 24 + 64
    self.opacity = 0
    self.x = @enemy.screen_x - self.width / 2
    self.y = @enemy.screen_y - self.height * 2
    self.y = 0 if self.y < 0
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    self.contents.font.size = 20
    j = 0
    for state_id in @state_plus
      text = '+' + $data_states[state_id].name
      self.contents.font.color = text_color(3)
      self.contents.draw_text(0, j*24, 96, 32, text)
      j += 1
    end
    for state_id in @state_minus
      text = '-' + $data_states[state_id].name
      self.contents.font.color = text_color(2)
      self.contents.draw_text(0, j*24, 96, 32, text)
      j += 1
    end
  end
  
  def update
    @wait -= 1
    # Fade in
    if System::Battle::ENEMY_STATE_WAIT - @wait <= 10
      self.opacity = 5 + (System::Battle::ENEMY_STATE_WAIT - @wait) * 25
    end
    # Fade out
    if @wait <= 10
      self.opacity = 5 + @wait * 25
    end
    # Disappear
    if @wait <= 0
      self.visible = false
    end
  end
end