# encoding: utf-8
###########################################################################
# test_win32_dir.rb
#
# Test suite for the win32-dir library.  You should run this test case
# via the 'rake test' task.
###########################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'win32/dir'
require 'fileutils'

class TC_Win32_Dir < Test::Unit::TestCase
  def self.startup
    @@test_home = File.dirname(File.expand_path(__FILE__))
  end

  def setup
    Dir.chdir(@@test_home) unless File.basename(Dir.pwd) == 'test'
    @@from = File.join(Dir.pwd, "test_from_directory")

    @ascii_to   = "test_to_directory"
    @unicode_to = "Ελλάσ" # Greek - the word is 'Hellas'
    @test_file  = File.join(@@from, "test.txt")
    Dir.mkdir(@@from)
  end
   
  def test_version
    assert_equal('0.3.7', Dir::VERSION)
  end

  test 'glob handles backslashes' do
    pattern = "C:\\Program Files\\Common Files\\System\\*.dll"
    assert_nothing_raised{ Dir.glob(pattern) }
    assert_true(Dir.glob(pattern).size > 0)
  end

  test 'glob still observes flags' do
    assert_nothing_raised{ Dir.glob('*', File::FNM_DOTMATCH ) }
    assert_true(Dir.glob('*', File::FNM_DOTMATCH).include?('.'))
  end

  test 'glob still honors block' do
    array = []
    assert_nothing_raised{ Dir.glob('*', File::FNM_DOTMATCH ){ |m| array << m } }
    assert_true(array.include?('.'))
  end

  test 'ref handles backslashes' do
    pattern = "C:\\Program Files\\Common Files\\System\\*.dll"
    assert_nothing_raised{ Dir[pattern] }
    assert_true(Dir[pattern].size > 0)
  end
  
  def test_create_junction_basic
    assert_respond_to(Dir, :create_junction)
  end

  def test_create_junction_ascii
    assert_nothing_raised{ Dir.create_junction(@ascii_to, @@from) }
    assert_true(File.exists?(@ascii_to))
    File.open(@test_file, 'w'){ |fh| fh.puts "Hello World" }
    assert_equal(Dir.entries(@@from), Dir.entries(@ascii_to))
  end

  def test_create_junction_unicode
    assert_nothing_raised{ Dir.create_junction(@unicode_to, @@from) }
    assert_true(File.exists?(@unicode_to))
    File.open(@test_file, 'w'){ |fh| fh.puts "Hello World" }
    assert_equal(Dir.entries(@@from), Dir.entries(@unicode_to))
  end
   
  def test_is_junction
    assert_respond_to(Dir, :junction?)
    assert_nothing_raised{ Dir.create_junction(@ascii_to, @@from) }
    assert_equal(false, Dir.junction?(@@from))
    assert_equal(true, Dir.junction?(@ascii_to))
  end

  def test_reparse_dir_alias
    assert_respond_to(Dir, :reparse_dir?) # alias
    assert_equal(true, Dir.method(:reparse_dir?) == Dir.method(:junction?))
  end
   
  def test_is_empty
    assert_respond_to(Dir, :empty?)
    assert_equal(false, Dir.empty?("C:\\")) # One would think
    assert_equal(true, Dir.empty?(@@from))
  end

  def test_pwd_basic
    assert_respond_to(Dir, :pwd)
    assert_nothing_raised{ Dir.pwd }
    assert_kind_of(String, Dir.pwd)
  end

  def test_pwd_short_path
    Dir.chdir("C:\\Progra~1")
    assert_equal("C:\\Program Files", Dir.pwd)
  end

  def test_pwd_long_path
    Dir.chdir("C:\\Program Files")
    assert_equal("C:\\Program Files", Dir.pwd)
  end
 
  def test_pwd_caps
    Dir.chdir("C:\\PROGRAM FILES")
    assert_equal("C:\\Program Files", Dir.pwd)
  end
   
  def test_pwd_forward_slash
    Dir.chdir("C:/Program Files")
    assert_equal("C:\\Program Files", Dir.pwd)
  end
   
  def test_pwd_is_proper_alias
    assert_true(Dir.method(:getwd) == Dir.method(:pwd))
  end

  def test_admintools
    assert_not_nil(Dir::ADMINTOOLS)
    assert_kind_of(String, Dir::ADMINTOOLS)
  end
   
  def test_altstartup
    assert_not_nil(Dir::ALTSTARTUP)
    assert_kind_of(String, Dir::ALTSTARTUP)
  end
   
  def test_appdata
    assert_not_nil(Dir::APPDATA)
    assert_kind_of(String, Dir::APPDATA)
  end
   
  def test_bitbucket
    assert_not_nil(Dir::BITBUCKET)
    assert_kind_of(String, Dir::BITBUCKET)
  end
   
  def test_cdburn_area
    assert_not_nil(Dir::CDBURN_AREA)
    assert_kind_of(String, Dir::CDBURN_AREA)
  end
   
  def test_common_admintools
    assert_not_nil(Dir::COMMON_ADMINTOOLS)
    assert_kind_of(String, Dir::COMMON_ADMINTOOLS)
  end
   
  def test_common_altstartup
    assert_not_nil(Dir::COMMON_ALTSTARTUP)
    assert_kind_of(String, Dir::COMMON_ALTSTARTUP)
  end
   
  def test_common_appdata
    assert_not_nil(Dir::COMMON_APPDATA)
    assert_kind_of(String, Dir::COMMON_APPDATA)
  end
   
  def test_common_desktopdirectory
    assert_not_nil(Dir::COMMON_DESKTOPDIRECTORY)
    assert_kind_of(String, Dir::COMMON_DESKTOPDIRECTORY)
  end
   
  def test_common_documents
    assert_not_nil(Dir::COMMON_DOCUMENTS)
    assert_kind_of(String, Dir::COMMON_DOCUMENTS)
  end
   
  def test_common_favorites
    assert_not_nil(Dir::COMMON_FAVORITES)
    assert_kind_of(String, Dir::COMMON_FAVORITES)
  end
   
  def test_common_music
    assert_not_nil(Dir::COMMON_MUSIC)
    assert_kind_of(String, Dir::COMMON_MUSIC)
  end
   
  def test_common_pictures
    assert_not_nil(Dir::COMMON_PICTURES)
    assert_kind_of(String, Dir::COMMON_PICTURES)
  end
   
  def test_common_programs
    assert_not_nil(Dir::COMMON_PROGRAMS)
    assert_kind_of(String, Dir::COMMON_PROGRAMS)
  end
  
  def test_common_startmenu
    assert_not_nil(Dir::COMMON_STARTMENU)
    assert_kind_of(String, Dir::COMMON_STARTMENU)
  end
   
  def test_common_startup
    assert_not_nil(Dir::COMMON_STARTUP)
    assert_kind_of(String, Dir::COMMON_STARTUP)
  end
  
  def test_common_templates
    assert_not_nil(Dir::COMMON_TEMPLATES)
    assert_kind_of(String, Dir::COMMON_TEMPLATES)
  end
   
  def test_common_video
    assert_not_nil(Dir::COMMON_VIDEO)
    assert_kind_of(String, Dir::COMMON_VIDEO)
  end
   
  def test_controls
    assert_not_nil(Dir::CONTROLS)
    assert_kind_of(String, Dir::CONTROLS)
  end
   
  def test_cookies
    assert_not_nil(Dir::COOKIES)
    assert_kind_of(String, Dir::COOKIES)
  end
   
  def test_desktop
    assert_not_nil(Dir::DESKTOP)
    assert_kind_of(String, Dir::DESKTOP)
  end
   
  def test_desktopdirectory
    assert_not_nil(Dir::DESKTOPDIRECTORY)
    assert_kind_of(String, Dir::DESKTOPDIRECTORY)
  end
   
  def test_drives
    assert_not_nil(Dir::DRIVES)
    assert_kind_of(String, Dir::DRIVES)
  end

  def test_favorites
    assert_not_nil(Dir::FAVORITES)
    assert_kind_of(String, Dir::FAVORITES)
  end
   
  def test_fonts
    assert_not_nil(Dir::FONTS)
    assert_kind_of(String, Dir::FONTS)
  end
   
  def test_history
    assert_not_nil(Dir::HISTORY)
    assert_kind_of(String, Dir::HISTORY)
  end
   
  def test_internet
    assert_not_nil(Dir::INTERNET)
    assert_kind_of(String, Dir::INTERNET)
  end
   
  def test_internet_cache
    assert_not_nil(Dir::INTERNET_CACHE)
    assert_kind_of(String, Dir::INTERNET_CACHE)
  end
   
  def test_local_appdata
    assert_not_nil(Dir::LOCAL_APPDATA)
    assert_kind_of(String, Dir::LOCAL_APPDATA)
  end
   
  def test_mydocuments
    assert_not_nil(Dir::MYDOCUMENTS)
    assert_kind_of(String, Dir::MYDOCUMENTS)
  end
   
  def test_local_mymusic
    assert_not_nil(Dir::MYMUSIC)
    assert_kind_of(String, Dir::MYMUSIC)
  end
   
  def test_local_mypictures
    assert_not_nil(Dir::MYPICTURES)
    assert_kind_of(String, Dir::MYPICTURES)
  end
   
  def test_local_myvideo
    assert_not_nil(Dir::MYVIDEO)
    assert_kind_of(String, Dir::MYVIDEO)
  end
   
  def test_nethood
    assert_not_nil(Dir::NETHOOD)
    assert_kind_of(String, Dir::NETHOOD)
  end
   
  def test_network
    assert_not_nil(Dir::NETWORK)
    assert_kind_of(String, Dir::NETWORK)
  end

  def test_personal
    assert_not_nil(Dir::PERSONAL)
    assert_kind_of(String, Dir::PERSONAL)
  end
   
  def test_printers
    assert_not_nil(Dir::PRINTERS)
    assert_kind_of(String, Dir::PRINTERS)
  end
   
  def test_printhood
    assert_not_nil(Dir::PRINTHOOD)
    assert_kind_of(String, Dir::PRINTHOOD)
  end
   
  def test_profile
    assert_not_nil(Dir::PROFILE)
    assert_kind_of(String, Dir::PROFILE)
  end
   
  # Doesn't appear to actually exist
  #def test_profiles
  #  assert_not_nil(Dir::PROFILES)
  #  assert_kind_of(String,Dir::PROFILES)
  #end
   
  def test_program_files
    assert_not_nil(Dir::PROGRAM_FILES)
    assert_kind_of(String, Dir::PROGRAM_FILES)
  end
   
  def test_program_files_common
    assert_not_nil(Dir::PROGRAM_FILES_COMMON)
    assert_kind_of(String, Dir::PROGRAM_FILES_COMMON)
  end
   
  def test_programs
    assert_not_nil(Dir::PROGRAMS)
    assert_kind_of(String, Dir::PROGRAMS)
  end
   
  def test_recent
    assert_not_nil(Dir::RECENT)
    assert_kind_of(String, Dir::RECENT)
  end
  
  def test_sendto
    assert_not_nil(Dir::SENDTO)
    assert_kind_of(String, Dir::SENDTO)
  end
   
  def test_startmenu
    assert_not_nil(Dir::STARTMENU)
    assert_kind_of(String, Dir::STARTMENU)
  end
   
  def test_startup
    assert_not_nil(Dir::STARTUP)
    assert_kind_of(String, Dir::STARTUP)
  end
   
  def test_system
    assert_not_nil(Dir::SYSTEM)
    assert_kind_of(String, Dir::SYSTEM)
  end
   
  def test_templates
    assert_not_nil(Dir::TEMPLATES)
    assert_kind_of(String, Dir::TEMPLATES)
  end

  def test_windows_dir
    assert_not_nil(Dir::WINDOWS)
    assert_kind_of(String, Dir::WINDOWS)
  end

  def teardown
    FileUtils.rm_rf(@ascii_to)
    FileUtils.rm_rf(@unicode_to)
    FileUtils.rm_rf(@@from)
  end
end
