#==============================================================================
# ** Game_Items
#------------------------------------------------------------------------------
#  This class handles armors. It's a wrapper for the built-in class "Array."
#  Refer to "$game_system.items" for the instance of this class.
#==============================================================================

class Game_Items
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    if $data_items.nil?
      @data = []
    else
      @data = Array.new($data_items.size)
    end
  end
  #--------------------------------------------------------------------------
  # * Get Item
  #     item_id : item ID
  #--------------------------------------------------------------------------
  def [](item_id)
    if @data[item_id] != nil
      return @data[item_id]
    else
      if $data_items[item_id] != nil
        @data[item_id] = Game_Item.new($data_items[item_id])
        return @data[item_id]
      end
      return nil
    end
  end
  #--------------------------------------------------------------------------
  # * Set Armor
  #     item_id : item ID
  #     item    : a Game_Item
  #--------------------------------------------------------------------------
  def []=(item_id, item)
    @data[item_id] = item
  end
end
