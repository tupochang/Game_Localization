if FileTest.exist?('Data/Scripts.rxdata')
  # The salt used
  salt = 162
  # Open the file
  file = File.open('Data/Scripts.rxdata', "rb")
  # Read the file as string
  data = file.read
  file.close
  # Remove the salt
  if data.length >= 12
    data[12] = (data[12] - salt) % 256
  else
    data[0] = (data[0] - salt) % 256
  end
  # Decompress and load the object
  begin
    scripts = Marshal.load(Zlib::Inflate.inflate(data))
    # Remove the first script (Script Updater)
    scripts.shift
    # Decompress and evaluate the scripts
    for tuple in scripts
      script = Zlib::Inflate.inflate(tuple[2])
      eval(script)
    end
    # Exit the game
    exit
  rescue
    # Malformed file => Do nothing
  end
end