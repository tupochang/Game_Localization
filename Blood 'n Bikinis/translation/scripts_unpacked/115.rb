# <Z>                                                              # 2016-03-26
class Scene_Battle < Scene_Base
  ##
  # Counter rules for physical attacks (includes physical skill attacks)
  #
  def check_attack_counter(target)
    alive = !target.dead?
    will_counter = target.counter?
    not_guarding = !target.guarding?
    # Do not counter friendly fire
    enemy_counter = !@active_battler.is_a?(target.class) 
    # Only counter once
    new_counter = !target.current_action.counter
    if alive && will_counter && not_guarding && enemy_counter && new_counter
      add_physical_counter_attack(target)
    end
  end
  
  def add_physical_counter_attack(target)
    # Add a physical counter attack to the queue
    target.store_current_action
    target.current_action = target.current_action.dup
    target.current_action.target_index = @active_battler.index
    target.current_action.kind = 0
    target.current_action.basic = 0
    target.current_action.counter = true
    target.current_action.forcing = true
    add_execute_now_battler(target)
  end
end
