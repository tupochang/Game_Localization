#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles the actor. It's used within the Game_Actors class
#  ($game_actors) and refers to the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_reader   :name                     # name
  attr_reader   :character_name           # character file name
  attr_reader   :character_hue            # character hue
  attr_reader   :class_id                 # class ID
  attr_reader   :weapon_id                # weapon ID
  attr_reader   :armor1_id                # shield ID
  attr_reader   :armor2_id                # helmet ID
  attr_reader   :armor3_id                # body armor ID
  attr_reader   :armor4_id                # accessory ID
  attr_reader   :level                    # level
  attr_reader   :exp                      # EXP
  attr_reader   :skills                   # skills
  attr_sec_accessor :fights, 0            ## fights
  attr_sec_accessor :quests, 0            ## quests
  attr_sec_accessor :prevent_death_skill, '$data_actors[@actor_id].prevent_death_skill'
  attr_sec_accessor :defense_divider, '$data_actors[@actor_id].defense_divider'
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def initialize(actor_id)
    super()
    setup(actor_id)
  end
  #--------------------------------------------------------------------------
  # * Setup
  #     actor_id : actor ID
  #--------------------------------------------------------------------------
  def setup(actor_id)
    actor = $data_actors[actor_id]
    @actor_id = actor_id
    @name = actor.name
    @character_name = actor.character_name
    @character_hue = actor.character_hue
    @battler_name = actor.battler_name
    @battler_hue = actor.battler_hue
    @class_id = actor.class_id
    @weapon_id = actor.weapon_id
    @armor1_id = actor.armor1_id
    @armor2_id = actor.armor2_id
    @armor3_id = actor.armor3_id
    @armor4_id = actor.armor4_id
    @level = actor.initial_level
    @exp_list = Array.new(101)
    make_exp_list
    @exp = @exp_list[@level]
    @skills = []
    @hp = maxhp
    @sp = maxsp
    @states = []
    @states_turn = {}
    @maxhp_plus = 0
    @maxsp_plus = 0
    @str_plus = 0
    @dex_plus = 0
    @agi_plus = 0
    @int_plus = 0
    # Learn skill
    for i in 1..@level
      for j in $data_classes[@class_id].learnings
        if j.level == i
          learn_skill(j.skill_id)
        end
      end
    end
    # Update auto state
    update_auto_state(nil, $game_system.weapons[@armor1_id])
    update_auto_state(nil, $game_system.armors[@armor1_id])
    update_auto_state(nil, $game_system.armors[@armor2_id])
    update_auto_state(nil, $game_system.armors[@armor3_id])
    update_auto_state(nil, $game_system.armors[@armor4_id])
  end
  #--------------------------------------------------------------------------
  # * Get Actor ID
  #--------------------------------------------------------------------------
  def id
    return @actor_id
  end
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------
  def index
    return $game_party.actors.index(self)
  end
  #--------------------------------------------------------------------------
  # * Calculate EXP
  #--------------------------------------------------------------------------
  def make_exp_list
    actor = $data_actors[@actor_id]
    @exp_list[1] = 0
    pow_i = 2.4 + actor.exp_inflation / 100.0
    for i in 2..100
      if i > actor.final_level
        @exp_list[i] = 0
      else
        n = actor.exp_basis * ((i + 3) ** pow_i) / (5 ** pow_i)
        @exp_list[i] = @exp_list[i-1] + Integer(n)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Get Element Revision Value
  #     element_id : element ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # Get values corresponding to element effectiveness
    table = [0,300,200,100,50,0,-100]
    result = table[$data_classes[@class_id].element_ranks[element_id]]
    # If this element is protected by armor, then it's reduced by half
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $game_system.armors[i]
      if armor != nil and armor.guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # If this element is protected by states, then it's reduced by half
    for i in @states
      if $data_states[i].guard_element_set.include?(element_id)
        result /= 2
      end
    end
    # End Method
    return result
  end
  #--------------------------------------------------------------------------
  # * Get State Effectiveness
  #--------------------------------------------------------------------------
  def state_ranks
    return $data_classes[@class_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # * Determine State Guard
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    for i in [@armor1_id, @armor2_id, @armor3_id, @armor4_id]
      armor = $game_system.armors[i]
      if armor != nil
        if armor.guard_state_set.include?(state_id)
          return true
        end
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.element_set : []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.plus_state_set : []
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.minus_state_set : []
  end
  #--------------------------------------------------------------------------
  # * Get Maximum HP
  #--------------------------------------------------------------------------
  def maxhp
    n = [[base_maxhp + @maxhp_plus, 1].max, 9999].min
    for i in @states
      n *= $data_states[i].maxhp_rate / 100.0
    end
    n = [[Integer(n), 1].max, 9999].min
    return n
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_actors[@actor_id].parameters[0, @level]
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum SP
  #--------------------------------------------------------------------------
  def base_maxsp
    return $data_actors[@actor_id].parameters[1, @level]
  end
  #--------------------------------------------------------------------------
  # * Get Basic Strength
  #--------------------------------------------------------------------------
  def base_str
    n = $data_actors[@actor_id].parameters[2, @level]
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    n += weapon != nil ? weapon.str_plus : 0
    n += armor1 != nil ? armor1.str_plus : 0
    n += armor2 != nil ? armor2.str_plus : 0
    n += armor3 != nil ? armor3.str_plus : 0
    n += armor4 != nil ? armor4.str_plus : 0
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # * Get Basic Dexterity
  #--------------------------------------------------------------------------
  def base_dex
    n = $data_actors[@actor_id].parameters[3, @level]
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    n += weapon != nil ? weapon.dex_plus : 0
    n += armor1 != nil ? armor1.dex_plus : 0
    n += armor2 != nil ? armor2.dex_plus : 0
    n += armor3 != nil ? armor3.dex_plus : 0
    n += armor4 != nil ? armor4.dex_plus : 0
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    n = $data_actors[@actor_id].parameters[4, @level]
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    n += weapon != nil ? weapon.agi_plus : 0
    n += armor1 != nil ? armor1.agi_plus : 0
    n += armor2 != nil ? armor2.agi_plus : 0
    n += armor3 != nil ? armor3.agi_plus : 0
    n += armor4 != nil ? armor4.agi_plus : 0
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # * Get Basic Intelligence
  #--------------------------------------------------------------------------
  def base_int
    n = $data_actors[@actor_id].parameters[5, @level]
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    n += weapon != nil ? weapon.int_plus : 0
    n += armor1 != nil ? armor1.int_plus : 0
    n += armor2 != nil ? armor2.int_plus : 0
    n += armor3 != nil ? armor3.int_plus : 0
    n += armor4 != nil ? armor4.int_plus : 0
    return [n, 1].max
  end
  #--------------------------------------------------------------------------
  # * Get Basic Attack Power
  #--------------------------------------------------------------------------
  def base_atk
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.atk : 0
  end
  #--------------------------------------------------------------------------
  # * Get Basic Physical Defense
  #--------------------------------------------------------------------------
  def base_pdef
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    pdef1 = weapon != nil ? weapon.pdef : 0
    pdef2 = armor1 != nil ? armor1.pdef : 0
    pdef3 = armor2 != nil ? armor2.pdef : 0
    pdef4 = armor3 != nil ? armor3.pdef : 0
    pdef5 = armor4 != nil ? armor4.pdef : 0
    return pdef1 + pdef2 + pdef3 + pdef4 + pdef5
  end
  #--------------------------------------------------------------------------
  # * Get Basic Magic Defense
  #--------------------------------------------------------------------------
  def base_mdef
    weapon = $game_system.weapons[@weapon_id]
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    mdef1 = weapon != nil ? weapon.mdef : 0
    mdef2 = armor1 != nil ? armor1.mdef : 0
    mdef3 = armor2 != nil ? armor2.mdef : 0
    mdef4 = armor3 != nil ? armor3.mdef : 0
    mdef5 = armor4 != nil ? armor4.mdef : 0
    return mdef1 + mdef2 + mdef3 + mdef4 + mdef5
  end
  #--------------------------------------------------------------------------
  # * Get Basic Evasion Correction
  #--------------------------------------------------------------------------
  def base_eva
    armor1 = $game_system.armors[@armor1_id]
    armor2 = $game_system.armors[@armor2_id]
    armor3 = $game_system.armors[@armor3_id]
    armor4 = $game_system.armors[@armor4_id]
    eva1 = armor1 != nil ? armor1.eva : 0
    eva2 = armor2 != nil ? armor2.eva : 0
    eva3 = armor3 != nil ? armor3.eva : 0
    eva4 = armor4 != nil ? armor4.eva : 0
    return eva1 + eva2 + eva3 + eva4
  end
  #--------------------------------------------------------------------------
  # * Get Offensive Animation ID for Normal Attacks
  #--------------------------------------------------------------------------
  def animation1_id
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.animation1_id : 0
  end
  #--------------------------------------------------------------------------
  # * Get Target Animation ID for Normal Attacks
  #--------------------------------------------------------------------------
  def animation2_id
    weapon = $game_system.weapons[@weapon_id]
    return weapon != nil ? weapon.animation2_id : 0
  end
  #--------------------------------------------------------------------------
  # * Get Class Name
  #--------------------------------------------------------------------------
  def class_name
    return $data_classes[@class_id].name
  end
  #--------------------------------------------------------------------------
  # * Get EXP String
  #--------------------------------------------------------------------------
  def exp_s
    return @exp_list[@level+1] > 0 ? @exp.to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get Next Level EXP String
  #--------------------------------------------------------------------------
  def next_exp_s
    return @exp_list[@level+1] > 0 ? @exp_list[@level+1].to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # * Get Until Next Level EXP String
  #--------------------------------------------------------------------------
  def next_rest_exp_s
    return @exp_list[@level+1] > 0 ?
      (@exp_list[@level+1] - @exp).to_s : "-------"
  end
  #--------------------------------------------------------------------------
  # * Update Auto State
  #     old_armor : unequipped armor
  #     new_armor : equipped armor
  #--------------------------------------------------------------------------
  def update_auto_state(old_armor, new_armor)
    # Forcefully remove unequipped armor's auto state
    if old_armor != nil and old_armor.auto_state_id != 0
      remove_state(old_armor.auto_state_id, true)
    end
    # Forcefully add unequipped armor's auto state
    if new_armor != nil and new_armor.auto_state_id != 0
      add_state(new_armor.auto_state_id, true)
    end
  end
  #--------------------------------------------------------------------------
  # * Get the weapon
  #--------------------------------------------------------------------------
  def weapon
    return $game_system.weapons[weapon_id]
  end
  #--------------------------------------------------------------------------
  # * Determine Fixed Equipment
  #     equip_type : type of equipment
  #--------------------------------------------------------------------------
  def equip_fix?(equip_type)
    case equip_type
    when 0  # Weapon
      return $data_actors[@actor_id].weapon_fix
    when 1  # Shield
      return $data_actors[@actor_id].armor1_fix
    when 2  # Head
      return $data_actors[@actor_id].armor2_fix
    when 3  # Body
      return $data_actors[@actor_id].armor3_fix
    when 4  # Accessory
      return $data_actors[@actor_id].armor4_fix
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Change Equipment
  #     equip_type : type of equipment
  #     id    : weapon or armor ID (If 0, remove equipment)
  #--------------------------------------------------------------------------
  def equip(equip_type, id, run_equip = true)
    case equip_type
    when 0  # Weapon
      if id == 0 or $game_party.weapon_number(id) > 0
        update_auto_state($game_system.weapons[@weapon_id], $game_system.weapons[id])
        $game_party.gain_weapon(@weapon_id, 1)
        @weapon_id = id
        $game_party.lose_weapon(id, 1)
      end
    when 1  # Shield
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($game_system.armors[@armor1_id], $game_system.armors[id])
        $game_party.gain_armor(@armor1_id, 1)
        @armor1_id = id
        $game_party.lose_armor(id, 1)
      end
    when 2  # Head
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($game_system.armors[@armor2_id], $game_system.armors[id])
        $game_party.gain_armor(@armor2_id, 1)
        @armor2_id = id
        $game_party.lose_armor(id, 1)
      end
    when 3  # Body
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($game_system.armors[@armor3_id], $game_system.armors[id])
        $game_party.gain_armor(@armor3_id, 1)
        @armor3_id = id
        $game_party.lose_armor(id, 1)
      end
    when 4  # Accessory
      if id == 0 or $game_party.armor_number(id) > 0
        update_auto_state($game_system.armors[@armor4_id], $game_system.armors[id])
        $game_party.gain_armor(@armor4_id, 1)
        @armor4_id = id
        $game_party.lose_armor(id, 1)
      end
    end
    run_equip_common_event if run_equip
  end
  #--------------------------------------------------------------------------
  # * Determine if Equippable
  #     item : item
  #--------------------------------------------------------------------------
  def equippable?(item)
    # If weapon
    if item.is_a?(RPG::Weapon) || item.is_a?(Game_Weapon)
      # If included among equippable weapons in current class
      if $data_classes[@class_id].weapon_set.include?(item.id)
        return true
      end
    end
    # If armor
    if item.is_a?(RPG::Armor) || item.is_a?(Game_Armor)
      # If included among equippable armor in current class
      if $data_classes[@class_id].armor_set.include?(item.id)
        return true
      end
    end
    return false
  end
  #--------------------------------------------------------------------------
  # * Change EXP
  #     exp : new EXP
  #--------------------------------------------------------------------------
  def exp=(exp)
    old_level = level
    @exp = [[exp, 9999999].min, 0].max
    # Level up
    while @exp >= @exp_list[@level+1] and @exp_list[@level+1] > 0
      @level += 1
      # Learn skill
      for j in $data_classes[@class_id].learnings
        if j.level == @level
          learn_skill(j.skill_id)
        end
      end
    end
    # Level down
    while @exp < @exp_list[@level]
      @level -= 1
    end
    # Correction if exceeding current max HP and max SP
    @hp = [@hp, self.maxhp].min
    @sp = [@sp, self.maxsp].min
    if @level != old_level
      run_level_code(@level > old_level)
    end
  end
  #--------------------------------------------------------------------------
  # * Change Level
  #     level : new level
  #--------------------------------------------------------------------------
  def level=(level)
    # Check up and down limits
    level = [[level, $data_actors[@actor_id].final_level].min, 1].max
    # Change EXP
    self.exp = @exp_list[level]
  end
  #--------------------------------------------------------------------------
  # * Learn Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def learn_skill(skill_id)
    if skill_id > 0 and not skill_learn?(skill_id)
      @skills.push(skill_id)
      @skills.sort!
    end
  end
  #--------------------------------------------------------------------------
  # * Forget Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def forget_skill(skill_id)
    @skills.delete(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Determine if Finished Learning Skill
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def skill_learn?(skill_id)
    return @skills.include?(skill_id)
  end
  #--------------------------------------------------------------------------
  # * Determine if Skill can be Used
  #     skill_id : skill ID
  #--------------------------------------------------------------------------
  def skill_can_use?(skill_id)
    if not skill_learn?(skill_id)
      return false
    end
    return super
  end
  #--------------------------------------------------------------------------
  # * Change Name
  #     name : new name
  #--------------------------------------------------------------------------
  def name=(name)
    @name = name
  end
  #--------------------------------------------------------------------------
  # * Change Class ID
  #     class_id : new class ID
  #--------------------------------------------------------------------------
  def class_id=(class_id)
    if $data_classes[class_id] != nil
      @class_id = class_id
      # Remove items that are no longer equippable
      unless equippable?($game_system.weapons[@weapon_id])
        equip(0, 0)
      end
      unless equippable?($game_system.armors[@armor1_id])
        equip(1, 0)
      end
      unless equippable?($game_system.armors[@armor2_id])
        equip(2, 0)
      end
      unless equippable?($game_system.armors[@armor3_id])
        equip(3, 0)
      end
      unless equippable?($game_system.armors[@armor4_id])
        equip(4, 0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Change Graphics
  #     character_name : new character file name
  #     character_hue  : new character hue
  #     battler_name   : new battler file name
  #     battler_hue    : new battler hue
  #--------------------------------------------------------------------------
  def set_graphic(character_name, character_hue, battler_name, battler_hue)
    @character_name = character_name
    @character_hue = character_hue
    @battler_name = battler_name
    @battler_hue = battler_hue
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen X-Coordinate
  #--------------------------------------------------------------------------
  def screen_x
    # Return after calculating x-coordinate by order of members in party
    if self.index != nil
      return self.index * 160 + 80
    else
      return 0
    end
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen Y-Coordinate
  #--------------------------------------------------------------------------
  def screen_y
    return 400 # BvZ
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen Z-Coordinate
  #--------------------------------------------------------------------------
  def screen_z
    # Return after calculating z-coordinate by order of members in party
    if self.index != nil
      return 4 - self.index
    else
      return 0
    end
  end
  
  ##
  # Check if the actor will counter a physical attack
  #
  def counter?
    w = $game_system.weapons
    a = $game_system.armors
    return true if w[@weapon_id] != nil && w[@weapon_id].counter
    return true if a[@armor1_id] != nil && a[@armor1_id].counter
    return true if a[@armor2_id] != nil && a[@armor2_id].counter
    return true if a[@armor3_id] != nil && a[@armor3_id].counter
    return true if a[@armor4_id] != nil && a[@armor4_id].counter
    return true if counter
    return false
  end
  
  ##
  # Check if the actor will counter a physical attack
  #
  def counter_spell?
    w = $game_system.weapons
    a = $game_system.armors
    return true if w[@weapon_id] != nil && w[@weapon_id].counter_spell
    return true if a[@armor1_id] != nil && a[@armor1_id].counter_spell
    return true if a[@armor2_id] != nil && a[@armor2_id].counter_spell
    return true if a[@armor3_id] != nil && a[@armor3_id].counter_spell
    return true if a[@armor4_id] != nil && a[@armor4_id].counter_spell
    return true if counter_spell
    return false
  end
  
  ##
  # Calculates the sp_modified provided by the weapon and armors
  # Multiplies the maximum value over 1 and and minimum value under 1 together
  #
  def sp_modifier
    sp_min = 1.0
    sp_max = 1.0
    a = $game_system.armors
    modifiers = [$game_system.weapons[@weapon_id], 
                 a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for modifier in modifiers.compact
      if modifier.sp_multiplier > sp_max
        sp_max = modifier.sp_multiplier
      elsif modifier.sp_multiplier < sp_min
        sp_min = modifier.sp_multiplier
      end
    end
    return sp_min * sp_max
  end
  
  ##
  # Calculates the sp_cost of a skill
  #
  def sp_cost(skill)
    return (skill.sp_cost * sp_modifier).to_i
  end
  def sp_costf(skill)
    return (skill.sp_cost).to_i
  end
  
  ##
  # Check if the actor has first strike
  #
  def has_first_strike?
    return true if first_strike
    # <Z>                                                          # 2016-03-26
    return true if current_action.has_first_strike?
    # </Z>
    return true if first_strike_on_attack && current_action.kind == 0 &&
                                             current_action.basic == 0
    a = $game_system.armors
    items = [$game_system.weapons[@weapon_id], 
             a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for item in items
      return true if item.first_strike
      return true if item.first_strike_on_attack && current_action.kind == 0 &&
                     current_action.basic == 0
    end
    return false
  end
  
  ##
  # Determine equipment regen - hp (placeholder)
  #
  def get_equip_regen_hp
    max_val = 0
    min_val = 0
    a = $game_system.armors
    items = [$game_system.weapons[@weapon_id], 
             a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for item in items
      if item.regen_hp_per_turn.is_a?(Integer)
        i = item.regen_hp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      else
        i = maxhp*item.regen_hp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      end
    end
    return max_val + min_val
  end
  
  ##
  # Determine equipment regen - sp (placeholder)
  #
  def get_equip_regen_sp
    max_val = 0
    min_val = 0
    a = $game_system.armors
    items = [$game_system.weapons[@weapon_id], 
             a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for item in items
      if item.regen_sp_per_turn.is_a?(Integer)
        i = item.regen_sp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      else
        i = maxsp*item.regen_sp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      end
    end
    return max_val + min_val
  end
  
  ##
  # Returns the amount of hits
  #
  def get_hit_multiplier
    hits = hit_multiplier
    a = $game_system.armors
    items = [$game_system.weapons[@weapon_id], 
             a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for item in items
      if item.hit_multiplier > hits
        hits = item.hit_multiplier
      end
    end
    return hits
  end

  ##
  # Returns the amount of hits (fixed enemy)
  #
  def get_hit_multiplier_fixed
    hits = hit_multiplier_fixed
    a = $game_system.armors
    items = [$game_system.weapons[@weapon_id], 
             a[@armor1_id], a[@armor2_id], a[@armor3_id], a[@armor4_id]].compact
    for item in items
      if item.hit_multiplier_fixed > hits
        hits = item.hit_multiplier_fixed
      end
    end
    return hits
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
  
  ##
  # Run the common event when an equip command has been called
  #
  def run_equip_common_event
    if $game_switches[COMMON_EVENT_ON_EQUIP_SWITCH]
      run_common_event(COMMON_EVENT_ON_EQUIP)
    end
  end
  
  ##
  # Run the common event when level change
  #
  def run_level_code(plus = true)
    run_common_event(COMMON_EVENT_ON_LEVEL)
  end
  
  ##
  # Ratio = Kills per battle (Kills / battle)
  #
  def ratio(kill_types = 7)
    return 0 if fights <= 0
    k = 0
    k += kill if kill_types[0] == 1   # Melee
    k += killz if kill_types[1] == 1  # Item
    k += killzz if kill_types[2] == 1 # Spell
    return (k) / fights.to_f
  end
  
  ##
  # Ratio as a textual representation
  #
  def ratio_s(multiplier, kill_types = 7, digits = 2)
    return sprintf("%.#{digits}f", ratio(kill_types)*multiplier)
  end
  
  ##
  # Generation
  #
  
  ATTRIBUTES = ['hit_multiplier', 'hit_multiplier_fixed', 'first_strike', 
                'first_strike_on_attack', 'counter', 'counter_spell']

  for attribute in ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    attr_writer :#{attribute}
    def #{attribute}
      if @#{attribute}.nil?
        return $data_actors[@actor_id].#{attribute}
      else
        return @#{attribute}
      end
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
end
