class StringBuffer < IO
   MODE_STRING = 1
   MODE_FILE_MARSHAL = 2
   MODE_FILE_BINMODE = 3
   ##
   # Initialization of the String Buffer
   # The mode can be MODE_STRING, MODE_FILE_MARSHAL or MODE_FILE_BINMODE
   #
   def initialize(data = nil, mode = MODE_FILE_MARSHAL, compressed = true)
     if data.nil?
       @data = ''
     else
       # Check which type the data is
       case mode
       when MODE_STRING
         @data = data
       when MODE_FILE_MARSHAL
         begin
           @data = load_data(data)
         rescue
           @data = ''
         end
       when MODE_FILE_BINMODE
         if FileTest.exists?(data)
           f = File.open(data, 'rb')
           f.binmode
           @data = f.read
           f.close
         end
       end
       # Decompress the data if it is compressed
       if compressed
         @data = Zlib::Inflate.inflate(@data)
       end
     end
   end
  
   ##
   # Save to file
   # The mode can be MODE_FILE_MARSHAL or MODE_FILE_BINMODE
   #
   def save(filename, mode = MODE_FILE_MARSHAL, compress = true)
     # Check whether the data should be compressed
     if compress
       data = Zlib::Deflate.deflate(@data)
     else
       data = @data
     end
     # Check whether to save in binary or marshal mode
     case mode
     when MODE_FILE_MARSHAL
       save_data(data, filename)
     when MODE_FILE_BINMODE
       f = File.open(filename, 'w+')
       f.binmode
       f.print data
       f.close
     end
   end

   ##
   # Get data
   #
   def data
     return @data
   end
  
   ##
   # Binary mode
   #
   def binmode
     # Do nothing
   end
  
   ##
   # Write data
   #
   def write(data)
     @data += data
   end
  
   ##
   # Get char
   #
   def getc
     return @data.slice!(0)
   end
  
   ##
   # Read an amount of bytes
   #
   def read(amount)
     return @data.slice!(0...amount)
   end
end