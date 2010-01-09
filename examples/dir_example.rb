####################################################################
# dir_example.rb
#
# Generic test script for general futzing.  Modify as you see fit.
# You can run this via the 'rake example' task.
####################################################################
require 'win32/dir'

puts "Admin Tools:\t\t" + Dir::ADMINTOOLS
puts "Common Admin Tools:\t" + Dir::COMMON_ADMINTOOLS
puts "App Data:\t\t" + Dir::APPDATA
puts "Common App Data:\t" + Dir::COMMON_APPDATA
puts "Common Documents:\t" + Dir::COMMON_DOCUMENTS
puts "Cookies:\t\t" + Dir::COOKIES
puts "History:\t\t" + Dir::HISTORY
puts "Internet Cache:\t\t" + Dir::INTERNET_CACHE
puts "Local App Data:\t\t" + Dir::LOCAL_APPDATA
puts "My Pictures:\t\t" + Dir::MYPICTURES
puts "Personal:\t\t" + Dir::PERSONAL
puts "Program Files:\t\t" + Dir::PROGRAM_FILES
puts "Program Files Common:\t" + Dir::PROGRAM_FILES_COMMON
puts "System:\t\t\t" + Dir::SYSTEM
puts "Windows:\t\t" + Dir::WINDOWS 