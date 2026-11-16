module System
  ##
  # Mouse constants
  #
  module Mouse
    module_function
    def get_icon_info(key)
      case key
      when '0'
        return 'Cursor1',
               20,
               15
      when '1'
        return 'Cursor1',
               20,
               15
      when '2'
        return 'Cursor1',
               20,
               15
      when '3'
        return 'Cursor1',
               20,
               15
      when '4'
        return 'Cursor1',
               20,
               15
      when '5'
        return 'Cursor1',
               20,
               15
      when '6'
        return 'Cursor1',
               20,
               15
      else
        return DEFAULT_ICON,
               DEFAULT_OFFSET_X,
               DEFAULT_OFFSET_Y
      end
    end
  end
end