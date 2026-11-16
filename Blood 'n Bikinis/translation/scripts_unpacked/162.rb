class Bitmap
  @@shadow = nil
  @@outline = nil
  @@shadow_transparancy = nil
  
  alias zeriab_shadow_draw_text :draw_text
  def draw_text(r, *args)
    if shadow || outline
      color = font.color.dup
      font.color = Color.new(0,0,0,shadow_transparancy)
      if r.is_a?(Rect)
        x,y,width,height = r.x,r.y,r.width,r.height
        opts = [width, height, *args]
      else
        x,y = r, args[0]
        opts = args[1..-1]
      end
      if outline
        zeriab_shadow_draw_text(x+1,y,*opts)
        zeriab_shadow_draw_text(x-1,y,*opts)
        zeriab_shadow_draw_text(x,y+1,*opts)
        zeriab_shadow_draw_text(x,y-1,*opts)
      end
      if shadow
        zeriab_shadow_draw_text(x+1,y,*opts)
        zeriab_shadow_draw_text(x+1,y+1,*opts)
      end
      font.color = color
    end
    zeriab_shadow_draw_text(r, *args)
  end
  
  def shadow
    if @@shadow.nil?
      value = Utility.read_ini('text_shadow')
      @@shadow = !(value == '0' || value == '')
    end
    @@shadow
  end
  
  def outline
    if @@outline.nil?
      value = Utility.read_ini('text_outline')
      @@outline = !(value == '0' || value == '')
    end
    @@outline
  end
  
  def shadow_transparancy
    if @@shadow_transparancy.nil?
      value = Utility.read_ini('shadow_transparancy')
      if value == ''
        @@shadow_transparancy = System::SHADOW_TRANSPARANCY 
      else
        @@shadow_transparancy = value.to_i
        @@shadow_transparancy = System::SHADOW_TRANSPARANCY unless @@shadow_transparancy.between?(0,255)
      end
    end
    @@shadow_transparancy
  end
end