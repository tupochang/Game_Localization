

class String



  def dernier
    return self.last
  end

  def last(nb=1)
    return self[self.size-nb...self.size]
  end

  def first
    return self[0..0]
  end

  def to(nb=0)
    return self[0..nb]
  end

  def from(nb=0)
    return self[nb...self.size]
  end

  def delete_reg(reg)
    return self.gsub(reg, '')
  end

  def delete_reg!(reg)
    return self.gsub!(reg, '')
  end



  def premier
    return self.first
  end


  def egal_court(str)
    return egal_short(str)
  end


  def egal_short(str)
    if self.size > str.size
      return self[0...str.size] == str
    else
      return str[0...self.size] == self
    end
  end



  def just(nb=0)
    return " "*nb+self
  end


  def just_lines(nb=0)
    lines = self.split("\n")
    lines.collect!{|line|
      line = " "*nb+line
    }
    lines << ""
    return lines.join("\n")

  end


  def basename
    return File.basename(self)
  end

  def real_basename
    dirname = self.dirname
    real = from(dirname.size)
    real.shift! if real.first == "/"
    return real
  end


  def dirname
    return File.dirname(self)
  end

  def extname
    return File.extname(self)
  end

  def join(*strings)
    return File.join(self, *strings)
  end
  

  def pop!
    return self if self.size == 0
    str = self[0...self.size-1]
    last = self.last
    self.replace(str)
    return last
  end

  def shift!
    return self if self.size == 0
    str = self[1...self.size]
    first = self.first
    self.replace(str)
    return first
  end

  def pop
    str = self.clone
    return str.pop!
  end


  def shift
    str = self.clone
    return str.shift!
  end



  def regexp_egal(*regs)
    for reg in regs
      return true if reg.match(self) != nil
    end
    return false
  end


  def add_max(word, max)

    if self.size+word.size > max
      return self+word
    end

    return self+" "*(max-self.size-word.size)+word

  end

  def subreg(reg, str)


    str2 = str.gsub(/\$(\d)/){'"+'+$&+'+"'}
    if str2.to(1) == '"+'
      str2 = str2.from(2)
    else
      str2 = '"' + str2
    end
    if str2.last(2) == '+"'
      str2.pop!
      str2.pop!
    else
      str2 = str2+'"'
    end

    str2.gsub!(/\+""\+/, '+')

 

    t = self.gsub(reg){eval str2}

  end


  def valid_file_name
    return self.dirname.join(self.basename.gsub(/[:\*"?<>|\/\\]/, ''))

  end
  #subreg //, "$1$2zz"
  #subreg //, "zz$1$2"

  
  def split_byte
    arr = []
    self.each_byte{|x|
      arr << x
    }
    return arr
  end


  def convert_utf8


    num = self.unpack("C*")

    return "" if num.size == 0

    new_phrase = ""
    old_pos = 0
    for i in 0...num.size
      if num[i] >= 192
        #new_phrase += phrase[old_pos...i]+"\303\\#{num[i]-64}"
        new_phrase += self[old_pos...i]+"\303"+[(self[i..i].unpack('C'))[0]-64].pack('C')
        old_pos = i+1
        next
      end
    end
    new_phrase += self[old_pos..i]

    return new_phrase

  end



  def convert_ansi


    return "" if self == ""

    num = self.unpack("C*")
    #p num

    new_phrase = ""
    old_pos = 0
    for i in 0...num.size
      if num[i] == 195
        #new_phrase += phrase[old_pos...i]+"\303\\#{num[i]-64}"
        new_phrase += self[old_pos...i]+[(self[i+1..i+1].unpack('C'))[0]+64].pack('C')
        old_pos = i+2
      else
        if num[i] == 194
          #puts "194 !"
          new_phrase += self[old_pos...i]+[(self[i+1..i+1].unpack('C'))[0]].pack('C')
          old_pos = i+2
        end
      end
    end
    new_phrase += self[old_pos..i]

    return new_phrase

  end


  def to_bit
    return self.force_encoding("ASCII-8BIT")
  end

  def to_hex
    txt = ""
    self.each_byte{|x|
      txt << (" %02x" % x).upcase
    }
    return txt

  end

  def to_byte
    txt = ""
    self.each_byte{|x|
      txt << ("\\%03i" % x)
    }
    return txt

  end

  def b
    return to_byte
  end

end
