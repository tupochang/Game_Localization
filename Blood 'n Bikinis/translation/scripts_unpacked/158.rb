class Game_Item
  ATTRIBUTES = ['id', 
                'name', 
                'icon_name', 
                'description', 
                'scope', 
                'occasion',
                'animation1_id', 
                'animation2_id', 
                'menu_se', 
                'common_event_id',
                'price', 
                'consumable', 
                'parameter_type', 
                'parameter_points',
                'recover_hp_rate', 
                'recover_hp', 
                'recover_sp_rate',
                'recover_sp', 
                'hit', 
                'pdef_f', 
                'mdef_f', 
                'variance',
                'element_set', 
                'plus_state_set', 
                'minus_state_set']

  for attribute in ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    attr_writer :#{attribute}
    def #{attribute}
      if @#{attribute}.nil?
        return @data.#{attribute}
      else
        return @#{attribute}
      end
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize(data_item)
    @data = data_item
  end
  
end