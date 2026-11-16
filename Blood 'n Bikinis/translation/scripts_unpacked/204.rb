#==============================================================================
# Easy LvlUp Notifier by Blizzard
# Version: 1.21b
# Date: 27.8.2006
# Date v1.2b: 3.11.2006
# 
# 
# Compatibility:
# 
# 96% chance of compatibility with everything. May cause slight problems with
# following systems and would need therefore slight recalibration:
# - exotic CBS-es
# - exotic skill systems (e.g. Soul Rage System)
# - exotic stat systems (additional stats like Wisdom, Luck etc.)
# - WILL corrupt old savegames
# 
# 
# Features:
# 
# - shows increased stats and learned skills at level up
# - animated
# - shows EXP gain for each actor (!) only after gaining EXP after a battle
# - more simple and less laggy than other Level Up Notifiers
# - you can set up any sound to be played when a higher level is reached or a
#   new skill is learned (LVLUP_SE and LEARN_SE further below)
# - uses the Window_Help class to show new learned skills instead of making an
#   entire new Window class for that
# 
# v1.2b:
# 
# - better window movement
# - higher compatibility
# - fixed a few "eventual" bugs
# 
# v1.21b:
# 
# - fixed a bug
# 
# 
# Instructions:
# 
# - Explanation:
# 
# This script will notify you when any character is leveled up after a battle.
# It will show any stats that were increased and any skills, that were learned.
# The windows are animated, the code is less complex than any other so far and
# it is most efficient as well as highly optimized and detailed worked out.
# 
# - Configuration:
# 
# Change LVLUP_SE = "087-Action02" and LEARN_SE = "106-Heal02" to any sound you
# want to be played when a new level is reached / a new skill was learned.
# 
# - For scripters:
# 
# 1) Modify following line (284) to make this script compatible with exotic
# skill systems:
# 
# @skills.push(id) if not @old_skills.include?(id)
# 
# Just add more "if"s to exclude any additional skills. i.e. for the Soul Rage
# System (version 2.0 or lower) this line should be:
# 
# if not $game_system.skills[id].element_set.include?($sr_element)
#   @skills.push(id) if not @old_skills.include?(id)
# end
# 
# 2) To make this script working for additional character stats like Wisdom,
# Luck etc. you only need to modify slighty Window_LevelUp\initialize and
# Window_LevelUp\refresh. In the refresh method, just increase the loop
# incrementor (for i in 0...7) and add any stat just like the normal stats
# are added in the script.
# 
# 3) To enable the EXP data in the normal window remove the entire
# Window_BattleResult class from this script
# 
# 4) To disable the display of gained EXP for each character even if no new
# level was reached find Window_LevelUp\test_lvlup and change any @exp to
# @level and any @actor.all_exp to @actor.level (CTRL+H).
# 
# 
# If you find any bugs, please report them here:
# http://www.chaosproject.co.nr/
# or send me an e-mail:
# boris_blizzard@yahoo.de
# 
#==============================================================================

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# START Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

LVLUP_SE = "087-Action02"
LEARN_SE = "106-Heal02"

#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
# END Configuration
#::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

#============================================================================== 
# Game_Actor 
#============================================================================== 

class Game_Actor < Game_Battler 
 
 def all_exp
   return @exp
 end 
 
 def all_exp=(exp)
   @exp = exp
 end 
 
end

#==============================================================================
# Window_BattleResult
#==============================================================================

class Window_BattleResult < Window_Base
 
 def refresh
   self.contents.clear
   x = 4
   self.contents.font.color = system_color
   cx = contents.text_size("Gained").width
   self.contents.draw_text(x, 0, cx, 32, "Gained")
   x += cx + 4
   self.contents.font.color = normal_color
   cx = contents.text_size(@gold.to_s).width
   self.contents.draw_text(x, 0, cx, 32, @gold.to_s)
   x += cx + 4
   self.contents.font.color = system_color
   self.contents.draw_text(x, 0, 128, 32, $data_system.words.gold)
   y = 32
   for item in @treasures
     draw_item_name(item, 4, y)
     y += 32
   end
 end
 
end

#==============================================================================
# Window_SkillLearn
#==============================================================================

