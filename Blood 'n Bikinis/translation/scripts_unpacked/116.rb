# <Z>                                                              # 2016-03-26
class Scene_Battle < Scene_Base
  ##
  # Counter rules for skill attacked (excludes physical skill attacks)
  #
  def check_skill_counter(target)
    # Some enemies cannot be countered
    is_enemy = @active_battler.is_a?(Game_Enemy)
    if is_enemy
      if System::Battle::ENEMY_NO_COUNTER_SPELL.include?(@active_battler.id)
        return
      end
    end
      
    alive = !target.dead?
    will_counter = target.counter_spell?
    not_guarding = !target.guarding?
    # Do not counter friendly fire
    enemy_counter = !@active_battler.is_a?(target.class)
    # Only counter once
    new_counter = !target.current_action.counter    
    if alive && will_counter && not_guarding && enemy_counter && new_counter
      add_physical_counter_attack(target)
    end  
  end
end