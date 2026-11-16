#=begin
unless $f12_cleaner_F3XXEFA1.nil?
  # Opens the game executable in a new thread
   Thread.new{system ("Dreamscape")}  # "Game" = Name of the game executable
  # Exits this thread
  exit
end

# Modifying this global variable might cause this snippet to stop working properly.
# Some garbage have been added to lessen the chance of it already being used
$f12_cleaner_F3XXEFA1 = true
#=end