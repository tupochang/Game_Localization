##
# Call common event on attack
#
class Scene_Battle < Scene_Base
  alias_method :zeriab_make_basic_action_result, :make_basic_action_result
  def make_basic_action_result
    zeriab_make_basic_action_result
    # If attack
    if @active_battler.current_action.basic == 0
      if @active_battler.common_event_on_attack &&
         @active_battler.common_event_on_attack > 0
        @common_event_id = @active_battler.common_event_on_attack
      end
    end
  end
end

##
# Static Data extensions
#
module RPG
  class Enemy
    attr_sec_accessor :common_event_on_attack, 189
  end
end

module RPG
  class Actor
    attr_sec_accessor :common_event_on_attack, 0
  end
end

##
# Active game object extensions
#
class Game_Enemy < Game_Battler
  attr_writer :common_event_on_attack
  def common_event_on_attack
    if @common_event_on_attack.nil?
      return $data_enemies[@enemy_id].common_event_on_attack
    else
      return @common_event_on_attack
    end
  end
end

class Game_Actor < Game_Battler
  attr_writer :common_event_on_attack
  def common_event_on_attack
    if @common_event_on_attack.nil?
      return $data_actors[@actor_id].common_event_on_attack
    else
      return @common_event_on_attack
    end
  end
end