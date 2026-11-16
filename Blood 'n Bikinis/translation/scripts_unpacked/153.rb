class Game_Shop
  attr_sec_accessor :items, 'Game_Shop_Items.new'
  attr_sec_accessor :weapons, 'Game_Shop_Items.new'
  attr_sec_accessor :armors, 'Game_Shop_Items.new'
  ##
  # Instantiation
  #
  def initialize
    setup
  end
  
  ##
  # Quick access to the amount left
  #
  def [](item)
    case item
    when Game_Item
      return items[item.id]
    when Game_Weapon
      return weapons[item.id]
    when Game_Armor
      return armors[item.id]
    end
  end
  
  ##
  # Quick access to decrementing the amount
  #
  def decrement(item, amount)
    case item
    when Game_Item
      items.decrement_amount(item.id, amount)
    when Game_Weapon
      weapons.decrement_amount(item.id, amount)
    when Game_Armor
      armors.decrement_amount(item.id, amount)
    end
  end
  
  ##
  # Quick access to incrementing the amount
  #
  def increment(item, amount)
    case item
    when Game_Item
      items.increment_amount(item.id, amount)
    when Game_Weapon
      weapons.increment_amount(item.id, amount)
    when Game_Armor
      armors.increment_amount(item.id, amount)
    end
  end
  
  ##
  # Quick access to check if an item is present in the shop
  #
  def present?(item)
    case item
    when Game_Item
      return items.present?(item.id)
    when Game_Weapon
      return weapons.present?(item.id)
    when Game_Armor
      return armors.present?(item.id)
    end
  end
end