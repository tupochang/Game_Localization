


def exe?
    return true
end
  
class My_Error
  
  def self.error_log(error)
    # Nothing  
  end
  
end

def traduire(message, *params)

    reg = /^\#(\d+) ?/
    message.sub!(reg, "")

    return sprintf(message, *params)
end
  