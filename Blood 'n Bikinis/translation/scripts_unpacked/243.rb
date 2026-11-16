

class King_RMXP
  

  def self.chemin(backtrace)
    
    liste = []
    for back in backtrace
      m = back.scan(/(\d+):(\d+).+`(.+)'|(\d+):(\d+)/)
      if m.size > 0
        liste.push(m[0].compact!)
      else
        liste.push(back)
      end
    end

    @nums = []
    
    liste.each{|x|
      @nums.push(x[0].to_i)
    }
    

    path = "Data/Scripts.rxdata"
    scripts = DA::marshal_read(path)
    

    message = ""
    
    for i in 0...@nums.size

      message << "from #{scripts[@nums[i]][1]} (#{liste[i][1]}) in #{liste[i][2]}\n"
    end
    
    message = message[0...message.size-5]
    

    return message
    
  end
  

  def self.erreur_log(erreur)
    DA::file_write("erreur_log.txt", erreur)
  end
end