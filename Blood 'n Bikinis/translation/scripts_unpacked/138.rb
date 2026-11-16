class Game_Actor
  if @stack.nil?
    alias zer_ori_maxhp maxhp
    alias zer_ori_maxsp maxsp
    @stack = true
  end
  
  def maxhp
    n = zer_ori_maxhp
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.hp_plus : 0
    n += armor1 != nil ? armor1.hp_plus : 0
    n += armor2 != nil ? armor2.hp_plus : 0
    n += armor3 != nil ? armor3.hp_plus : 0
    n += armor4 != nil ? armor4.hp_plus : 0
    n = [[n, 1].max, 9999].min
    @hp = n if @hp > n
    return n
  end
  
  def maxsp
    n = zer_ori_maxsp
    weapon = $data_weapons[@weapon_id]
    armor1 = $data_armors[@armor1_id]
    armor2 = $data_armors[@armor2_id]
    armor3 = $data_armors[@armor3_id]
    armor4 = $data_armors[@armor4_id]
    n += weapon != nil ? weapon.sp_plus : 0
    n += armor1 != nil ? armor1.sp_plus : 0
    n += armor2 != nil ? armor2.sp_plus : 0
    n += armor3 != nil ? armor3.sp_plus : 0
    n += armor4 != nil ? armor4.sp_plus : 0
    n = [[n, 0].max, 9999].min
    @sp = n if @sp > n
    return n
  end
end