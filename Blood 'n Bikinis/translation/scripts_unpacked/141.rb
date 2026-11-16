alias zeriab_patch_save_data save_data

def save_data(object, filename)
  begin
    # The salt used
    salt = System::SALT
    # Serialize the object
    raw_data = Marshal.dump(object)
    # Compress the data
    data = Zlib::Deflate.deflate(data)
    # Add the salt
    if data.length >= 12
      data[12] = (data[12] + salt) % 256
    else
      data[0] = (data[0] + salt) % 256
    end
    # Save the object
    zeriab_patch_save_data(data, filename)
  rescue
    # If something goes wrong, use normal save method
    return zeriab_patch_save_data(object, filename)
  end
end

