#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
  # * Set Targeted Battler for Skill or Item
  #     scope : effect scope for skill or item
  #--------------------------------------------------------------------------
  def set_target_battlers(scope)
    # If battler performing action is enemy
    if @active_battler.is_a?(Game_Enemy)
      # Branch by effect scope
      case scope
      when 1  # single enemy
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 2  # all enemies
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 3  # single ally
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 4  # all allies
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy) unless enemy.index == 0
          end
        end
      when 5  # single ally (HP 0) 
        index = @active_battler.current_action.target_index
        enemy = $game_troop.enemies[index]
        if enemy != nil and enemy.hp0?
          @target_battlers.push(enemy)
        end
      when 6  # all allies (HP 0) 
        for enemy in $game_troop.enemies
          if enemy != nil and enemy.hp0?
            @target_battlers.push(enemy)
          end
        end
      when 7  # user
        @target_battlers.push(@active_battler)
      end
    end
    # If battler performing action is actor
    if @active_battler.is_a?(Game_Actor)
      # Branch by effect scope
      case scope
      when 1  # single enemy
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_troop.smooth_target_enemy(index))
      when 2  # all enemies
        for enemy in $game_troop.enemies
          if enemy.exist?
            @target_battlers.push(enemy) unless enemy.index == 0
          end
        end
      when 3  # single ally
        index = @active_battler.current_action.target_index
        @target_battlers.push($game_party.smooth_target_actor(index))
      when 4  # all allies
        for actor in $game_party.actors
          if actor.exist?
            @target_battlers.push(actor)
          end
        end
      when 5  # single ally (HP 0) 
        index = @active_battler.current_action.target_index
        actor = $game_party.actors[index]
        if actor != nil and actor.hp0?
          @target_battlers.push(actor)
        end
      when 6  # all allies (HP 0) 
        for actor in $game_party.actors
          if actor != nil and actor.hp0?
            @target_battlers.push(actor)
          end
        end
      when 7  # user
        @target_battlers.push(@active_battler)
      end
    end
  end
end
