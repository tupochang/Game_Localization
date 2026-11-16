module Input
  @update = 10
  class << self
    alias_method(:zer_mouse_input_update,:update)
    def update
      Mouse.update
      zer_mouse_input_update
      @update -= 1
      if @update <= 0
        @update = 20
        @is_full_screen = (IS_FULL_SCREEN.call == 1)
      end
    end
    def is_fullscreen
      @is_full_screen
    end
  end
end