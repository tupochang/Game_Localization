=begin
If you do not have the SDK then you have to change Game_Map
In the Game_Map setup method change the load_data line to this: (Line 50)

  # Load map from file and set @map
  @map = load_data(sprintf("Data/%sMap%03d.rxdata", $game_system.disc, @map_id))

After you have done this the below will work.

This script enables the change_disc command. Use script calls to change the disc.
For disc 1 create a subfolder in your data folder called 'disc1' and place the
map files for disc 1 in there.
For disc 2 you should create a subfolder called 'disc2' and place the map files
for disc 2 in there. And so on for each of your discs.
The syntax is:

  change_disc(number, id = nil, x = nil, y = nil, direction = nil)

The nil numbers mean that those arguments are optional. When you don't use them
then they are set to whatever the current map_id, x, y and direction are at the
moment.

If you want to change to disc 2 then you can put this in a script call:

  change_disc(2)
  
You will then be transfered to disc 2 with the same map id and coordinates as
what the player currently has.
If you want to be more precise and say you want to change to disc 2 on the map
with id 10 and the player must be placed at the tile with x = 6 and y = 13 then
you should put this in a call script:

  change_disc(2, 10, 6, 13)
  
Note that when you start the game the maps directly in the data folder is used.
You can back to them by changing to disc number 0.
Basically, disc number 0 is the maps directly in the data folder and not in any
of the sub folders.

The final argument is the direction. By default the player retains the current
direction. You can put 6 different values as direction:

0, 10 : No change
2     : Turn Down
4     : Turn Left
6     : Turn Right
8     : Turn Up

If you for example want to transfer the player to disc 1, map 43 at x = 30 and
y = 4 with the player looking down you should put this in a call script:

  change_disc(1, 43, 30, 4, 2)
  
*hugs*
 - Zeriab
=end

class Game_System
  attr_writer :disc
  def disc
    @disc ||= ''
    @disc
  end
end

class Game_Temp
  attr_accessor :disc_changing
end

class Game_Map
  attr_writer :map_id
  if Module.constants.include?('SDK')
    def setup_load
      # Load map from file and set @map
      @map = load_data(sprintf("Data/%sMap%03d.rxdata", $game_system.disc, @map_id))
    end
  end
end

def change_disc(number, id = nil, x = nil, y = nil, direction = nil)
  # Change disc
  if number == 0
    $game_system.disc = ''
  else
    $game_system.disc = "disc#{number}/"
  end
  # Process arguments
  map_id = id.is_a?(Integer) ? id : $game_map.map_id
  x = $game_player.x unless x.is_a?(Integer)
  y = $game_player.y unless y.is_a?(Integer)
  direction = $game_player.direction unless direction.is_a?(Integer)
  # Set transferring player flag
  $game_temp.player_transferring = true
  # Set transferring player flag
  $game_temp.disc_changing = true
  # Set player move destination
  $game_temp.player_new_map_id = map_id
  $game_temp.player_new_x = x
  $game_temp.player_new_y = y
  $game_temp.player_new_direction = direction
  # Change the current map id in case the new and old are identical.
  $game_map.map_id = 0
end