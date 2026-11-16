##
# Copyright (c) 2016 Zeriab
#
# This software is provided 'as-is', without any express or implied
# warranty. In no event will the authors be held liable for any damages
# arising from the use of this software.
# 
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
# 
# 1. The origin of this software must not be misrepresented; you must not
#    claim that you wrote the original software. If you use this software
#    in a product, an acknowledgement in the product documentation would be
#    appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
#    misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#
##
# usage: 
#   path = EnvUtil.get_path_from_env("APPDATA")
#
module EnvUtil
  THROW_ERRORS = true
  
  # Win32API bindings
  GetEnvironmentVariable = Win32API.new('Kernel32', 'GetEnvironmentVariableW', 'ppi', 'i')
  GetShortPathName = Win32API.new('Kernel32', 'GetShortPathNameW', 'ppi', 'i')
  GetLastError = Win32API.new('Kernel32', 'GetLastError', '', 'i')
  
  ##
  # Windows error codes
  #
  
  # The system cannot find the path specified.
  ERROR_PATH_NOT_FOUND = 3  
  # The system could not find the environment option that was entered.
  ERROR_ENVVAR_NOT_FOUND = 203

  module_function
  def get_shortpath_from_env(name)
    # Change to wide-chars with null-terminator
    array = name.split('')
    env_name = array.join("\0") + "\0\0\0"
    
    # Fetch path in wide-chars
    env_buffer = "\0" * 1024
    env_buffer_length = env_buffer.length - 1
    env_length = GetEnvironmentVariable.call(env_name, 
                                             env_buffer, 
                                             env_buffer_length)  
  
    # If the function fails for any other reason, the return value is zero
    if env_length <= 0
      return nil unless THROW_ERRORS
      raise :env_error, GetLastError.call()
    end
    
    # Try to retrieve the short path form of the specified path
    short_name_buffer = "\0" * 1024
    # Ensure the string will be null-terminated
    short_name_buffer_length = short_name_buffer.length - 1
    short_name_length = GetShortPathName.call(env_buffer,
                                              short_name_buffer, 
                                              short_name_buffer_length)
    
    # If the function fails for any other reason, the return value is zero
    if short_name_length <= 0
      return nil unless THROW_ERRORS
      raise :shortname_error, GetLastError.call()
    end
    
    # A short name confirming to the specification will only have left side of
    # the wide characters file. Following this we can convert the string into
    # UTF-8 by removing all null-terminators
    return short_name_buffer.gsub("\0", '')
  end
  
  def get_path_from_env(env_name)
    # Sanity check
    path = ENV[env_name]
    return nil if path.nil?
    
    # Some paths work without being converted to short path form
    return path if FileTest.exists?(path)
    
    # Try to fetch the short path from as a fallback
    return get_shortpath_from_env(env_name)
  end
end