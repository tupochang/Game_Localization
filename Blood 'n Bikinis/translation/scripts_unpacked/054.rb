#==============================================================================
# ** Window_ShopBuy
#------------------------------------------------------------------------------
#  This window displays buyable goods on the shop screen.
#==============================================================================

class Window_ShopBuy < Window_Selectable_Type_2
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     shop_goods : goods
  #--------------------------------------------------------------------------
  def initialize(shop_goods)
    super(0, 128, 368, 352)
    @shop_goods = shop_goods
    refresh
    self.index = 0
  end
  #--------------------------------------------------------------------------
  # * Item Acquisition
  #--------------------------------------------------------------------------
  def item
    return @data[self.index]
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    if self.contents != nil
      self.contents.dispose
      self.contents = nil
    end
    @data = []
    shop_items = $game_system.shop.items
    shop_weapons = $game_system.shop.weapons
    shop_armors = $game_system.shop.armors
    for goods_item in @shop_goods
      case goods_item[0]
      when 0
        item = $game_system.items[goods_item[1]]
      when 1
        item = $game_system.weapons[goods_item[1]]
      when 2
        item = $game_system.armors[goods_item[1]]
      end
      if item != nil
        if $game_system.shop.present?(item)
          @data.push(item)
        end
      end
    end
    # If item count is not 0, make a bit map and draw all items
    @item_max = @data.size
    if @item_max > 0
      self.contents = Bitmap.new(width - 32, row_max * 32)
      for i in 0...@item_max
        draw_item(i)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Item
  #     index : item number
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    # Get items in possession
    case item
    when Game_Item
      number = $game_party.item_number(item.id)
    when Game_Weapon
      number = $game_party.weapon_number(item.id)
    when Game_Armor
      number = $game_party.armor_number(item.id)
    end
    # If price is less than money in possession, and amount in possession is
    # not 99, then set to normal text color. Otherwise set to disabled color
    text = item.name
    if item.price <= $game_party.gold and number < 99
      if $game_system.shop[item].nil?
        self.contents.font.color = normal_color
      else
        self.contents.font.color = system_color
        text += ' x' + $game_system.shop[item].to_s + '*'
      end
    else
      self.contents.font.color = disabled_color
    end
    x = 4
    y = index * 32
    rect = Rect.new(x, y, self.width - 32, 32)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    bitmap = RPG::Cache.icon(item.icon_name)
    opacity = self.contents.font.color == normal_color ? 255 : 128
    self.contents.blt(x, y + 4, bitmap, Rect.new(0, 0, 24, 24), opacity)
    self.contents.draw_text(x + 28, y, 212, 32, text, 0)
    self.contents.draw_text(x + 240, y, 88, 32, item.price.to_s, 2)
  end
  #--------------------------------------------------------------------------
  # * Help Text Update
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text(self.item == nil ? "" : self.item.description)
  end
end
