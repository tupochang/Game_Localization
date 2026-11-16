#==============================================================================
# ** Spriteset_Map
#------------------------------------------------------------------------------
#  This class brings together map screen sprites, tilemaps, etc.
#  It's used within the Scene_Map class.
#==============================================================================

class Spriteset_Map
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    # Make viewports
    @viewport1 = Viewport.new(0, 0, 640, 480)
    @viewport2 = Viewport.new(0, 0, 640, 480)
    @viewport3 = Viewport.new(0, 0, 640, 480)
    @viewport2.z = 200
    @viewport3.z = 5000
    # Make tilemap
    @tilemap = Tilemap.new(@viewport1)
    @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
    for i in 0..6
      autotile_name = $game_map.autotile_names[i]
      @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
    end
    @tilemap.map_data = $game_map.data
    @tilemap.priorities = $game_map.priorities
    # Make panorama plane
    @panorama = Plane.new(@viewport1)
    @panorama.z = -1000
    # Make fog plane
    @fog = Plane.new(@viewport1)
    @fog.z = 3000
    # Make character sprites
    init_characters
    # Make hero sprite
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
    # Make weather
    @weather = RPG::Weather.new(@viewport1)
    # Make picture sprites
    @picture_sprites = []
    for i in 1..50
      @picture_sprites.push(Sprite_Picture.new(@viewport2,
        $game_screen.pictures[i]))
    end
    # Make timer sprite
    @timer_sprite = Sprite_Timer.new
    # Frame update
    update
  end
  #--------------------------------------------------------------------------
  # * Dispose
  #--------------------------------------------------------------------------
  def dispose
    # Dispose of tilemap
    @tilemap.tileset.dispose
    for i in 0..6
      @tilemap.autotiles[i].dispose
    end
    @tilemap.dispose
    # Dispose of panorama plane
    @panorama.dispose
    # Dispose of fog plane
    @fog.dispose
    # Dispose of weather
    @weather.dispose
    # Dispose of picture sprites
    for sprite in @picture_sprites
      sprite.dispose
    end
    # Dispose of character sprites
    for sprite in @character_event_sprites
      sprite.dispose unless sprite.disposed?
    end
    # Dispose of timer sprite
    @timer_sprite.dispose
    # Dispose of viewports
    @viewport1.dispose
    @viewport2.dispose
    @viewport3.dispose
  end
  #------------------------------------------------------------------------
  # * Frame Update Overwrite
  #------------------------------------------------------------------------
  def update
    # If panorama is different from current one
    if @panorama_name != $game_map.panorama_name or
       @panorama_hue != $game_map.panorama_hue
      @panorama_name = $game_map.panorama_name
      @panorama_hue = $game_map.panorama_hue
      if @panorama.bitmap != nil
        @panorama.bitmap.dispose
        @panorama.bitmap = nil
      end
      if @panorama_name != ""
        @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
      end
      Graphics.frame_reset
    end
    # If fog is different than current fog
    if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
      @fog_name = $game_map.fog_name
      @fog_hue = $game_map.fog_hue
      if @fog.bitmap != nil
        @fog.bitmap.dispose
        @fog.bitmap = nil
      end
      if @fog_name != ""
        @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
      end
      Graphics.frame_reset
    end
    # Update tilemap
    @panorama.ox = $game_map.display_x / 100
    @panorama.oy = $game_map.display_y / 100
    @tilemap.update
    # Update panorama plane
    @panorama.ox = $game_map.display_x / 8
    @panorama.oy = $game_map.display_y / 8
    # Update fog plane
    @fog.zoom_x = $game_map.fog_zoom / 100.0
    @fog.zoom_y = $game_map.fog_zoom / 100.0
    @fog.opacity = $game_map.fog_opacity
    @fog.blend_type = $game_map.fog_blend_type
    @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
    @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
    @fog.tone = $game_map.fog_tone
    # Update character sprites
    update_character_sprites
    # Update weather graphic
    @weather.type = $game_screen.weather_type
    @weather.max = $game_screen.weather_max
    @weather.ox = $game_map.display_x / 4
    @weather.oy = $game_map.display_y / 4
    @weather.update
    # Update picture sprites
    for sprite in @picture_sprites
      sprite.update
    end
    # Update timer sprite
    @timer_sprite.update
    # Set screen color tone and shake position
    @viewport1.tone = $game_screen.tone
    @viewport1.ox = $game_screen.shake
    # Set screen flash color
    @viewport3.color = $game_screen.flash_color
    # Update viewports
    @viewport1.update
    @viewport3.update
  end
  
  #--------------------------------------------------------------------------
  # * Initializes Character Sprites (Overwrite)
  #--------------------------------------------------------------------------
  def init_characters
    # Creates the array used for holding the hero sprite.
    # Is here for compatibility reasons.
    @character_sprites = []
    # Refreshes the characters in the spritemap
    refresh_characters
    # Refreshes the character sprites
    refresh_character_sprites
  end
  
  #--------------------------------------------------------------------------
  # * Refreshes the characters.
  #--------------------------------------------------------------------------
  def refresh_characters
    # Make character sprites
    @character_event_sprites = []
    @character_spritemap = {}
    # Gets the tile area to search for events
    min_x, max_x, min_y, max_y = $game_map.get_tile_area
    # Goes through all the visible tiles and adds the sprites on those tiles
    for x in min_x..max_x
      for y in min_y..max_y
        add_sprites(x,y)
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Refreshes the character sprites.
  #--------------------------------------------------------------------------
  def refresh_character_sprites
    # Gets the character sprites
    @character_event_sprites = @character_spritemap.values.flatten
    #### Note: I do not think character sprites have to be sorted, but here it
    ####       is if you for some reason need them sorted.
    #@character_event_sprites.sort! {|a,b| a.character.id <=> b.character.id}
    # Updates the last screen x and y to the current x and y
    @last_screen_x = $game_map.display_x / 128
    @last_screen_y = $game_map.display_y / 128
    # The sprites have just been refresh, no need to do this every frame.
    @need_refresh = false
  end
  
  #--------------------------------------------------------------------------
  # * Updates Character Sprites
  #--------------------------------------------------------------------------
  def update_character_sprites
    # Checks if the player has moved
    unless @last_screen_x == $game_map.display_x / 128 &&
           @last_screen_y == $game_map.display_y / 128
      # Gets the difference in the x and y coordinate
      diff_x = @last_screen_x - $game_map.display_x / 128
      diff_y = @last_screen_y - $game_map.display_y / 128
      # Checks if the player has moved more than one tile. (Supports 8-way)
      if diff_x.abs > 1 || diff_y.abs > 1
        # The player has moved more than one tile.
        # This section could be extended if some of the previous visible area
        # still is visible and only update the the the new areas as well as
        # the parts of the old area that is now out of side.
        # For ease and because this should be a rare situation I have decided
        # to simple remove all sprites and start over for the new area.
        @character_event_sprites.each {|sprite| sprite.dispose}
        # Initialized the sprites for the new area
        init_characters
      else
        # Updates the buffer
        update_buffer(diff_x, diff_y)
      end
      # Refresh the character sprites. (To which should be updated)
      refresh_character_sprites
    else
      # Refreshed the character sprites if it is needed
      refresh_character_sprites if @need_refresh
    end
    # Updates the sprites.
    @character_event_sprites.each {|sprite| sprite.update}
    # Updates the hero sprite. Is here to increase compatibility with other
    # scripts using this array. Most caterpillar scripts for example
    @character_sprites.each {|sprite| sprite.update}
  end
  
  #--------------------------------------------------------------------------
  # * Updates Character Sprites
  #--------------------------------------------------------------------------
  def update_buffer(diff_x, diff_y)
    # Gets the tile area to search for events
    min_x, max_x, min_y, max_y = $game_map.get_tile_area
    # For change in x-coordinate
    if diff_x > 0 # Left
      # Removes any sprites outside of the buffer
      unless max_x >= $game_map.width - 1
        for y in min_y..max_y
          dispose_sprites(max_x+1, y)  
        end
      end
      # Adds any new sprites comming into the buffer
      for y in min_y..max_y
        add_sprites(min_x, y)  if @character_spritemap[[min_x,y]].nil?
      end
    elsif diff_x < 0 # Right
      # Removes any sprites outside of the buffer
      unless min_x <= 0
        for y in min_y..max_y
          dispose_sprites(min_x-1, y)  
        end
      end
      # Adds any new sprites comming into the buffer
      for y in min_y..max_y
        add_sprites(max_x, y)  if @character_spritemap[[max_x,y]].nil?
      end
    end
    # For change in y-coordinates
    if diff_y > 0 # Up
      # Removes any sprites outside of the buffer
      unless max_y >= $game_map.height - 1
        for x in min_x..max_x
          dispose_sprites(x, max_y+1)  
        end
      end
      # Adds any new sprites comming into the buffer
      for x in min_x..max_x
        add_sprites(x, min_y)  if @character_spritemap[[x,min_y]].nil?
      end
    elsif diff_y < 0 # Down
      # Removes any sprites outside of the buffer
      unless min_y <= 0
        for x in min_x..max_x
          dispose_sprites(x, min_y-1)  
        end
      end
      # Adds any new sprites comming into the buffer
      for x in min_x..max_x
        add_sprites(x, max_y)  if @character_spritemap[[x,max_y]].nil?
      end
    end
  end
  
  #--------------------------------------------------------------------------
  # * Called when an event has moved
  #--------------------------------------------------------------------------
  def update_event(old_x,old_y,event)
    # Finds the sprites on the event's old position
    sprites = @character_spritemap[[old_x,old_y]]
    # Checks if there are any sprites on the event's old position
    unless sprites.nil?
      # Goes through the sprites to find which one is attached to the given
      # event. Sprite is nil if no sprite on the event's old position is 
      # attached to the given event.
      sprite = nil
      for sprite in sprites
        break if sprite.character == event
      end
    end
    # If there is not a sprite attached to the event
    if sprite.nil?
      # Checks if the event has become visible
      if $game_map.visible?(event.x, event.y)
        # A sprite is create because the event is now visible
        sprite = Sprite_Character.new(@viewport1, event)
        # The sprite is added at the event's current position
        add_sprite(event.x,event.y,sprite)
        # We need to refresh the character sprites since we added one.
        @need_refresh = true
      end
    else # A sprite is attached to the event
      # Checks if the event is still visible
      if $game_map.visible?(event.x, event.y)
        # The event is still visible and moved from its old coordinate
        # to its new coordinates.
        move_event(old_x, old_y, sprite)
      else
        # The sprite is not visible anymore and thus removed
        remove_sprite(old_x,old_y,sprite)
        # The sprite is disposed since we don't want to wait for Ruby's
        # garbage cleaner to remove the sprite from view. (For big sprites)
        sprite.dispose
        # We need to refresh the character sprites since we removed one.
        @need_refresh = true
      end
    end
  end
  
  ##
  ## Macros
  ##
  
  #--------------------------------------------------------------------------
  # * Creates and adds sprites for all the events with the given x and y 
  #   coordinates to the spritemap.
  #--------------------------------------------------------------------------
  def add_sprites(x,y)
    # Returns if there are no events with the given x and y coordinates
    return if $game_map.event_map[[x,y]].nil?
    for event in $game_map.event_map[[x,y]]
      # Creates a sprite for the event
      sprite = Sprite_Character.new(@viewport1, event)
      # Adds the sprite to the spritemap
      add_sprite(x,y,sprite)
    end
  end
  
  #--------------------------------------------------------------------------
  # * Disposes all the sprites on given x,y tile
  #--------------------------------------------------------------------------
  def dispose_sprites(x,y)
    # Returns if there are no sprites with the given coordinates
    return if @character_spritemap[[x,y]].nil?
    for sprite in @character_spritemap[[x,y]]
      # Removes the sprite from the datastructure
      remove_sprite(x,y,sprite)
      # Disposes the sprite
      sprite.dispose
    end
  end

  #--------------------------------------------------------------------------
  # * Moves the sprite from its old coordinates to its new coordinates
  #--------------------------------------------------------------------------
  def move_event(old_x,old_y,sprite)
    # Gets the event attached to the character
    event = sprite.character
    # Returns if the sprite have not change position
    return if old_x == event.x && old_y == event.y
    # Removes the sprite from its old location
    remove_sprite(old_x, old_y, sprite)
    # Adds the sprite to the new location
    add_sprite(event.x, event.y, sprite)
  end
  
  ##
  ## Low level methods, alters the datastructure directly
  ##
  
  #--------------------------------------------------------------------------
  # * Adds the given sprite to the given x and y coordinate to
  #   @character_spritemap.
  #--------------------------------------------------------------------------
  def add_sprite(x,y,sprite)
    # Checks if there a not any sprite on the given tile already
    if @character_spritemap[[x,y]].nil?
      # Adds the sprite to the spriteset as an array containing the sprite
      @character_spritemap[[x,y]] = [sprite]
    else
      # Adds the sprite to the array of sprites with the same x and y
      # coordinates.
      @character_spritemap[[x,y]] << sprite
    end
  end
    
  #--------------------------------------------------------------------------
  # * Removes the given sprite with the given x and y coordinate from
  #   @character_spritemap.
  #--------------------------------------------------------------------------
  def remove_sprite(x,y,sprite)
    # Returns if there are no sprites with the given x and y coordinate
    return  unless !@character_spritemap[[x,y]].nil? &&
                   @character_spritemap[[x,y]].include?(sprite)
    # Checks if there are more sprites with the same coordinates
    if @character_spritemap[[x,y]].size > 1
      # Removes the sprite from the array of sprites with the given coordinates
      @character_spritemap[[x,y]].delete(sprite)
    else
      # Deletes the key attached to the array since there are no sprites left.
      @character_spritemap.delete([x,y])
    end
  end
end
