class Window_StateChange < Window_Base
  attr_accessor :limit
  def initialize(actor)
    super(0, 0, 160, 32)
    self.x = actor.index * 160
    self.visible = false
    self.z = 100
    @actor = actor
    @limit = 480
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
    @state_plus = @actor.state_change_plus.uniq
    @state_minus = @actor.state_change_minus.uniq

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
    
    @wait = System::Battle::ALLY_STATE_WAIT
    count = @state_plus.size + @state_minus.size - 1
    self.height = count * 24 + 64
    @limit = 320 - self.height
    self.y = 160 + @limit + (self.height/64+1)*64
    self.contents = Bitmap.new(self.width - 32, self.height - 32)
    self.contents.font.size = 20
    j = 0
    for state_id in @state_plus
      text = '+' + $data_states[state_id].name
      self.contents.font.color = text_color(3)
      self.contents.draw_text(0, j*24, 128, 32, text)
      j += 1
    end
    for state_id in @state_minus
      text = '-' + $data_states[state_id].name
      self.contents.font.color = text_color(2)
      self.contents.draw_text(0, j*24, 128, 32, text)
      j += 1
    end
  end
  
  def update
    @wait -= 1
    if @wait <= 0
      self.visible = false
    end
  end
end