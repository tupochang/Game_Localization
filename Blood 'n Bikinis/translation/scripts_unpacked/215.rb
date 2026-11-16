class Scene_Battle < Scene_Base
  alias_method :zeriab_turn_end_update_phase4_step1, :update_phase4_step1
  def update_phase4_step1
    phase = @phase
    zeriab_turn_end_update_phase4_step1
    if phase == 4 && @phase == 2 && $game_temp.battle_turn > 0
      @common_event_id = System::Battle::COMMON_EVENT_ON_TURN_END
      update_phase4_step6
    end
  end
end