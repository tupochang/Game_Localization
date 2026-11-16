class Game_Shop_Items
  ##
  # Instantiation
  #
  def initialize
    @data = {}
  end
  
  ##
  # Returns the amount of items left
  # Returns nil if there is no limit
  #
  def [](item_id)
    return @data[item_id]
  end
  
  ##
  # Increases the number of items left with the specified id
  # with the given amount.
  #
  def increment_amount(item_id, amount)
    return if @data[item_id].nil?
    @data[item_id] += amount
  end
  
  ##
  # Decreases the number of items left with the given id
  # with the given amount
  #
  def decrement_amount(item_id, amount)
    return if @data[item_id].nil?
    @data[item_id] -= amount
  end
  
  ##
  # Sets the amount of items left with the given id.
  # Works with previously unrestricted items as well.
  #
  def []=(item_id, amount)
    @data[item_id] = amount
  end
  
  ##
  # Return true if there is no limit on the given item
  # Return false if there is a limit on the given item
  #
  def no_limit?(item_id)
    return @data[item_id].nil?
  end
  
  ##
  # Return true if there is a limit on the given item
  # Return false if there is no limit on the given item
  #
  def has_limit?(item_id)
    return @data[item_id] != nil
  end
  
  ##
  # Check if the item is present in the shop
  #
  def present?(item_id)
    return !(@data[item_id] != nil && @data[item_id] <= 0)
  end
  
  ##
  # Removes the limit on the item with the given id
  # Return false if no limit were on the given item
  # Return true if the limit was removed 
  #
  def remove_limit(item_id)
    return @data.delete(item_id) != nil
  end
end