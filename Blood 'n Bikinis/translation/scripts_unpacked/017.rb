#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It's used within the Game_Troop class
#  ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_sec_accessor :defense_divider, '$data_enemies[@enemy_id].defense_divider'
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     troop_id     : troop ID
  #     member_index : troop member index
  #--------------------------------------------------------------------------
  def initialize(troop_id, member_index)
    super()
    @troop_id = troop_id
    @member_index = member_index
    troop = $data_troops[@troop_id]
    @enemy_id = troop.members[@member_index].enemy_id
    enemy = $data_enemies[@enemy_id]
    @battler_name = enemy.battler_name
    @battler_hue = enemy.battler_hue
    @hp = maxhp
    @sp = maxsp
    @hidden = troop.members[@member_index].hidden
    @immortal = troop.members[@member_index].immortal
  end
  #--------------------------------------------------------------------------
  # * Get Enemy ID
  #--------------------------------------------------------------------------
  def id
    return @enemy_id
  end
  #--------------------------------------------------------------------------
  # * Get Index
  #--------------------------------------------------------------------------
  def index
    return @member_index
  end
  #--------------------------------------------------------------------------
  # * Get Name
  #--------------------------------------------------------------------------
  def name
    return $data_enemies[@enemy_id].name
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum HP
  #--------------------------------------------------------------------------
  def base_maxhp
    return $data_enemies[@enemy_id].maxhp
  end
  #--------------------------------------------------------------------------
  # * Get Basic Maximum SP
  #--------------------------------------------------------------------------
  def base_maxsp
    return $data_enemies[@enemy_id].maxsp
  end
  #--------------------------------------------------------------------------
  # * Get Basic Strength
  #--------------------------------------------------------------------------
  def base_str
    return $data_enemies[@enemy_id].str
  end
  #--------------------------------------------------------------------------
  # * Get Basic Dexterity
  #--------------------------------------------------------------------------
  def base_dex
    return $data_enemies[@enemy_id].dex
  end
  #--------------------------------------------------------------------------
  # * Get Basic Agility
  #--------------------------------------------------------------------------
  def base_agi
    return $data_enemies[@enemy_id].agi
  end
  #--------------------------------------------------------------------------
  # * Get Basic Intelligence
  #--------------------------------------------------------------------------
  def base_int
    return $data_enemies[@enemy_id].int
  end
  #--------------------------------------------------------------------------
  # * Get Basic Attack Power
  #--------------------------------------------------------------------------
  def base_atk
    return $data_enemies[@enemy_id].atk
  end
  #--------------------------------------------------------------------------
  # * Get Basic Physical Defense
  #--------------------------------------------------------------------------
  def base_pdef
    return $data_enemies[@enemy_id].pdef
  end
  #--------------------------------------------------------------------------
  # * Get Basic Magic Defense
  #--------------------------------------------------------------------------
  def base_mdef
    return $data_enemies[@enemy_id].mdef
  end
  #--------------------------------------------------------------------------
  # * Get Basic Evasion
  #--------------------------------------------------------------------------
  def base_eva
    return $data_enemies[@enemy_id].eva
  end
  #--------------------------------------------------------------------------
  # * Get Offensive Animation ID for Normal Attack
  #--------------------------------------------------------------------------
  def animation1_id
    return $data_enemies[@enemy_id].animation1_id
  end
  #--------------------------------------------------------------------------
  # * Get Target Animation ID for Normal Attack
  #--------------------------------------------------------------------------
  def animation2_id
    return $data_enemies[@enemy_id].animation2_id
  end
  #--------------------------------------------------------------------------
  # * Get Element Revision Value
  #     element_id : Element ID
  #--------------------------------------------------------------------------
  def element_rate(element_id)
    # Get a numerical value corresponding to element effectiveness
    table = [0,300,200,100,50,0,-100]
    result = table[$data_enemies[@enemy_id].element_ranks[element_id]]
    # If protected by state, this element is reduced by half
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
    return $data_enemies[@enemy_id].state_ranks
  end
  #--------------------------------------------------------------------------
  # * Determine State Guard
  #     state_id : state ID
  #--------------------------------------------------------------------------
  def state_guard?(state_id)
    return false
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack Element
  #--------------------------------------------------------------------------
  def element_set
    # <Z>
    return hit_weapon != nil ? hit_weapon.element_set : []
    # </Z>
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (+)
  #--------------------------------------------------------------------------
  def plus_state_set
    # <Z>
    return hit_weapon != nil ? hit_weapon.plus_state_set : []
    # </Z>
  end
  #--------------------------------------------------------------------------
  # * Get Normal Attack State Change (-)
  #--------------------------------------------------------------------------
  def minus_state_set
    # <Z>
    return hit_weapon != nil ? hit_weapon.minus_state_set : []
    # </Z>
  end
  #--------------------------------------------------------------------------
  # * Aquire Actions
  #--------------------------------------------------------------------------
  def actions
    return $data_enemies[@enemy_id].actions
  end
  #--------------------------------------------------------------------------
  # * Get EXP
  #--------------------------------------------------------------------------
  def exp
    return $data_enemies[@enemy_id].exp
  end
  #--------------------------------------------------------------------------
  # * Get Gold
  #--------------------------------------------------------------------------
  def gold
    return $data_enemies[@enemy_id].gold
  end
  #--------------------------------------------------------------------------
  # * Get Item ID
  #--------------------------------------------------------------------------
  def item_id
    return $data_enemies[@enemy_id].item_id
  end
  #--------------------------------------------------------------------------
  # * Get Weapon ID
  #--------------------------------------------------------------------------
  def weapon_id
    return $data_enemies[@enemy_id].weapon_id
  end
  #--------------------------------------------------------------------------
  # * Get Armor ID
  #--------------------------------------------------------------------------
  def armor_id
    return $data_enemies[@enemy_id].armor_id
  end
  #--------------------------------------------------------------------------
  # * Get Treasure Appearance Probability
  #--------------------------------------------------------------------------
  def treasure_prob
    return $data_enemies[@enemy_id].treasure_prob
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen X-Coordinate
  #--------------------------------------------------------------------------
  def screen_x
    return $data_troops[@troop_id].members[@member_index].x
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen Y-Coordinate
  #--------------------------------------------------------------------------
  def screen_y
    return $data_troops[@troop_id].members[@member_index].y
  end
  #--------------------------------------------------------------------------
  # * Get Battle Screen Z-Coordinate
  #--------------------------------------------------------------------------
  def screen_z
    return screen_y
  end
  #--------------------------------------------------------------------------
  # * Escape
  #--------------------------------------------------------------------------
  def escape
    # Set hidden flag
    @hidden = true
    # Clear current action
    self.current_action.clear
  end
  #--------------------------------------------------------------------------
  # * Transform
  #     enemy_id : ID of enemy to be transformed
  #--------------------------------------------------------------------------
  def transform(enemy_id)
    # Change enemy ID
    @enemy_id = enemy_id
    # Change battler graphics
    @battler_name = $data_enemies[@enemy_id].battler_name
    @battler_hue = $data_enemies[@enemy_id].battler_hue
    # Remake action
    make_action
  end
  #--------------------------------------------------------------------------
  # * Make Action
  #--------------------------------------------------------------------------
  def make_action
    # Clear current action
    self.current_action.clear
    # If unable to move
    unless self.movable?
      # End Method
      return
    end
    # Extract current effective actions
    available_actions = []
    rating_max = 0
    for action in self.actions
      # Confirm turn conditions
      n = $game_temp.battle_turn
      a = action.condition_turn_a
      b = action.condition_turn_b
      if (b == 0 and n != a) or
         (b > 0 and (n < 1 or n < a or n % b != a % b))
        next
      end
      # Confirm HP conditions
      if self.hp * 100.0 / self.maxhp > action.condition_hp
        next
      end
      # Confirm level conditions
      if $game_party.max_level < action.condition_level
        next
      end
      # Confirm switch conditions
      switch_id = action.condition_switch_id
      if switch_id > 0 and $game_switches[switch_id] == false
        next
      end
      # Confirm that the enemy can cast a magic if the action is one
      if action.kind == 1 && !skill_can_use?(action.skill_id)
        next
      end
      # Add this action to applicable conditions
      available_actions.push(action)
      if action.rating > rating_max
        rating_max = action.rating
      end
    end
    # Calculate total with max rating value at 3 (exclude 0 or less)
    ratings_total = 0
    for action in available_actions
      if action.rating > rating_max - 3
        ratings_total += action.rating - (rating_max - 3)
      end
    end
    # If ratings total isn't 0
    if ratings_total > 0
      # Create random numbers
      value = rand(ratings_total)
      # Set things that correspond to created random numbers as current action
      for action in available_actions
        if action.rating > rating_max - 3
          if value < action.rating - (rating_max - 3)
            self.current_action.kind = action.kind
            self.current_action.basic = action.basic
            self.current_action.skill_id = action.skill_id
            self.current_action.decide_random_target_for_enemy
            return
          else
            value -= action.rating - (rating_max - 3)
          end
        end
      end
    end
  end
  
  ##
  # Check if the enemy will counter a physical attack
  #
  def counter?
    return true if counter
    # <Z>
    return true if hit_weapon != nil && hit_weapon.counter
    # </Z>
    return false
  end
  
  ##
  # Check if the enemy will counter a magical attack
  #
  def counter_spell?
    return true if counter_spell
    # <Z>
    return true if hit_weapon != nil && hit_weapon.counter_spell
    # </Z>
    return false
  end
  
  ##
  # Check if the enemy has first strike
  #
  def has_first_strike?
    return true if first_strike
    # <Z>                                                          # 2016-03-26
    return true if current_action.has_first_strike?
    # </Z>
    return true if first_strike_on_attack && current_action.kind == 0 &&
                                             current_action.basic == 0
    return false
  end
  
  ## <Z>
  # Return the weapon the enemy use to attack
  #
  def hit_weapon
    weapon = nil
    weapon_id = $data_enemies[@enemy_id].hit_weapon_id
    if weapon_id > 0
      weapon = $game_system.weapons[weapon_id]
    end
    return weapon
  end
  # </Z>
  
  ##
  # Returns the amount of hits
  # 
  def get_hit_multiplier
    # <Z>                                                          # 2016-04-11
    hits = hit_multiplier
    weapon = hit_weapon
    if !weapon.nil? && weapon.hit_multiplier > hits
      hits = weapon.hit_multiplier
    end
    return hits
    # </Z>
  end

  ##
  # Returns the amount of hits (fixed actor)
  #
  def get_hit_multiplier_fixed
    # <Z>                                                          # 2016-04-11
    hits = hit_multiplier_fixed
    weapon = hit_weapon
    if !weapon.nil? && weapon.hit_multiplier_fixed > hits
      hits = weapon.hit_multiplier_fixed
    end
    return hits
    # </Z>
  end
  
  ## <Z>
  # Determine equipment regen - hp (placeholder)
  #
  def get_equip_regen_hp
    max_val = 0
    min_val = 0
    unless hit_weapon.nil?
      if hit_weapon.regen_hp_per_turn.is_a?(Integer)
        i = hit_weapon.regen_hp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      else
        i = maxhp*hit_weapon.regen_hp_per_turn
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
    unless hit_weapon.nil?
      if hit_weapon.regen_sp_per_turn.is_a?(Integer)
        i = hit_weapon.regen_sp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      else
        i = maxsp*hit_weapon.regen_sp_per_turn
        max_val = (max_val > i) ? max_val : i
        min_val = (min_val < i) ? min_val : i
      end
    end
    return max_val + min_val
  end
  # </Z>
  
  ##
  # Generation
  #
  
  ATTRIBUTES = ['hit_multiplier', 'hit_multiplier_fixed', 'first_strike', 
                'first_strike_on_attack', 'counter', 'counter_spell',
                'damage_range', 'damage_range_variable']

  for attribute in ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    attr_writer :#{attribute}
    def #{attribute}
      if @#{attribute}.nil?
        return $data_enemies[@enemy_id].#{attribute}
      else
        return @#{attribute}
      end
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
end
