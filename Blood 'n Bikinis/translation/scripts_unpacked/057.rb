#==============================================================================
# ** Window_ShopStatus
#------------------------------------------------------------------------------
#  This window displays number of items in possession and the actor's equipment
#  on the shop screen.
#==============================================================================

class Window_ShopStatus < Window_Base
  # ---------------------------------------
  def initialize
    super(368, 128, 272, 352)
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = ["Verdana", "Arial"]
    self.contents.font.size = 24
    @item = nil
    @sprite1 = nil
    @sprite2 = nil
    @sprite3 = nil
    @sprite4 = nil
    @walk = [false, false, false, false]
    @count = 0
    refresh
  end
  # ---------------------------------------
  def visible=(value)
    super
    @sprite1.visible = value unless @sprite1.nil?
    @sprite2.visible = value unless @sprite2.nil?
    @sprite3.visible = value unless @sprite3.nil?
    @sprite4.visible = value unless @sprite4.nil?
  end
  # ---------------------------------------
  def refresh
    self.contents.clear
    if @sprite1 != nil
      @sprite1.dispose
      @sprite1 = nil
    end
    if @sprite2 != nil
      @sprite2.dispose
      @sprite2 = nil
    end
    if @sprite3 != nil
      @sprite3.dispose
      @sprite3 = nil
    end
    if @sprite4 != nil
      @sprite4.dispose
      @sprite4 = nil
    end
    self.contents.font.name = "Arial"
    self.contents.font.size = 24
    if @item == nil
      return
    end
    case @item
    when Game_Item
      number = $game_party.item_number(@item.id)
    when Game_Weapon
      number = $game_party.weapon_number(@item.id)
    when Game_Armor
      number = $game_party.armor_number(@item.id)
    end
    self.contents.font.color = system_color
    self.contents.draw_text(4, 0, 200, 32, "    Owned:")
    self.contents.font.color = normal_color
    self.contents.draw_text(204, 0, 32, 32, number.to_s, 2)
    if @item.is_a?(Game_Item)
      @walk = [false, false, false, false]
      return
    end
    for i in 0...$game_party.actors.size
      actor = $game_party.actors[i]
      if @item.is_a?(Game_Weapon)
        item1 = $game_system.weapons[actor.weapon_id]
      elsif @item.kind == 0
        item1 = $game_system.armors[actor.armor1_id]
      elsif @item.kind == 1
        item1 = $game_system.armors[actor.armor2_id]
      elsif @item.kind == 2
        item1 = $game_system.armors[actor.armor3_id]
      else
        item1 = $game_system.armors[actor.armor4_id]
      end
      if not actor.equippable?(@item)
        @walk[i] = false
        draw_actor_graphic(actor, 380, 194 + 64 * i, i, 0)
        self.contents.font.name = "Arial"
        self.contents.font.size = 24
        self.contents.font.color = normal_color
        self.contents.draw_text(32, 54 + 64 * i, 150, 32, "") # Cannot Equip
      end
      if actor.equippable?(@item)
        @walk[i] = true
        draw_actor_graphic(actor, 380, 194 + 64 * i, i, 1)
          atk1 = 0
          atk2 = 0
          eva1 = 0
          eva2 = 0
          str1 = 0
          str2 = 0
          dex1 = 0
          dex2 = 0
          agi1 = 0
          agi2 = 0
          int1 = 0
          int2 = 0
          pdf1 = 0
          pdf2 = 0
          mdf1 = 0
          mdf2 = 0
          eva1 = 0
          eva2 = 0
          str1 = item1 != nil ? item1.str_plus : 0
          str2 = @item != nil ? @item.str_plus : 0
          dex1 = item1 != nil ? item1.dex_plus : 0
          dex2 = @item != nil ? @item.dex_plus : 0
          agi1 = item1 != nil ? item1.agi_plus : 0
          agi2 = @item != nil ? @item.agi_plus : 0
          int1 = item1 != nil ? item1.int_plus : 0
          int2 = @item != nil ? @item.int_plus : 0
          pdf1 = item1 != nil ? item1.pdef : 0
          pdf2 = @item != nil ? @item.pdef : 0
          mdf1 = item1 != nil ? item1.mdef : 0
          mdf2 = @item != nil ? @item.mdef : 0
        if @item.is_a?(Game_Weapon)
          atk1 = item1 != nil ? item1.atk : 0
          atk2 = @item != nil ? @item.atk : 0
        end
        if @item.is_a?(RPG::Armor) || @item.is_a?(Game_Armor)
          eva1 = item1 != nil ? item1.eva : 0
          eva2 = @item != nil ? @item.eva : 0
        end
        str_change = str2 - str1
        dex_change = dex2 - dex1
        agi_change = agi2 - agi1
        int_change = int2 - int1
        pdf_change = pdf2 - pdf1
        mdf_change = mdf2 - mdf1
        atk_change = atk2 - atk1
        eva_change = eva2 - eva1
        if item1 == nil
          name1 = ""
        else
          name1 = item1.name
        end
        if @item == nil
          name2 = ""
        else
          name2 = @item.name
        end
        if str_change == 0 && dex_change == 0 && agi_change == 0 &&
        pdf_change == 0 && mdf_change == 0 && atk_change == 0 &&
        eva_change == 0 && name1 != name2
          self.contents.draw_text(32, 54 + 64 * i, 150, 32, " ") # | EDIT "No Change"
        end
        if name1 == name2
          self.contents.draw_text(32, 54 + 64 * i, 200, 32, "") # Currently Equipped
        end
        self.contents.font.name = "Arial"
        self.contents.font.size = 16
        self.contents.font.color = normal_color
        if @item.is_a?(Game_Weapon) && atk_change != 0
          #self.contents.draw_text(32, 42 + 64 * i, 32, 32, "ATK")
        end
        if (@item.is_a?(RPG::Armor) || @item.is_a?(Game_Armor)) && eva_change != 0
          #self.contents.draw_text(32, 42 + 64 * i, 32, 32, "EVA")
        end
        if pdf_change != 0
          #self.contents.draw_text(32, 58 + 64 * i, 32, 32, "PDF")
        end
        if mdf_change != 0
          #self.contents.draw_text(32, 74 + 64 * i, 32, 32, "MDF")
        end
        if str_change != 0
          #self.contents.draw_text(112, 42 + 64 * i, 32, 32, "STR")
        end
        if dex_change != 0
          #self.contents.draw_text(112, 58 + 64 * i, 32, 32, "RES")
        end
        if agi_change != 0
          #self.contents.draw_text(112, 74 + 64 * i, 32, 32, "SPD")
        end
        if int_change != 0
          #self.contents.draw_text(192, 42 + 64 * i, 32, 32, "MND")
        end
        if @item.is_a?(Game_Weapon) && atk_change > 0
          #self.contents.font.color = up_color
          #s = atk_change.abs.to_s
          #self.contents.draw_text(60, 42 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(62, 42 + 64 * i, 24, 32, s, 2)
        end
        if @item.is_a?(Game_Weapon) && atk_change < 0
          #self.contents.font.color = down_color
          #s = atk_change.abs.to_s
          #self.contents.draw_text(60, 42 + 64 * i, 4, 32, "-")
          #self.contents.draw_text(62, 42 + 64 * i, 24, 32, s, 2)
        end
        if (@item.is_a?(RPG::Armor) || @item.is_a?(Game_Armor)) && eva_change > 0
          #self.contents.font.color = up_color
          #s = eva_change.abs.to_s
          #self.contents.draw_text(60, 42 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(62, 42 + 64 * i, 24, 32, s, 2)
        end
        if (@item.is_a?(RPG::Armor) || @item.is_a?(Game_Armor)) && eva_change < 0
          #self.contents.font.color = down_color
          #s = eva_change.abs.to_s
         # self.contents.draw_text(60, 42 + 64 * i, 4, 32, "-")
          #self.contents.draw_text(62, 42 + 64 * i, 24, 32, s, 2)
        end
        if pdf_change > 0
          #self.contents.font.color = up_color
          #s = pdf_change.abs.to_s
          #self.contents.draw_text(60, 58 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(62, 58 + 64 * i, 24, 32, s, 2)
        end
        if pdf_change < 0
          #self.contents.font.color = down_color
          #s = pdf_change.abs.to_s
          #self.contents.draw_text(60, 58 + 64 * i, 4, 32, "-")
          #self.contents.draw_text(62, 58 + 64 * i, 24, 32, s, 2)
        end
        if mdf_change > 0
          #self.contents.font.color = up_color
          #s = mdf_change.abs.to_s
          #self.contents.draw_text(60, 74 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(62, 74 + 64 * i, 24, 32, s, 2)
        end
        if mdf_change < 0
          #self.contents.font.color = down_color
          #s = mdf_change.abs.to_s
          #self.contents.draw_text(60, 74 + 64 * i, 4, 32, "-")
          #self.contents.draw_text(62, 74 + 64 * i, 24, 32, s, 2)
        end
        if str_change > 0
          #self.contents.font.color = up_color
          #s = str_change.abs.to_s
          #self.contents.draw_text(140, 42 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(142, 42 + 64 * i, 24, 32, s, 2)
        end
        if str_change < 0
          #self.contents.font.color = down_color
          #s = str_change.abs.to_s
          #self.contents.draw_text(140, 42 + 64 * i, 4, 32, "-")
          #self.contents.draw_text(142, 42 + 64 * i, 24, 32, s, 2)
        end
        if dex_change > 0
          #self.contents.font.color = up_color
         # s = dex_change.abs.to_s
          #self.contents.draw_text(140, 58 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(142, 58 + 64 * i, 24, 32, s, 2)
        end
        if dex_change < 0
         # self.contents.font.color = down_color
         # s = dex_change.abs.to_s
         # self.contents.draw_text(140, 58 + 64 * i, 4, 32, "-")
         # self.contents.draw_text(142, 58 + 64 * i, 24, 32, s, 2)
        end
        if agi_change > 0
         # self.contents.font.color = up_color
         # s = agi_change.abs.to_s
          #self.contents.draw_text(140, 74 + 64 * i, 4, 32, "+")
          #self.contents.draw_text(142, 74 + 64 * i, 24, 32, s, 2)
        end
        if agi_change < 0
         # self.contents.font.color = down_color
       #   s = agi_change.abs.to_s
        #  self.contents.draw_text(140, 74 + 64 * i, 4, 32, "-")
        #  self.contents.draw_text(142, 74 + 64 * i, 24, 32, s, 2)
        end
        if int_change > 0
        #  self.contents.font.color = up_color
       #   s = int_change.abs.to_s
        #  self.contents.draw_text(214, 42 + 64 * i, 4, 32, "+")
        #  self.contents.draw_text(216, 42 + 64 * i, 24, 32, s, 2)
        end
        if int_change < 0
        #  self.contents.font.color = down_color
        #  s = int_change.abs.to_s
       #  self.contents.draw_text(214, 42 + 64 * i, 4, 32, "-")
         # self.contents.draw_text(216, 42 + 64 * i, 24, 32, s, 2)
        end
      end
    end
  end
  # ---------------------------------------
  def item=(item)
    if @item != item
      @item = item
      refresh
    end
  end
  # ---------------------------------------
  def draw_actor_graphic(actor, x, y, id, tone_id)
    if id == 0
      bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
      @v1 = Viewport.new(380, 194, [bitmap.width / 4 + 10, 32].min, [bitmap.height / 4, 48].min)
      @v1.z = 9998
      @sprite1 = Sprite.new(@v1)
      @sprite1.bitmap = bitmap
      if tone_id == 0
        @sprite1.tone = Tone.new(0, 0, 0, 255)
      else
        @sprite1.tone = Tone.new(0, 0, 0, 0)
      end
      @sprite1.visible = true
    end
     if id == 1
      bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
      @v2 = Viewport.new(380, 258, [bitmap.width / 4 + 10, 32].min, [bitmap.height / 4, 48].min)
      @v2.z = 9999
      @sprite2 = Sprite.new(@v2)
      @sprite2.bitmap = bitmap
      if tone_id == 0
        @sprite2.tone = Tone.new(0, 0, 0, 255)
      else
        @sprite2.tone = Tone.new(0, 0, 0, 0)
      end
      @sprite2.visible = true
    end
     if id == 2
      bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
      @v3 = Viewport.new(380, 322, [bitmap.width / 4 + 10, 32].min, [bitmap.height / 4, 48].min)
      @v3.z = 9999
      @sprite3 = Sprite.new(@v3)
      @sprite3.bitmap = bitmap
      if tone_id == 0
        @sprite3.tone = Tone.new(0, 0, 0, 255)
      else
        @sprite3.tone = Tone.new(0, 0, 0, 0)
      end
      @sprite3.visible = true
    end
    if id == 3
      bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
      @v4 = Viewport.new(380, 386, [bitmap.width / 4 + 10, 32].min, [bitmap.height / 4, 48].min)
      @v4.z = 9999
      @sprite4 = Sprite.new(@v4)
      @sprite4.bitmap = bitmap
      if tone_id == 0
        @sprite4.tone = Tone.new(0, 0, 0, 255)
      else
        @sprite4.tone = Tone.new(0, 0, 0, 0)
      end
      @sprite4.visible = true
    end
  end
  # ---------------------------------------
  def update
    super
    @count += 1
    for i in 0..@walk.size
        if @walk[i] == false
        case i
          when 0
            if @sprite1 != nil
            @sprite1.ox = get_sprite_ox(@sprite1)
            end
          when 1
            if @sprite2 != nil
            @sprite2.ox = get_sprite_ox(@sprite2)
            end
          when 2
            if @sprite3 != nil
            @sprite3.ox = get_sprite_ox(@sprite3)
            end
          when 3
            if @sprite4 != nil
            @sprite4.ox = get_sprite_ox(@sprite4)
            end
          end
        end
      end
    if @count == 0
      for i in 0..@walk.size
        if @walk[i] == true
        case i
        when 0
          if @sprite1 != nil
          @sprite1.ox = 0
          end
        when 1
          if @sprite2 != nil
          @sprite2.ox = 0
          end
        when 2
          if @sprite3 != nil
          @sprite3.ox = 0
          end
        when 3
          if @sprite4 != nil
          @sprite4.ox = 0
            end
          end
        end
      end
    end
    if @count == 5
      for i in 0..@walk.size
        if @walk[i] == true
        case i
        when 0
          if @sprite1 != nil
          @sprite1.ox = get_sprite_ox(@sprite1, 1)
          end
        when 1
          if @sprite2 != nil
          @sprite2.ox = get_sprite_ox(@sprite2, 1)
          end
        when 2
          if @sprite3 != nil
          @sprite3.ox = get_sprite_ox(@sprite3, 1)
          end
        when 3
          if @sprite4 != nil
          @sprite4.ox = get_sprite_ox(@sprite4, 1)
            end
          end
        end
      end
    end
    if @count == 10
      for i in 0..@walk.size
        if @walk[i] == true
          case i
        when 0
          if @sprite1 != nil
          @sprite1.ox = get_sprite_ox(@sprite1, 2)
          end
        when 1
          if @sprite2 != nil
          @sprite2.ox = get_sprite_ox(@sprite2, 2)
          end
        when 2
          if @sprite3 != nil
          @sprite3.ox = get_sprite_ox(@sprite3, 2)
          end
        when 3
          if @sprite4 != nil
          @sprite4.ox = get_sprite_ox(@sprite4, 2)
            end
          end
        end
      end
    end
    if @count == 15
      @count = 0
    end
  end
  #------------------------
  def get_sprite_ox(sprite, pattern = 0)
    return (sprite.bitmap.width / 4 - 32) / 2 + (sprite.bitmap.width * pattern) / 4
  end
end