##
# Interpreter commands
#

# Skill
def extra_info_skill_clear(skill_id)
  $game_system.extra_info_set(:skill, skill_id)
end
def extra_info_skill(skill_id, *lines)
  $game_system.extra_info_set(:skill, skill_id, *lines)
end

# Item
def extra_info_item_clear(item_id)
  $game_system.extra_info_set(:item, item_id)
end
def extra_info_item(item_id, *lines)
  $game_system.extra_info_set(:item, item_id, *lines)
end

# Weapon
def extra_info_weapon_clear(weapon_id)
  $game_system.extra_info_set(:weapon, weapon_id)
end
def extra_info_weapon(weapon_id, *lines)
  $game_system.extra_info_set(:weapon, weapon_id, *lines)
end

# Armor
def extra_info_armor_clear(armor_id)
  $game_system.extra_info_set(:armor, armor_id)
end
def extra_info_armor(armor_id, *lines)
  $game_system.extra_info_set(:armor, armor_id, *lines)
end










=begin
Here are some example script calls:

skill_id = 20
extra_info_skill_clear(skill_id)



skill_id = 20
line2 = "And some extra line"
extra_info_skill(skill_id, line2)



skill_id = 20
l2 = "And some extra line"
l3 = "with one more extra line"
extra_info_skill(skill_id, l2, l3)



skill_id = 20
l2 = "And some extra line"
l3 = "with one more extra line"
l4 = "and yet another"
extra_info_skill(skill_id, l2, l3, 
l4)

=end















##
# Store description changes in the save file
#
class Game_System
  attr_sec_accessor :extra_info, 'Hash.new'
  
  ##
  # Find or create a collection that can be used to read and modify the 
  # extra description lines for the given type
  #
  def extra_info_find_or_create(type)
    # Ensure type specific collection exists
    if self.extra_info[type].nil?
      self.extra_info[type] = {}
    end
    type_collection = self.extra_info[type]
    
    # Return a collection of extra description lines
    return type_collection
  end
  
  ##
  # Set the lines of extra description for the given type and identifier.
  # Giving no lines as arguments clears the extra description information
  #
  def extra_info_set(type, type_id, *lines)
    type_extra_info = extra_info_find_or_create(type)
    type_extra_info[type_id] = lines
  end
  
  ##
  # Retrieve extra description lines
  #
  def extra_info_get(type, type_id)
    type_extra_info = extra_info_find_or_create(type)
    type_extra_info[type_id] ||= []
    return type_extra_info[type_id]
  end
end

LinkedWindow = Struct.new(:orig_x, :orig_y, :orig_height, :fixed_height)

class Window_Help < Window_Base
  attr_sec_accessor :details_map, "Hash.new"
  attr_sec_accessor :extra_line_count, 0
  attr_sec_accessor :extra_info, "Array.new"
  attr_sec_accessor :linked_windows, "Array.new"
  
  ##
  # Override to provide support for multiple lines
  #
  def set_text(text, align = 0, extra_info = [])
    @resized ||= false
    # Check if resize is needed
    unless @resized
      resize(System::EXTRA_DESCRIPTION_LINES)
      @resized = true
      self.extra_line_count = extra_info.size
      self.extra_info = extra_info
    end
    # If at least one part of text and alignment differ from last time
    if text != @text || align != @align || self.extra_info != extra_info
      # Redraw text
      self.contents.clear
      self.contents.font.color = normal_color
      self.contents.draw_text(4, 0, self.width - 24, 32, text, align) #BvZ
      @text = text
      @align = align
      @actor = nil
      
      # Draw extra lines
      for i in 0...extra_info.size
        line = extra_info[i]
        # Draw text
        self.contents.font.color = normal_color
        self.contents.draw_text(4, 32 * i + 32, self.width - 24, 32, line, align) #BvZ
      end
    end
    self.visible = true
  end
  
  ##
  # Resize window to fit new line count
  #
  def resize(line_count = 0)
    self.height = line_count * 32 + 64
    self.contents = Bitmap.new(width - 32, height - 32)
    move_linked_windows(line_count)
  end

  def resize_to_standard
    resize(0)
  end
  def resize_to_lines
    unless @text.nil?
      old_visible = self.visible
      set_text(@text, @align, extra_info)
      self.visible = old_visible
    end
  end
  
  ##
  # Move linked windows so they adapt to the changed shape
  #
  def move_linked_windows(line_count)
    for window in linked_windows
      details = details_map[window]
      window.y = details.orig_y + line_count * 32
      unless details.fixed_height
        window.height = details.orig_height - line_count * 32
      end      
    end
  end

  ##
  # Link window to be resized along with the help window
  #
  def link_window(window, fixed_height = false)
    unless linked_windows.include?(window)
      # Store linked window
      linked_windows << window 
      details = LinkedWindow.new(window.x, window.y, window.height, fixed_height)
      details_map[window] = details
      
      # Redraw
      unless @text.nil?
        old_visible = self.visible
        set_text(@text, @align, extra_info)
        self.visible = old_visible
      end
    end
  end
  
  ##
  # Removes a link to a window
  #
  def unlink_window(window)
    linked_windows.delete(window)
    details_map.delete(window)
    
    resize(0) if linked_windows.empty?     
  end
