# implémentation dans RMXP : on va rajouter l\\\'objet dans Scene_map
class Scene_Map < Scene_Base
  # on renomme la méthode update de Scene_map
  alias update_TurboFab update
 
   # on rédéfinit une nouvelle méthode update de Scene_map
   def update
      # vitesse normale par défaut
      #$scene = Scene_Top10.new($scene) if Input.press?(Input::F8) and $game_switches[2] == true
      #$scene = Scene_PartySwitcher.new if Input.press?(Input::F6) and $game_switches[2] == true
      #$scene = Scene_PartySwitcher.new if Input.press?(Input::X) and $game_switches[2] == true
      #Dialog_Options.show if Input.press?(Input::F5)
      update_TurboFab
    end
 
end 