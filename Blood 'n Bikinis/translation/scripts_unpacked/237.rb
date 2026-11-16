class Game_Temp
  attr_sec_accessor :battle_bgm_skip, false          # battle bgm skipping
end

class Interpreter
  alias zeriab_bgmskip_command_301 command_301
  def command_301
    $game_temp.battle_bgm_skip = true
    zeriab_bgmskip_command_301
  end
end