class Window_SkillLearn < Window_Help
 
 def initialize
   super
   if $fontface != nil
     self.contents.font.name = $fontface
   elsif $defaultfonttype != nil
     self.contents.font.name = $defaultfonttype
   end
 end
 
 def set_text(text)
   self.width = self.contents.text_size(text).width + 48
   self.x = 320 - self.width/2
   self.y = 304 #BvZ
   self.visible = true
   Audio.se_play("Audio/SE/" + LEARN_SE, 80, 100)
   self.contents = Bitmap.new(self.width - 32, self.height - 32)
   super(text, 1)
 end
 
end

#==============================================================================
# Window_LevelUp
#==============================================================================

class Window_LevelUp < Window_Base

 attr_accessor :limit
 attr_reader :skills
 
 def initialize(actor, skill_window)
   super(0, 0, 160, 32)
   @skill_window = skill_window
   @skill_window.visible = false
   self.x = actor.index * 160
   self.visible = false
   self.z = 100
   @actor = actor
   @exp = @actor.all_exp
   @level = @actor.level
   @maxhp = @actor.maxhp
   @maxsp = @actor.maxsp
   @str = @actor.str
   @dex = @actor.dex
   @agi = @actor.agi
   @int = @actor.int
   @old_skills = @actor.skills.clone
   @skills = []
   @limit = 480
 end
 
 def refresh
   count = 0
   count += 1 if @level != @actor.level
   count += 1 if @maxhp != @actor.maxhp
   count += 1 if @maxsp != @actor.maxsp
   count += 1 if @str != @actor.str
   count += 1 if @dex != @actor.dex
   count += 1 if @agi != @actor.agi
   count += 1 if @int != @actor.int
   self.height = count * 24 + 64
   @limit = 231 - self.height #BvZ
   self.y = 160 + @limit + (self.height/64+1)*64 
   self.contents = Bitmap.new(self.width - 32, self.height - 32)
   if $fontface != nil
     self.contents.font.name = $fontface
   elsif $defaultfonttype != nil
     self.contents.font.name = $defaultfonttype
   end
   self.contents.font.size = 20
   @skill_window.visible = false
   self.contents.font.color = normal_color
   self.contents.draw_text(0, 0, 128, 32, "Gained " + (@actor.all_exp - @exp).to_s + " EXP")
   j = 1
   for i in 0...7
     case i
     when 0
       text1 = "Level:"
       text2 = @level.to_s
       text3 = @actor.level.to_s
       next if @level == @actor.level
     when 1
       text1 = $data_system.words.hp
       text2 = @maxhp.to_s
       text3 = @actor.maxhp.to_s
       next if @maxhp == @actor.maxhp
     when 2
       text1 = $data_system.words.sp
       text2 = @maxsp.to_s
       text3 = @actor.maxsp.to_s
       next if @maxsp == @actor.maxsp
     when 3
       text1 = $data_system.words.str[0,3]
       text2 = @str.to_s
       text3 = @actor.str.to_s
       next if @str == @actor.str
     when 4
       text1 = $data_system.words.dex[0,3]
       text2 = @dex.to_s
       text3 = @actor.dex.to_s
       next if @dex == @actor.dex
     when 5
       text1 = $data_system.words.agi[0,3]
       text2 = @agi.to_s
       text3 = @actor.agi.to_s
       next if @agi == @actor.agi
     when 6
       text1 = $data_system.words.int[0,3]
       text2 = @int.to_s
       text3 = @actor.int.to_s
       next if @int == @actor.int
     else
       text1 = ""
       text2 = ""
       text3 = ""
     end
     self.contents.font.color = system_color
     self.contents.draw_text(0, j*24, 128, 32, text1)
     self.contents.font.color = normal_color
     self.contents.draw_text(0, j*24, 76, 32, text2, 2)
     self.contents.font.color = system_color
     self.contents.draw_text(80, j*24, 32, 32, "»")
     self.contents.font.color = Color.new(0, 255, 64, 255)
     self.contents.font.color = Color.new(255, 64, 0, 255) if text2.to_i > text3.to_i
     self.contents.draw_text(0, j*24, 128, 32, text3, 2)
     j += 1
   end
 end
 
 def test_lvlup
   if @exp != @actor.all_exp
     Audio.se_play("Audio/SE/" + LVLUP_SE, 80, 100)
     check_skills
     refresh
     @exp = @actor.all_exp
     self.visible = true
     return true
   end
   @skill_window.visible = false
   return false
 end
 
 def test_lvlup(flag = false)
   if flag
     if @exp != @actor.all_exp and @level == @actor.level
       refresh
       @exp = @actor.all_exp
       self.visible = true
       return true
     else
       return false
     end
   end
   if @level != @actor.level
     Audio.se_play("Audio/SE/" + LVLUP_SE, 80, 100)
     check_skills
     refresh
     @exp = @actor.all_exp
     @level = @actor.level
     self.visible = true
     return true
   end
   @skill_window.visible = false
   return false
 end
 
 def check_skills
   #return ### Does nothing!
   for id in @actor.skills
     @skills.push(id) if not @old_skills.include?(id)
   end
 end
 
 def set_next_skill
   text = @actor.name + " learned " + $game_system.skills[@skills.shift].name + "!"
   @skill_window.set_text(text)
   self.visible = true
 end
 