end

def extra_fetch_text(symbol, extra_id, first_line, align = 1) # BvZ
  # Fetch help text
  extra_lines = $game_system.extra_info_get(symbol, extra_id)
  # Flush left
  align = 1
  return [first_line, align, extra_lines]
end


def extra_fetch_baseitem(item)
  first_line = self.item == nil ? "" : self.item.description
  case self.item
  when Game_Item
    return extra_fetch_text(:item, self.item.id, first_line)
  when Game_Weapon
    return extra_fetch_text(:weapon, self.item.id, first_line)
  when Game_Armor
    return extra_fetch_text(:armor, self.item.id, first_line)
  else
    return nil
  end
end

##
# Window integrations
#
class Window_Skill < Window_Selectable_Type_2
  alias_method :zeriab_desc_initialize, :initialize
  def initialize(*args)
    zeriab_desc_initialize(*args)
    if $game_temp.in_battle
      extra_line_adjust(false)
    end
  end
  
  # Override with new logic
  def update_help
    # Fetch help text
    first_line = self.skill == nil ? "" : self.skill.description
    # Flush left
    text_args = extra_fetch_text(:skill, self.skill.id, first_line, 0)
    @help_window.set_text(*text_args)
  end
end


class Window_Item < Window_Selectable_Type_2
  alias_method :zeriab_desc_initialize, :initialize
  def initialize(*args)
    zeriab_desc_initialize(*args)
    if $game_temp.in_battle
      extra_line_adjust(false)
    end
  end
  
  # Override with new logic
  def update_help
    # Fetch help text
    text_args = extra_fetch_baseitem(item)
    # Update text
    @help_window.set_text(*text_args) unless text_args.nil?
  end
end


class Window_EquipRight < Window_Selectable_Type_2
  # Override with new logic
  def update_help
    # Fetch help text
    text_args = extra_fetch_baseitem(item)
    # Update text
    @help_window.set_text(*text_args) unless text_args.nil?
  end
end


class Window_EquipItem < Window_Selectable_Type_2
  # Override with new logic
  def update_help
    # Fetch help text
    text_args = extra_fetch_baseitem(item)
    # Update text
    @help_window.set_text(*text_args) unless text_args.nil?
  end
end

class Window_ShopBuy < Window_Selectable_Type_2
  # Override with new logic
  def update_help
    # Fetch help text
    text_args = extra_fetch_baseitem(item)
    # Update text
    @help_window.set_text(*text_args) unless text_args.nil?
  end
end

class Window_ShopSell < Window_Selectable_Type_2
  # Override with new logic
  def update_help
    # Fetch help text
    text_args = extra_fetch_baseitem(item)
    # Update text
    @help_window.set_text(*text_args) unless text_args.nil?
  end
end


##
# Since integrations
#
class Window_Base < Window
  def initialize(x, y, width, height)
    super()
    @windowskin_name = $game_system.windowskin_name
    self.windowskin = RPG::Cache.windowskin(@windowskin_name)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.z = 100
    
    if $scene.is_a?(Scene_Skill)
      scene_skill_init
    elsif $scene.is_a?(Scene_Item)
      scene_item_init
    elsif $scene.is_a?(Scene_Shop)
      scene_shop_init
    elsif $scene.is_a?(Scene_Equip)
      scene_equip_init
    end
  end
  
  def scene_skill_init
    extra_line_adjust(true) if self.is_a?(Window_SkillStatus)
    extra_line_adjust(false) if self.is_a?(Window_Skill)
  end
  
  def scene_item_init
    extra_line_adjust(false) if self.is_a?(Window_Item)
  end
  
  def scene_shop_init
    extra_line_adjust(true) if self.is_a?(Window_Gold)
    extra_line_adjust(true) if self.is_a?(Window_ShopCommand)
    extra_line_adjust(false) if self.is_a?(Window_ShopBuy)
    extra_line_adjust(false) if self.is_a?(Window_ShopSell)
    extra_line_adjust(false) if self.is_a?(Window_ShopStatus)
  end
  
  def scene_equip_init
    extra_line_adjust(true) if self.is_a?(Window_EquipRight)
    extra_line_adjust(false) if self.is_a?(Window_EquipLeft)
    extra_line_adjust(false) if self.is_a?(Window_EquipItem)
  end
  
  def extra_line_adjust(fixed_height = false)
    self.y += System::EXTRA_DESCRIPTION_LINES * 32
    unless fixed_height
      self.height -= System::EXTRA_DESCRIPTION_LINES * 32
    end    
  end  
end