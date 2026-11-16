


class My_Exception < Exception


  def mot
    return "Exception"
  end

  @@SYMBOL = "*"

  def initialize(*args)
    #p @@MESSAGE, args
    trd = traduire(@MESSAGE, *args)
    @exception = "#{self.mot} #{self.class} #{@@SYMBOL}#{@NUMERO}#{@@SYMBOL} : \n".just_lines(2)+trd.just_lines(4)
  end

  def message
    return @exception
  end



end




class My_Error < My_Exception

  attr_accessor :error

  def initialize(*args)
    if args.last != nil
      @error = args.last.clone
    else
      @error = nil
    end
    #p self, args
    My_Error::error_log(self)
    super(*args[0...args.size-1])
    #puts message
  end

  def mot
    return "ERROR"
  end

end



class My_Warning < My_Exception

  def mot
    return "Warning"
  end


end

