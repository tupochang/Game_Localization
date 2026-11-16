class Game_Switches
  def steam_achievement_unlock(switch_id)
    symbol = Achievements::SwitchToSymbol[switch_id]
    Achievements.unlock(symbol) if symbol
  end
  
  def steam_check_all
    # Check all switch achievements
    for key in Achievements::SwitchToSymbol.keys
      steam_achievement_unlock(key) if @data[key]
    end
  end
end

class Game_Variables
  def steam_achievement_unlock(variable_id, value)
    return unless value
    if variable_id == 3342 && value >= 16
      Achievements.unlock(:goblin_pesticide)
    end
  end
  
  def steam_check_all
    # Check Goblin Pesticide achievement
    steam_achievement_unlock(42, @data[42]) 
  end
end

def steam_check_all_achievements
  $game_variables.steam_check_all
  $game_switches.steam_check_all
end


##
# Added an bag of arbitrary counters which are stored in the save files
#
class Game_System
  attr_sec_accessor :ach_counters, '{}'
  
  def add_ach_count(symbol)
    ach_counters[symbol] ||= 0
    ach_counters[symbol] += 1
  end
  
  def ach_count(symbol)
    value = ach_counters[symbol]
    value ||= 0
    return value
  end
end


def achievement_count(symbol, unlock_count)
  $game_system.add_ach_count(symbol)
  if $game_system.ach_count(symbol) >= unlock_count
    Achievements.unlock(symbol)
  end
end