# encoding: utf-8
###########################################################################
# test_win32_dir.rb
#
# Test suite for the win32-dir library.  You should run this test case
# via the 'rake test' task.
###########################################################################
require 'test-unit'
require 'win32/dir'
require 'tmpdir'
require 'fileutils'
require 'pathname'

class TC_Win32_Dir < Test::Unit::TestCase
  def self.startup
    @@java = RUBY_PLATFORM == 'java'
    @@temp = Dir.tmpdir
    @@from = File.join(@@temp, "test_from_directory")
    Dir.mkdir(@@from)
  end

  def setup
    @ascii_to   = File.join(@@temp, "test_to_directory")
    @unicode_to = File.join(@@temp, "Ελλάσ")
    @test_file  = File.join(@@from, "test.txt")
  end

  test "version number is set to expected value" do
    assert_equal('0.4.9', Dir::VERSION)
  end

  test 'glob handles backslashes' do
    pattern = "C:\\Program Files\\Common Files\\System\\*.dll"
    assert_nothing_raised{ Dir.glob(pattern) }
    assert_true(Dir.glob(pattern).size > 0)
  end

  test 'glob handles multiple strings' do
    pattern1 = "C:\\Program Files\\Common Files\\System\\*.dll"
    pattern2 = "C:\\Windows\\*.exe"
    assert_nothing_raised{ Dir.glob([pattern1, pattern2]) }
    assert_true(Dir.glob([pattern1, pattern2]).size > 0)
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

  test 'glob handles Pathname objects' do
    pattern1 = Pathname.new("C:\\Program Files\\Common Files\\System\\*.dll")
    pattern2 = Pathname.new("C:\\Windows\\*.exe")
    assert_nothing_raised{ Dir.glob([pattern1, pattern2]) }
    assert_true(Dir.glob([pattern1, pattern2]).size > 0)
  end

  test "glob requires a stringy argument" do
    assert_raise(TypeError){ Dir.glob(nil) }
  end

  test 'ref handles backslashes' do
    pattern = "C:\\Program Files\\Common Files\\System\\*.dll"
    assert_nothing_raised{ Dir[pattern] }
    assert_true(Dir[pattern].size > 0)
  end

  test 'ref handles multiple arguments' do
    pattern1 = "C:\\Program Files\\Common Files\\System\\*.dll"
    pattern2 = "C:\\Windows\\*.exe"
    assert_nothing_raised{ Dir[pattern1, pattern2] }
    assert_true(Dir[pattern1, pattern2].size > 0)
  end

  test 'ref handles pathname arguments' do
    pattern1 = Pathname.new("C:\\Program Files\\Common Files\\System\\*.dll")
    pattern2 = Pathname.new("C:\\Windows\\*.exe")
    assert_nothing_raised{ Dir[pattern1, pattern2] }
    assert_true(Dir[pattern1, pattern2].size > 0)
  end

  test "create_junction basic functionality" do
    assert_respond_to(Dir, :create_junction)
  end

  test "create_junction works as expected with ascii characters" do
    assert_nothing_raised{ Dir.create_junction(@ascii_to, @@from) }
    assert_true(File.exists?(@ascii_to))
    File.open(@test_file, 'w'){ |fh| fh.puts "Hello World" }
    assert_equal(Dir.entries(@@from), Dir.entries(@ascii_to))
  end

  test "create_junction works as expected with unicode characters" do
    assert_nothing_raised{ Dir.create_junction(@unicode_to, @@from) }
    assert_true(File.exists?(@unicode_to))
    File.open(@test_file, 'w'){ |fh| fh.puts "Hello World" }
    assert_equal(Dir.entries(@@from), Dir.entries(@unicode_to))
  end

  test "create_junction works as expected with pathname objects" do
    assert_nothing_raised{ Dir.create_junction(Pathname.new(@ascii_to), Pathname.new(@@from)) }
    assert_true(File.exists?(@ascii_to))
    File.open(@test_file, 'w'){ |fh| fh.puts "Hello World" }
    assert_equal(Dir.entries(@@from), Dir.entries(@ascii_to))
  end

  test "create_junction requires stringy arguments" do
    assert_raise(TypeError){ Dir.create_junction(nil, @@from) }
    assert_raise(TypeError){ Dir.create_junction(@ascii_to, nil) }
  end

  test "read_junction works as expected with ascii characters" do
    assert_nothing_raised{ Dir.create_junction(@ascii_to, @@from) }
    assert_true(File.exists?(@ascii_to))
    assert_equal(Dir.read_junction(@ascii_to), @@from)
  end

  test "read_junction works as expected with unicode characters" do
    assert_nothing_raised{ Dir.create_junction(@unicode_to, @@from) }
    assert_true(File.exists?(@unicode_to))
    assert_equal(Dir.read_junction(@unicode_to), @@from)
  end

  test "read_junction with unicode characters is joinable" do
    assert_nothing_raised{ Dir.create_junction(@unicode_to, @@from) }
    assert_true(File.exists?(@unicode_to))
    assert_nothing_raised{ File.join(Dir.read_junction(@unicode_to), 'foo') }
  end

  test "read_junction works as expected with pathname objects" do
    assert_nothing_raised{ Dir.create_junction(Pathname.new(@ascii_to), Pathname.new(@@from)) }
    assert_true(File.exists?(@ascii_to))
    assert_equal(Dir.read_junction(@ascii_to), @@from)
  end

  test "read_junction requires a stringy argument" do
    assert_raise(TypeError){ Dir.read_junction(nil) }
    assert_raise(TypeError){ Dir.read_junction([]) }
  end

  test "junction? method returns boolean value" do
    assert_respond_to(Dir, :junction?)
    assert_nothing_raised{ Dir.create_junction(@ascii_to, @@from) }
    assert_false(Dir.junction?(@@from))
    assert_true(Dir.junction?(@ascii_to))
    assert_true(Dir.junction?(Pathname.new(@ascii_to)))
  end

  test "reparse_dir? is an aliase for junction?" do
    assert_respond_to(Dir, :reparse_dir?)
    assert_true(Dir.method(:reparse_dir?) == Dir.method(:junction?))
  end

  test "empty? method returns expected result" do
    assert_respond_to(Dir, :empty?)
    assert_false(Dir.empty?("C:\\")) # One would think
    assert_true(Dir.empty?(@@from))
    assert_true(Dir.empty?(Pathname.new(@@from)))
  end

  test "pwd basic functionality" do
    omit_if(@@java)
    assert_respond_to(Dir, :pwd)
    assert_nothing_raised{ Dir.pwd }
    assert_kind_of(String, Dir.pwd)
  end

  test "pwd returns full path even if short path was just used" do
    omit_if(@@java)
    Dir.chdir("C:\\Progra~1")
    assert_equal("C:\\Program Files", Dir.pwd)
  end

  test "pwd returns full path if long path was just used" do
    omit_if(@@java)
    Dir.chdir("C:\\Program Files")
    assert_equal("C:\\Program Files", Dir.pwd)
  end

  test "pwd uses standard case conventions" do
    omit_if(@@java)
    Dir.chdir("C:\\PROGRAM FILES")
    assert_equal("C:\\Program Files", Dir.pwd)
  end

  test "pwd converts forward slashes to backslashes" do
    omit_if(@@java)
    Dir.chdir("C:/Program Files")
    assert_equal("C:\\Program Files", Dir.pwd)
  end

  test "pwd and getwd are aliases" do
    omit_if(@@java)
    assert_true(Dir.method(:getwd) == Dir.method(:pwd))
  end

  test "admintools constant is set" do
    assert_not_nil(Dir::ADMINTOOLS)
    assert_kind_of(String, Dir::ADMINTOOLS)
  end

  test "altstartup constant is set" do
    assert_not_nil(Dir::ALTSTARTUP)
    assert_kind_of(String, Dir::ALTSTARTUP)
  end

  test "appdata constant is set" do
    assert_not_nil(Dir::APPDATA)
    assert_kind_of(String, Dir::APPDATA)
  end

  test "bitbucket constant is set" do
    assert_not_nil(Dir::BITBUCKET)
    assert_kind_of(String, Dir::BITBUCKET)
  end

  test "cdburn area is set" do
    assert_not_nil(Dir::CDBURN_AREA)
    assert_kind_of(String, Dir::CDBURN_AREA)
  end

  test "common admintools is set" do
    assert_not_nil(Dir::COMMON_ADMINTOOLS)
    assert_kind_of(String, Dir::COMMON_ADMINTOOLS)
  end

  test "common_altstartup constant is set" do
    assert_not_nil(Dir::COMMON_ALTSTARTUP)
    assert_kind_of(String, Dir::COMMON_ALTSTARTUP)
  end

  test "common_appdata constant is set" do
    assert_not_nil(Dir::COMMON_APPDATA)
    assert_kind_of(String, Dir::COMMON_APPDATA)
  end

  test "common desktopdirectory constant is set" do
    assert_not_nil(Dir::COMMON_DESKTOPDIRECTORY)
    assert_kind_of(String, Dir::COMMON_DESKTOPDIRECTORY)
  end

  test "common_documents constant is set" do
    assert_not_nil(Dir::COMMON_DOCUMENTS)
    assert_kind_of(String, Dir::COMMON_DOCUMENTS)
  end

  test "common_favorites constant is set" do
    assert_not_nil(Dir::COMMON_FAVORITES)
    assert_kind_of(String, Dir::COMMON_FAVORITES)
  end

  test "common_music constant is set" do
    assert_not_nil(Dir::COMMON_MUSIC)
    assert_kind_of(String, Dir::COMMON_MUSIC)
  end

  test "common_pictures constant is set" do
    assert_not_nil(Dir::COMMON_PICTURES)
    assert_kind_of(String, Dir::COMMON_PICTURES)
  end

  test "common_programs constant is set" do
    assert_not_nil(Dir::COMMON_PROGRAMS)
    assert_kind_of(String, Dir::COMMON_PROGRAMS)
  end

  test "common_startmenu constant is set" do
    assert_not_nil(Dir::COMMON_STARTMENU)
    assert_kind_of(String, Dir::COMMON_STARTMENU)
  end

  test "common_startup constant is set" do
    assert_not_nil(Dir::COMMON_STARTUP)
    assert_kind_of(String, Dir::COMMON_STARTUP)
  end

  test "common_templates constant is set" do
    assert_not_nil(Dir::COMMON_TEMPLATES)
    assert_kind_of(String, Dir::COMMON_TEMPLATES)
  end

  test "common_video constant is set" do
    assert_not_nil(Dir::COMMON_VIDEO)
    assert_kind_of(String, Dir::COMMON_VIDEO)
  end

  test "controls constant is set" do
    assert_not_nil(Dir::CONTROLS)
    assert_kind_of(String, Dir::CONTROLS)
  end

  test "cookies constant is set" do
    assert_not_nil(Dir::COOKIES)
    assert_kind_of(String, Dir::COOKIES)
  end

  test "desktop constant is set" do
    assert_not_nil(Dir::DESKTOP)
    assert_kind_of(String, Dir::DESKTOP)
  end

  test "desktopdirectory is set" do
    assert_not_nil(Dir::DESKTOPDIRECTORY)
    assert_kind_of(String, Dir::DESKTOPDIRECTORY)
  end

  test "drives constant is set" do
    assert_not_nil(Dir::DRIVES)
    assert_kind_of(String, Dir::DRIVES)
  end

  test "favorites constant is set" do
    assert_not_nil(Dir::FAVORITES)
    assert_kind_of(String, Dir::FAVORITES)
  end

  test "fonts constant is set" do
    assert_not_nil(Dir::FONTS)
    assert_kind_of(String, Dir::FONTS)
  end

  test "history constant is set" do
    assert_not_nil(Dir::HISTORY)
    assert_kind_of(String, Dir::HISTORY)
  end

  test "internet constant is set" do
    assert_not_nil(Dir::INTERNET)
    assert_kind_of(String, Dir::INTERNET)
  end

  test "internet_cache constant is set" do
    assert_not_nil(Dir::INTERNET_CACHE)
    assert_kind_of(String, Dir::INTERNET_CACHE)
  end

  test "local_appdata constant is set" do
    assert_not_nil(Dir::LOCAL_APPDATA)
    assert_kind_of(String, Dir::LOCAL_APPDATA)
  end

  test "mydocuments constant is set" do
    assert_not_nil(Dir::MYDOCUMENTS)
    assert_kind_of(String, Dir::MYDOCUMENTS)
  end

  test "mymusic constant is set" do
    assert_not_nil(Dir::MYMUSIC)
    assert_kind_of(String, Dir::MYMUSIC)
  end

  test "mypictures constant is set" do
    assert_not_nil(Dir::MYPICTURES)
    assert_kind_of(String, Dir::MYPICTURES)
  end

  test "myvideo constant is set" do
    assert_not_nil(Dir::MYVIDEO)
    assert_kind_of(String, Dir::MYVIDEO)
  end

  test "nethood constant is set" do
    assert_not_nil(Dir::NETHOOD)
    assert_kind_of(String, Dir::NETHOOD)
  end

  test "network constant is set" do
    assert_not_nil(Dir::NETWORK)
    assert_kind_of(String, Dir::NETWORK)
  end

  test "personal constant is set" do
    assert_not_nil(Dir::PERSONAL)
    assert_kind_of(String, Dir::PERSONAL)
  end

  test "printers cosntant is set" do
    assert_not_nil(Dir::PRINTERS)
    assert_kind_of(String, Dir::PRINTERS)
  end

  test "printhood constant is set" do
    assert_not_nil(Dir::PRINTHOOD)
    assert_kind_of(String, Dir::PRINTHOOD)
  end

  test "profile constant is set" do
    assert_not_nil(Dir::PROFILE)
    assert_kind_of(String, Dir::PROFILE)
  end

  test "program_files constant is set" do
    assert_not_nil(Dir::PROGRAM_FILES)
    assert_kind_of(String, Dir::PROGRAM_FILES)
  end

  test "program_files_common constant is set" do
    assert_not_nil(Dir::PROGRAM_FILES_COMMON)
    assert_kind_of(String, Dir::PROGRAM_FILES_COMMON)
  end

  test "programs constant is set" do
    assert_not_nil(Dir::PROGRAMS)
    assert_kind_of(String, Dir::PROGRAMS)
  end

  test "recent constant is set" do
    assert_not_nil(Dir::RECENT)
    assert_kind_of(String, Dir::RECENT)
  end

  test "sendto constant is set" do
    assert_not_nil(Dir::SENDTO)
    assert_kind_of(String, Dir::SENDTO)
  end

  test "startmenu constant is set" do
    assert_not_nil(Dir::STARTMENU)
    assert_kind_of(String, Dir::STARTMENU)
  end

  test "startup constant is set" do
    assert_not_nil(Dir::STARTUP)
    assert_kind_of(String, Dir::STARTUP)
  end

  test "system constant is set" do
    assert_not_nil(Dir::SYSTEM)
    assert_kind_of(String, Dir::SYSTEM)
  end

  test "templates constant is set" do
    assert_not_nil(Dir::TEMPLATES)
    assert_kind_of(String, Dir::TEMPLATES)
  end

  test "windows constant is set" do
    assert_not_nil(Dir::WINDOWS)
    assert_kind_of(String, Dir::WINDOWS)
  end

  test "constants are ascii_compatible?" do
    assert_true(Dir::COMMON_APPDATA.encoding.ascii_compatible?)
    assert_nothing_raised{ File.join(Dir::COMMON_APPDATA, 'foo') }
  end

  test "ffi functions are private" do
    assert_not_respond_to(Dir, :SHGetFolderPathW)
  end

  def teardown
    FileUtils.rm_rf(@ascii_to)
    FileUtils.rm_rf(@unicode_to)
  end

  def self.shutdown
    FileUtils.rm_rf(@@from)
    @@test_home = nil
    @@from = nil
  end
end
