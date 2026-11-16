class Window_MenuCommand < Window_Command
  ##
  # Draw item overwrite
  #
  def draw_item(index, color)
    self.contents.font.color = color
    icon = System::Menu::INDEX_TO_ICON[index]
    rect = nil
    if icon.nil?
      rect = Rect.new(4, 32 * index, self.contents.width - 8, 32)
    else
      bitmap = RPG::Cache.icon(icon)
      opacity = self.contents.font.color == normal_color ? 255 : 128
      self.contents.blt(x, 32 * index + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)      
      rect = Rect.new(System::Menu::ICON_TEXT_OFFSET, 32 * index, 
                      self.contents.width - 8, 32)
    end
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
  end
  
end
