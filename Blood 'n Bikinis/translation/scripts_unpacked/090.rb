#==============================================================================
# ** Scene_Shop
#------------------------------------------------------------------------------
#  This class performs shop screen processing.
#==============================================================================

class Scene_Shop < Scene_Base
  #--------------------------------------------------------------------------
  # * Main Processing
  #--------------------------------------------------------------------------
  def main
    # Make help window
    @help_window = Window_Help.new
    # Make command window
    @command_window = Window_ShopCommand.new
    # Make gold window
    @gold_window = Window_Gold.new
    @gold_window.x = 500
    @gold_window.y = 64
    # Make dummy window
    @dummy_window = Window_Base.new(0, 128, 640, 352)
    # Make buy window
    @buy_window = Window_ShopBuy.new($game_temp.shop_goods)
    @buy_window.active = false
    @buy_window.visible = false
    @buy_window.help_window = @help_window
    # Make sell window
    @sell_window = Window_ShopSell.new
    @sell_window.active = false
    @sell_window.visible = false
    @sell_window.help_window = @help_window
    # Make quantity input window
    @number_window = Window_ShopNumber.new
    @number_window.active = false
    @number_window.visible = false
    # Make status window
    @status_window = Window_ShopStatus.new
    @status_window.visible = false
    # <Z>  Setup for extra lines
    @gold_window.extra_line_adjust(true)
    @dummy_window.extra_line_adjust(false)
    @help_window.resize(System::EXTRA_DESCRIPTION_LINES)
    # </Z>
    # Add as a mouse enabled window
    mouse_windows << @command_window
    mouse_windows << @buy_window
    mouse_windows << @sell_window
    # Set owners
    @command_window.owner = self
    @buy_window.owner = self
    @sell_window.owner = self
    # Execute transition
    Graphics.transition
    # Main loop
    loop do
      # Update game screen
      Graphics.update
      # Update input information
      Input.update
      # Mouse update
      mouse_update
      # Frame update
      update
      # Abort loop if screen is changed
      if $scene != self
        break
      end
    end
    # Prepare for transition
    Graphics.freeze
    # Dispose of windows
    @help_window.dispose
    @command_window.dispose
    @gold_window.dispose
    @dummy_window.dispose
    @buy_window.dispose
    @sell_window.dispose
    @number_window.dispose
    @status_window.dispose
  end
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  def update
    # Update windows
    @help_window.update
    @command_window.update
    @gold_window.update
    @dummy_window.update
    @buy_window.update
    @sell_window.update
    @number_window.update
    @status_window.update  if @status_window.visible
    # If command window is active: call update_command
    if @command_window.active
      update_command
      return
    end
    # If buy window is active: call update_buy
    if @buy_window.active
      update_buy
      return
    end
    # If sell window is active: call update_sell
    if @sell_window.active
      update_sell
      return
    end
    # If quantity input window is active: call update_number
    if @number_window.active
      update_number
      return
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when command window is active)
  #--------------------------------------------------------------------------
  def update_command
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Switch to map screen
      $scene = Scene_Map.new
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      command_trigger
      return
    end
  end
  ##
  # Command window trigger
  #
  def command_trigger
    # Branch by command window cursor position
    case @command_window.index
    when 0  # buy
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Change windows to buy mode
      @command_window.active = false
      @dummy_window.visible = false
      @buy_window.active = true
      @buy_window.visible = true
      @buy_window.refresh
      @status_window.visible = true
    when 1  # sell
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Change windows to sell mode
      @command_window.active = false
      @dummy_window.visible = false
      @sell_window.active = true
      @sell_window.visible = true
      @sell_window.refresh
    when 2  # quit
      # Play decision SE
      $game_system.se_play($data_system.decision_se)
      # Switch to map screen
      $scene = Scene_Map.new
    end
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when buy window is active)
  #--------------------------------------------------------------------------
  def update_buy
    # Set status window item
    @status_window.item = @buy_window.item
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Change windows to initial mode
      @command_window.active = true
      @dummy_window.visible = true
      @buy_window.active = false
      @buy_window.visible = false
      @status_window.visible = false
      @status_window.item = nil
      # Erase help text
      @help_window.set_text("")
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      buy_trigger
    end
  end
  ##
  # Buy trigger window
  #
  def buy_trigger
    # Get item
    @item = @buy_window.item
    # If item is invalid, or price is higher than money possessed
    if @item == nil or @item.price > $game_party.gold
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # The shop limit
    limit = nil
    # Get items in possession count
    case @item
    when Game_Item
      number = $game_party.item_number(@item.id)
      limit = $game_system.shop.items[@item.id]
    when Game_Weapon
      number = $game_party.weapon_number(@item.id)
      limit = $game_system.shop.weapons[@item.id]
    when Game_Armor
      number = $game_party.armor_number(@item.id)
      limit = $game_system.shop.armors[@item.id]
    end
    # If 99 items are already in possession
    if number == 99
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Calculate maximum amount possible to buy
    max = @item.price == 0 ? 99 : $game_party.gold / @item.price
    max = [max, 99 - number].min
    unless limit.nil?
      max = [max, limit].min
    end
    # Change windows to quantity input mode
    @buy_window.active = false
    @buy_window.visible = false
    @number_window.set(@item, max, @item.price)
    @number_window.active = true
    @number_window.visible = true
    Mouse.update
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when sell window is active)
  #--------------------------------------------------------------------------
  def update_sell
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Change windows to initial mode
      @command_window.active = true
      @dummy_window.visible = true
      @sell_window.active = false
      @sell_window.visible = false
      @status_window.item = nil
      # Erase help text
      @help_window.set_text("")
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C)
      sell_trigger
    end
  end
  ##
  # Sell window trigger
  #
  def sell_trigger
    # Get item
    @item = @sell_window.item
    # If item is invalid, or item price is 0 (unable to sell)
    if @item == nil or @item.price == 0
      # Play buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Set status window item
    @status_window.item = @item
    # Play decision SE
    $game_system.se_play($data_system.decision_se)
    # Get items in possession count
    case @item
    when Game_Item
      number = $game_party.item_number(@item.id)
    when Game_Weapon
      number = $game_party.weapon_number(@item.id)
    when Game_Armor
      number = $game_party.armor_number(@item.id)
    end
    # Maximum quanitity to sell = number of items in possession
    max = number
    # Change windows to quantity input mode
    @sell_window.active = false
    @sell_window.visible = false
    #if $game_variables[22] != 0  # EDIT SELL
     # @number_window.set(@item, max, @item.price * 100 / $game_variables[22])
    #else
     # @number_window.set(@item, max, @item.price)
    #end
    
    @number_window.set(@item, max, 1)
    
    @number_window.active = true
    @number_window.visible = true
    @status_window.visible = true
    Mouse.update
  end
  #--------------------------------------------------------------------------
  # * Frame Update (when quantity input window is active)
  #--------------------------------------------------------------------------
  def update_number
    # If B button was pressed
    if Input.trigger?(Input::B) || Mouse.trigger?(Mouse::RIGHT_CLICK)
      # Play cancel SE
      $game_system.se_play($data_system.cancel_se)
      # Set quantity input window to inactive / invisible
      @number_window.active = false
      @number_window.visible = false
      # Branch by command window cursor position
      case @command_window.index
      when 0  # buy
        # Change windows to buy mode
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # sell
        # Change windows to sell mode
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
    # If C button was pressed
    if Input.trigger?(Input::C) || Mouse.trigger?(Mouse::MIDDLE_CLICK)
      # Play shop SE
      $game_system.se_play($data_system.shop_se)
      # Set quantity input window to inactive / invisible
      @number_window.active = false
      @number_window.visible = false
      # Branch by command window cursor position
      case @command_window.index
      when 0  # buy
        # Buy process
        $game_party.lose_gold(@number_window.number * @item.price)
        case @item
        when Game_Item
          $game_party.gain_item(@item.id, @number_window.number)
        when Game_Weapon
          $game_party.gain_weapon(@item.id, @number_window.number)
        when Game_Armor
          $game_party.gain_armor(@item.id, @number_window.number)
        end
        # Decrement the amount of items in the shop
        $game_system.shop.decrement(@item, @number_window.number)
        # Refresh each window
        @gold_window.refresh
        @buy_window.refresh
        @status_window.refresh
        # Change windows to buy mode
        @buy_window.active = true
        @buy_window.visible = true
      when 1  # sell
        # Sell process # EDIT SELL
        #if $game_variables[22] != 0
         # $game_party.gain_gold(@number_window.number * (@item.price * 100 / $game_variables[22]))
        #else
         # $game_party.gain_gold(@number_window.number * @item.price)
        # end
        
        $game_party.gain_gold(@number_window.number * 1)
        
        case @item
        when Game_Item
          $game_party.lose_item(@item.id, @number_window.number)
        when Game_Weapon
          $game_party.lose_weapon(@item.id, @number_window.number)
        when Game_Armor
          $game_party.lose_armor(@item.id, @number_window.number)
        end
        # Refresh each window
        @gold_window.refresh
        @sell_window.refresh
        @status_window.refresh
        # Change windows to sell mode
        @sell_window.active = true
        @sell_window.visible = true
        @status_window.visible = false
      end
      return
    end
  end
  ##
  # Events can be fired on scenes
  #
  def fireEvent(event)
    command_trigger if event.sender == @command_window
    buy_trigger if event.sender == @buy_window
    sell_trigger if event.sender == @sell_window
  end
end
