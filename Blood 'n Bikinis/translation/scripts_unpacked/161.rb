module Utility
  module_function
  ##
  #
  #
  def autosave
    ss = Scene_Save.new
    ss.save(ss.make_filename(0))
  end
  
  ##
  # Unequip all actors
  #
  def unequip_all
    for actor in $game_actors
      unless actor.nil?
        for i in 0...5
          actor.equip(i,0)
        end
      end
    end
  end

  ##
  # Unequip all disabled_for_party actors
  #
  def unequip_disabled
    for actor in $game_actors
      if actor != nil && actor.disabled_for_party
        for i in 0...5
          actor.equip(i,0)
        end
      end
    end
  end
  
  ##
  # Unequip all disabled_for_party actors
  #
  def unequip_not_available
    for actor in $game_actors
      if actor != nil && actor.not_available
        for i in 0...5
          actor.equip(i,0)
        end
      end
    end
  end
  
  ##
  # Give all party members +n completed quests (for Top_10)
  #
  def give_party_quests(n = 1)
    for actor in $game_party.actors
      actor.quests += 1
    end
  end
  
  ##
  # Get the amount the specified item type left in the shop
  # Return -1 if there are no limit
  # Return 0 if there are none left
  # Return the number of items left otherwise (number > 0)
  #
  def get_item_left(item_id)
    left = $game_system.shop.items[item_id]
    if left.nil?
      return -1
    else
      return left < 0 ? 0 : left
    end
  end
  
  ##
  # Get the amount the specified weapon type left in the shop
  # Return -1 if there are no limit
  # Return 0 if there are none left
  # Return the number of items left otherwise (number > 0)
  #
  def get_weapon_left(weapon_id)
    left = $game_system.shop.weapons[weapon_id]
    if left.nil?
      return -1
    else
      return left < 0 ? 0 : left
    end
  end
  
  ##
  # Get the amount the specified armor type left in the shop
  # Return -1 if there are no limit
  # Return 0 if there are none left
  # Return the number of items left otherwise (number > 0)
  #
  def get_armor_left(armor_id)
    left = $game_system.shop.armors[armor_id]
    if left.nil?
      return -1
    else
      return left < 0 ? 0 : left
    end
  end
  
  ##
  # Increase the amount of items left
  #
  def set_item_left(item_id, amount)
    $game_system.shop.items[item_id] = amount
  end
  ##
  # Increase the amount of items left
  #
  def increase_item_left(item_id, amount)
    $game_system.shop.items.increment_amount(item_id, amount)
  end
  ##
  # Decrease the amount of items left
  #
  def decrease_item_left(item_id, amount)
    return if $game_system.shop.items[item_id].nil?
    $game_system.shop.items.decrement_amount(item_id, amount)
    if $game_system.shop.items[item_id] < 0
      $game_system.shop.items[item_id] = 0
    end
  end
  ##
  # Check whether the given item has a shop limit
  #
  def has_item_limit?(item_id)
    $game_system.shop.items.has_limit?(item_id)
  end
  ##
  # Removes the shop limit from the item
  # Nothing happens if it doesn't have a limit
  #
  def remove_item_limit(item_id)
    $game_system.shop.items.remove_limit(item_id)
  end
  
  ##
  # Increase the amount of weapons left
  #
  def set_weapon_left(weapon_id, amount)
    $game_system.shop.weapons[weapon_id] = amount
  end
  ##
  # Increase the amount of weapons left
  #
  def increase_weapon_left(weapon_id, amount)
    $game_system.shop.weapons.increment_amount(weapon_id, amount)
  end
  ##
  # Decrease the amount of weapons left
  #
  def decrease_weapon_left(weapon_id, amount)
    return if $game_system.shop.weapons[weapon_id].nil?
    $game_system.shop.weapons.decrement_amount(weapon_id, amount)
    if $game_system.shop.weapons[weapon_id] < 0
      $game_system.shop.weapons[weapon_id] = 0
    end
  end
  ##
  # Check whether the given weapon has a shop limit
  #
  def has_weapon_limit?(weapon_id)
    $game_system.shop.weapons.has_limit?(weapon_id)
  end
  ##
  # Removes the shop limit from the weapon
  # Nothing happens if it doesn't have a limit
  #
  def remove_weapon_limit(weapon_id)
    $game_system.shop.weapons.remove_limit(weapon_id)
  end
  
  ##
  # Increase the amount of armors left
  #
  def set_armor_left(armor_id, amount)
    $game_system.shop.armors[armor_id] = amount
  end
  ##
  # Increase the amount of armors left
  #
  def increase_armor_left(armor_id, amount)
    $game_system.shop.armors.increment_amount(armor_id, amount)
  end
  ##
  # Decrease the amount of armors left
  #
  def decrease_armor_left(armor_id, amount)
    return if $game_system.shop.armors[armor_id].nil?
    $game_system.shop.armors.decrement_amount(armor_id, amount)
    if $game_system.shop.armors[armor_id] < 0
      $game_system.shop.armors[armor_id] = 0
    end
  end
  ##
  # Check whether the given armor has a shop limit
  #
  def has_armor_limit?(armor_id)
    $game_system.shop.armors.has_limit?(armor_id)
  end
  ##
  # Removes the shop limit from the armor
  # Nothing happens if it doesn't have a limit
  #
  def remove_armor_limit(armor_id)
    $game_system.shop.armors.remove_limit(armor_id)
  end
  
  ##
  # Run the common event with the given id
  #
  def run_common_event(id, event_id = 0)
    return if $data_common_events[id].nil?
    i = Interpreter.new
    i.setup($data_common_events[id].list, event_id)
    while i.running?
      i.update
    end
  end
  
  #############
  # DLL STUFF #
  #############
  READ_INI         = Win32API.new('kernel32',  'GetPrivateProfileStringA', 
                                  %w(p p p p l p), 'l')
  WRITE_INI        = Win32API.new('kernel32',  'WritePrivateProfileStringA',
                                  %w(p p p p), 'l')
  ##
  # Read from system ini
  #
  def read_ini(key_name, app_name = 'Game', buffer_size = 256, default = '')
    buffer = "\0" * buffer_size
    READ_INI.call(app_name, key_name, default, buffer, buffer_size - 1, 
                  ".\\" + System::INI_FILENAME)
    return buffer.delete("\0")
  end
  
  ##
  # Write to system ini
  #
  def write_ini(key_name, value, app_name = 'Game')
    return WRITE_INI.call(app_name, key_name, value.to_s, ".\\" + System::INI_FILENAME)
  end
  
  def toggle_fullscreen
    $showm.call(18,0,0,0)
    $showm.call(13,0,0,0)
    $showm.call(13,0,2,0)
    $showm.call(18,0,2,0)
  end
end