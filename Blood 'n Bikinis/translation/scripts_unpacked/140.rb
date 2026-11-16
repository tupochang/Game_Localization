alias zeriab_patch_load_data load_data

def load_data(filename)
  if FileTest.exist?(filename)
    # The salt used
    salt = System::SALT
    # Open the file
    file = File.open(filename, "rb")
    # Read the file as string
    data = file.read
    file.close
    # Remove the salt
    if data.length > 12
      data[12] = (data[12] - salt) % 256
    else
      data[0] = (data[0] - salt) % 256
    end
    # Decompress and load the object
    begin
      object = Marshal.load(Zlib::Inflate.inflate(data))
    rescue
      # Malformed file
      return zeriab_patch_load_data(filename)
    end
    # Return the object
    return object
  else
    return zeriab_patch_load_data(filename)
  end
end

