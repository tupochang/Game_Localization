class Interpreter
  END_CHOICE_COMMENT = 'END_LABELFY'
  
  def label_counter
    @label_counter = 0 if @label_counter.nil?
    @label_counter += 1
  end
  
  ##
  # Labelfy until a comment with END_LABELFY is reached.
  # Exit Event Processing is used if no such comment is found.
  # Note: Only current page is checked.
  #
  def labelfy
    this_command = @list[@index]
    this_command.parameters[0] = @list.size
    this_command.code = 1102
    index = @index + 1
    label = nil
    while index < @list.size
      command = @list[index]
      if command.code == 108 &&
         command.parameters[0] == END_CHOICE_COMMENT
        label = index
        break
      end
      index += 1
    end
    if label.nil?
      _generate_exit_processing(@index+1)
    else
      _generate_labels(@index+1, label)
      this_command.parameters[0] = label
    end
    @index -= 1
    return
  end
  
  def _generate_exit_processing(index)
    while index < @list.size
      command = @list[index]
      command.code = 115 if command.code == 0
      index += 1
    end
  end
  
  def _generate_labels(index, label)
    label_name = "\000choice_label_#{label_counter}"
    @list[label].code = 118
    @list[label].parameters = [label_name]
    while index < label
      command = @list[index]
      if command.code == 0
        command.code = 119
        command.parameters = [label_name]
      end
      index += 1
    end
  end
  
  #--------------------------------------------------------------------------
  # * Show Text
  #--------------------------------------------------------------------------
  def command_101_simple
    # If other text has been set to message_text
    if $game_temp.message_text != nil
      # End
      return false
    end
#    # Set message end waiting flag and callback
#    @message_waiting = false
#    $game_temp.message_proc = Proc.new { @message_waiting = false }
    # Set message text on first line
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    line_count = 1
    # Loop
    loop do
      # If next event command text is on the second line or after
      if @list[@index+1].code == 401
        # Add the second line or after to message_text
        $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
        line_count += 1
      else
        return
      end
      # Advance index
      @index += 1
    end
  end
  
  unless method_defined?(:zeriab_multichoice_execute_command)
    alias_method :zeriab_multichoice_execute_command, :execute_command
  end
  #--------------------------------------------------------------------------
  # * Event Command Execution
  #--------------------------------------------------------------------------
  def execute_command
    # If select choices
    if @index < @list.size && @list[@index].code == 1102 # 102 is show choices
      select_choices(@list[@index].parameters[0])
    else
      zeriab_multichoice_execute_command
    end
  end
  ##
  # Collect choices until the given index number
  #
  def select_choices(label_number = @list.size)
    if @choice_index == @index
      # Update choice window
      @choice_window.update
      # Check if it is done
      if @choice_window.done?
        # Set the index to the one given by the choice window
        @index = @choice_window.index
        # Destroy the choice window
        @choice_window.dispose
        @choice_window = nil
        @choice_index = nil
        # Terminate window message
        window = $scene.instance_eval('@message_window')
        window.terminate_message if window.is_a?(Window)
        # Let's continue
        $game_map.need_refresh = true
        @wait_count = 1
        return true
      else
        # Let's wait
        return false
      end
    end
    @choice_index = @index
    # Store current parameters
    branch = @branch.dup
    index = @index
    parameters = @parameters
    @index += 1
    command_101_simple if @list[@index].code == 101
    choices = []
    indices = []
    last_cancel = nil
    while @index < label_number
      command = @list[@index]
      if command.code == 402
        choices << command.parameters[1] 
        indices << @index
      end
      if command.code == 403
        last_cancel = @index
      end
      if command.code == 111 || command.code == 411
        @parameters = command.parameters
        command.code == 111 ? command_111 : command_411
      end
      @index += 1
    end
    # Restore parameters
    @index = index
    @branch = branch
    @parameters = parameters
    # Make choice window
    if choices.empty?
      @choice_index = nil
      return true
    else
      @choice_window = Window_MultiChoice.new(choices, indices, last_cancel)
    end
    # Wait
    return false
  end
end
