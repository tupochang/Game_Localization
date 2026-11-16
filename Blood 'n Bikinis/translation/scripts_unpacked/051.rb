#==============================================================================
# ** Window_Status
#------------------------------------------------------------------------------
#  This window displays full status specs on the status screen.
#==============================================================================

class Window_Status < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #     actor : actor
  #--------------------------------------------------------------------------
  def initialize(actor)
    super(0, 0, 640, 480)
    self.contents = Bitmap.new(width - 32, height - 32)
    @actor = actor
    refresh
  end
    def draw_actor_faceM(actor, x, y) 
    bitmap = RPG::Cache.character("Status/" + actor.character_name, actor.character_hue) 
    src_rect = Rect.new(0, 0,300,460)  #size picture 192/384
    self.contents.blt(x - 96 / 2, y - 96, bitmap, src_rect) 
  end 
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.name = ["Impact", "Arial", "Times New Roman"]
    self.contents.font.size = 20
    draw_actor_faceM(@actor, 220, 80) #position picture 240/135
    draw_actor_name(@actor, 4, 0)
    draw_actor_level(@actor, 24, 32) #was 96 instead of 4
    draw_actor_state(@actor, 24, 64)
    draw_actor_hp(@actor, 24, 112, 172)
    draw_actor_sp(@actor, 24, 144, 172)
    draw_actor_parameter(@actor, 24, 192, 0)
    draw_actor_parameter(@actor, 24, 224, 1)
    draw_actor_parameter(@actor, 24, 256, 2)
    draw_actor_parameter(@actor, 24, 304, 3)
    draw_actor_parameter(@actor, 24, 400, 4)
    draw_actor_parameter(@actor, 24, 336, 5)
    draw_actor_parameter(@actor, 24, 368, 6)
    self.contents.font.color = system_color
    self.contents.draw_text(400, 384, 80, 32, "EXP")
    self.contents.draw_text(400, 400, 80, 32, "NXT")
    self.contents.font.color = normal_color
    self.contents.draw_text(400, 384, 84, 32, @actor.exp_s, 2)
    self.contents.draw_text(400, 400, 84, 32, @actor.next_rest_exp_s, 2)
    self.contents.font.color = system_color
    self.contents.draw_text(432, 128, 96, 32, "EQUIPMENT") 
    draw_item_name($game_system.weapons[@actor.weapon_id], 384 + 16, 160, true) 
    draw_item_name($game_system.armors[@actor.armor1_id], 384 + 16, 208, true) 
    draw_item_name($game_system.armors[@actor.armor2_id], 384 + 16, 256, true) 
    draw_item_name($game_system.armors[@actor.armor3_id], 384 + 16, 304, true) 
    draw_item_name($game_system.armors[@actor.armor4_id], 384 + 16, 352, true) 
    self.contents.font.color = system_color 
    #self.contents.draw_text(320, 12, 80, 32, "WEAPON") 
    self.contents.font.color = normal_color 
    #self.contents.draw_text(320 + 80, 12, 84, 32, @actor.kill.to_s, 2) 
    self.contents.font.color = normal_color 
    #self.contents.draw_text(320 + 160, 12, 84, 32, @actor.hitz.to_s, 2)
    self.contents.font.color = system_color 
    self.contents.draw_text(384, 30, 80, 32, "KILLS") 
    self.contents.font.color = normal_color 
    self.contents.draw_text(400, 30, 84, 32, @actor.kills.to_s, 2) 
    self.contents.font.color = normal_color 
    #self.contents.draw_text(320 + 160, 30, 84, 32, @actor.hitzz.to_s, 2)
    self.contents.font.color = system_color 
    #self.contents.draw_text(320 + 130, -3, 80, 32, "KILL") 
    self.contents.font.color = system_color 
    #self.contents.draw_text(320 + 210, -3, 80, 32, "HIT") 
    self.contents.draw_text(384, 48, 80, 32, "DEFEATS") 
    self.contents.font.color = normal_color 
    self.contents.draw_text(400, 48, 84, 32, $game_variables[DEATH_START_ID + @actor.id - 1].to_s, 2)
    self.contents.font.color = normal_color 
    # self.contents.draw_text(0, 135, 80, 32, "[STATES]") 
    self.contents.font.color = system_color 
    self.contents.draw_text(384, 64, 80, 32, "FIGHTS") 
    self.contents.font.color = normal_color
    self.contents.draw_text(400, 64, 84, 32, @actor.fights.to_s, 2)
    if @actor.states.size == 0
      self.contents.draw_text(0, 160, 96, 32, "") 
    end
    #for i in 0...@actor.states.size
     # state = @actor.states[i]
      #if $data_states[state].name.downcase == "knockout"
       # self.contents.font.color = knockout_color
      #end
      #self.contents.draw_text(0, 151+i*16, 96, 32, $data_states[state].name) 
    #end
  end
  def dummy
    self.contents.font.color = system_color
    self.contents.draw_text(320, 112, 196, 32, $data_system.words.weapon)
    self.contents.draw_text(320, 176, 96, 32, $data_system.words.armor1)
    self.contents.draw_text(320, 240, 96, 32, $data_system.words.armor2)
    self.contents.draw_text(320, 304, 96, 32, $data_system.words.armor3)
    self.contents.draw_text(320, 368, 96, 32, $data_system.words.armor4)
    draw_item_name($game_system.weapons[@actor.weapon_id], 320 + 24, 144, true)
    draw_item_name($game_system.armors[@actor.armor1_id], 320 + 24, 208, true)
    draw_item_name($game_system.armors[@actor.armor2_id], 320 + 24, 272, true)
    draw_item_name($game_system.armors[@actor.armor3_id], 320 + 24, 336, true)
    draw_item_name($game_system.armors[@actor.armor4_id], 320 + 24, 400, true)
  end
end