end

#============================================================================== 
# Scene_Battle
#============================================================================== 

class Scene_Battle < Scene_Base
 
 alias main_lvlup_later main
 def main
   @lvlup_windows = []
   @skilllearn_window = Window_SkillLearn.new
   for i in 0...$game_party.actors.size
     @lvlup_windows.push(Window_LevelUp.new($game_party.actors[i], @skilllearn_window))
   end
   main_lvlup_later
   for win in @lvlup_windows
     win.dispose if win != nil
   end
   @skilllearn_window.dispose
 end
 
 alias start_phase5_lvlup_later start_phase5
 def start_phase5
   for actor in $game_party.actors
     actor.remove_states_battle
   end
   @lvlup_index = 0
   @flags = []
   start_phase5_lvlup_later
 end
 
 def update_phase5
   if @phase5_wait_count > 0
     @phase5_wait_count -= 1
     if @phase5_wait_count == 0
       @result_window.visible = true
       $game_temp.battle_main_phase = false
       @status_window.refresh
     end
     return
   end
   if @flags == []
     @flags = [false]
     for i in 0...$game_party.actors.size
       @flags.push(i) if @lvlup_windows[i].test_lvlup(true)
     end
     @flags = [true] if @flags.size == 1
   end
   if @flags[0] == true
     if @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 64
       @lvlup_windows[@lvlup_index].y -= 64
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 32
       @lvlup_windows[@lvlup_index].y -= 32
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 16
       @lvlup_windows[@lvlup_index].y -= 16
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 8
       @lvlup_windows[@lvlup_index].y -= 8
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 4
       @lvlup_windows[@lvlup_index].y -= 4
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 2
       @lvlup_windows[@lvlup_index].y -= 2
     elsif @lvlup_windows[@lvlup_index].y > @lvlup_windows[@lvlup_index].limit + 1
       @lvlup_windows[@lvlup_index].y -= 1
     end
   else
     for i in 1...@flags.size
       if @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 64
         @lvlup_windows[@flags[i]].y -= 64
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 32
         @lvlup_windows[@flags[i]].y -= 32
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 16
         @lvlup_windows[@flags[i]].y -= 16
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 8
         @lvlup_windows[@flags[i]].y -= 8
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 4
         @lvlup_windows[@flags[i]].y -= 4
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 2
         @lvlup_windows[@flags[i]].y -= 2
       elsif @lvlup_windows[@flags[i]].y > @lvlup_windows[@flags[i]].limit + 1
         @lvlup_windows[@flags[i]].y -= 1
       end
     end
   end
   if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::LEFT_CLICK)
     if @check
       @check = false
       return if not @flags[0]
     end
     @flags[0] = true
     for i in 0...$game_party.actors.size
       @lvlup_index += 1 if @flags.include?(@lvlup_index)
     end
     @result_window.visible = false if @result_window.visible != false
     loop do
       Graphics.update
       if @lvlup_windows[@lvlup_index] == nil
         battle_end(0)
         return
       end
       check = @lvlup_windows[@lvlup_index].test_lvlup
       if @lvlup_windows[@lvlup_index].skills.size == 0
         return if check
         if @lvlup_index == ($game_party.actors.size - 1)
           battle_end(1) if @escaped
           battle_end(0)
           return
         end
         @lvlup_index += 1
       else
         @lvlup_windows[@lvlup_index].set_next_skill
         return
       end
     end
   end
 end
 
end