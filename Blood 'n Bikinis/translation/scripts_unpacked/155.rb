class Game_Skill
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
                'sp_cost',
                'power',
                'atk_f',
                'eva_f',
                'str_f',
                'dex_f',
                'agi_f',
                'int_f',
                'hit',
                'pdef_f',
                'mdef_f',
                'first_strike', # <Z/>                             # 2016-03-26
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
  def initialize(data_skill)
    @data = data_skill
  end
  
end

class RPG::Actor
  for attribute in Game_Skill::ATTRIBUTES
    # Computes the setter and getter code for the specific attribute
PROG = <<FIN
    def #{attribute}=(val)
      index = $data_skills.index(self)
      $game_system.skills[index].#{attribute} = val
    end
FIN
    # Evaluates the method definitions
    eval(PROG)
  end
end