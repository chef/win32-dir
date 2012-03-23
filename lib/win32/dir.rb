require 'windows/directory'
require 'windows/shell'
require 'windows/file'
require 'windows/error'
require 'windows/device_io'
require 'windows/unicode'
require 'windows/directory'
require 'windows/handle'
require 'windows/path'
require 'windows/limits'
require 'windows/system_info'

class Dir
  include Windows::Directory
  include Windows::Shell
  include Windows::Error
  include Windows::File
  include Windows::DeviceIO
  include Windows::Limits

  extend Windows::Directory
  extend Windows::Shell
  extend Windows::File
  extend Windows::Error
  extend Windows::DeviceIO
  extend Windows::Unicode
  extend Windows::Handle
  extend Windows::Path
  extend Windows::Limits
  extend Windows::SystemInfo
   
  # The version of the win32-dir library.
  VERSION = '0.3.7'
   
  # Dynamically set each of the CSIDL_ constants
  constants.grep(/CSIDL/).each{ |constant|
    path   = 0.chr * MAXPATH
    nconst = constant.to_s.split('CSIDL_').last # to_s call for 1.9.x
      
    if SHGetFolderPath(0, const_get(constant), 0, 1, path) != 0
      path = nil
    else 
      path.strip!
    end

    # Try another approach for virtual folders
    if path.nil?
      ppidl = 0.chr * 4 # PIDLIST_ABSOLUTE

      if SHGetFolderLocation(0, const_get(constant), 0, 0, ppidl) == S_OK
        info = 0.chr * 692 # sizeof(SHFILEINFO)
        flags = SHGFI_DISPLAYNAME | SHGFI_PIDL
        SHGetFileInfo(ppidl.unpack('L')[0], 0, info, 692, flags)
        path = info[12..-1].strip
      end
    end

    Dir.const_set(nconst, path) if path
  }

  # Set Dir::MYDOCUMENTS to the same as Dir::PERSONAL if undefined
  unless defined? MYDOCUMENTS
    # Same as Dir::PERSONAL
    MYDOCUMENTS = PERSONAL
  end
   
  class << self
    remove_method :getwd
    remove_method :pwd
    alias :old_glob :glob
    alias :old_ref :[]
    remove_method :glob
    remove_method :[]
  end

  # Same as the standard MRI Dir.glob method except that it handles
  # backslashes in path names.
  #
  def self.glob(glob_pattern, flags = 0, &block)
    glob_pattern = glob_pattern.tr("\\", "/") 
    old_glob(glob_pattern, flags, &block)
  end

  # Same as the standard MRI Dir[] method except that it handles
  # backslashes in path names.
  #
  def self.[](glob_pattern)
    glob_pattern = glob_pattern.tr("\\", "/") 
    old_ref(glob_pattern)
  end
   
  # Returns the present working directory. Unlike MRI, this method always
  # normalizes the path.
  #
  # Examples:
  #
  #    Dir.chdir("C:/Progra~1")
  #    Dir.getwd # => C:\Program Files
  #
  #    Dir.chdir("C:/PROGRAM FILES")
  #    Dir.getwd # => C:\Program Files
  #
  def self.getwd
    path1 = 0.chr * MAXPATH
    path2 = 0.chr * MAXPATH
    path3 = 0.chr * MAXPATH

    GetCurrentDirectory(MAXPATH, path1)
    GetShortPathName(path1, path2, MAXPATH)
    GetLongPathName(path2, path3, MAXPATH)

    path3[/^[^\0]*/]
  end
   
  class << self
    alias :pwd :getwd
  end

  # Creates the symlink +to+, linked to the existing directory +from+. If the
  # +to+ directory already exists, it must be empty or an error is raised.
  #
  # Example:
  #
  #    Dir.mkdir('C:/from')
  #    Dir.create_junction('C:/to', 'C:/from')
  # 
  def self.create_junction(to, from)
    to   = to.tr(File::SEPARATOR, File::ALT_SEPARATOR)   # Normalize path
    from = from.tr(File::SEPARATOR, File::ALT_SEPARATOR) # Normalize path
      
    to_path    = 0.chr * MAXPATH
    from_path  = 0.chr * MAXPATH
    buf_target = 0.chr * MAXPATH
      
    length = GetFullPathName(from, from_path.size, from_path, 0)

    if length == 0
      raise StandardError, 'GetFullPathName() failed: ' + get_last_error
    else
      from_path = from_path[0..length-1]
    end
      
    length = GetFullPathName(to, to_path.size, to_path, 0)

    if length == 0
      raise StandardError, 'GetFullPathName() failed: ' + get_last_error
    else
      to_path = to_path[0..length-1]
    end

    # You can create a junction to a directory that already exists, so
    # long as it's empty.
    rv = CreateDirectory(to_path, 0)

    if rv == 0 && rv != ERROR_ALREADY_EXISTS
      raise StandardError, 'CreateDirectory() failed: ' + get_last_error
    end
      
    handle = CreateFile(
      to_path,
      GENERIC_READ | GENERIC_WRITE, 
      0,
      0,
      OPEN_EXISTING, 
      FILE_FLAG_OPEN_REPARSE_POINT | FILE_FLAG_BACKUP_SEMANTICS,
      0
    )
      
    if handle == INVALID_HANDLE_VALUE
      raise StandardError, 'CreateFile() failed: ' + get_last_error
    end 
      
    buf_target  = buf_target.split(0.chr).first
    buf_target  = "\\??\\" << from_path
    wide_string = multi_to_wide(buf_target)[0..-3]
      
    # REPARSE_JDATA_BUFFER
    rdb = [
      "0xA0000003L".hex,      # ReparseTag (IO_REPARSE_TAG_MOUNT_POINT)
      wide_string.size + 12,  # ReparseDataLength
      0,                      # Reserved
      0,                      # SubstituteNameOffset
      wide_string.size,       # SubstituteNameLength
      wide_string.size + 2,   # PrintNameOffset
      0,                      # PrintNameLength
      wide_string             # PathBuffer
    ].pack('LSSSSSSa' + (wide_string.size + 4).to_s)

    bytes = [0].pack('L')

    begin
      bool = DeviceIoControl(
        handle,
        CTL_CODE(FILE_DEVICE_FILE_SYSTEM, 41, METHOD_BUFFERED, 0),
        rdb,
        rdb.size,
        0,
        0,
        bytes,
        0
      )
         
      unless bool
        error = 'DeviceIoControl() failed: ' + get_last_error
        RemoveDirectory(to_path)
        raise error
      end
    ensure
      CloseHandle(handle)
    end
      
    self  
  end
   
  # Returns whether or not +path+ is empty.  Returns false if +path+ is not
  # a directory, or contains any files other than '.' or '..'.
  # 
  def self.empty?(path)
    PathIsDirectoryEmpty(path)
  end
   
  # Returns whether or not +path+ is a junction.
  # 
  def self.junction?(path)
    bool   = true
    attrib = GetFileAttributes(path)
      
    if attrib == INVALID_FILE_ATTRIBUTES ||
       attrib & FILE_ATTRIBUTE_DIRECTORY == 0 ||
       attrib & FILE_ATTRIBUTE_REPARSE_POINT == 0
    then
       bool = false
    end
      
    bool
  end 
   
  # Class level aliases
  #
  class << self
    alias reparse_dir? junction?
  end
end
