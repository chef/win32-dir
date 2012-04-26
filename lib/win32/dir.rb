require 'ffi'

class Dir
  extend FFI::Library

  # The version of the win32-dir library.
  VERSION = '0.4.0'

  private

  typedef :ulong, :hwnd
  typedef :ulong, :dword
  typedef :ulong, :handle
  typedef :ulong, :hresult
  typedef :ushort, :word

  ffi_lib :shell32

  attach_function :SHGetFolderPathW, [:hwnd, :int, :handle, :dword, :buffer_out], :hresult
  attach_function :SHGetFolderLocation, [:hwnd, :int, :handle, :dword, :pointer], :hresult
  attach_function :SHGetFileInfo, [:ulong, :dword, :pointer, :uint, :uint], :ulong

  ffi_lib :shlwapi

  attach_function :PathIsDirectoryEmptyW, [:buffer_in], :bool

  ffi_lib :kernel32

  attach_function :CloseHandle, [:handle], :bool
  attach_function :CreateDirectoryW, [:buffer_in, :pointer], :bool
  attach_function :CreateFileW, [:buffer_in, :dword, :dword, :pointer, :dword, :dword, :handle], :handle
  attach_function :DeviceIoControl, [:handle, :dword, :pointer, :dword, :pointer, :dword, :pointer, :pointer], :bool
  attach_function :GetCurrentDirectoryW, [:dword, :buffer_out], :dword
  attach_function :GetFileAttributesW, [:buffer_in], :dword
  attach_function :GetLastError, [], :dword
  attach_function :GetShortPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_function :GetLongPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_function :GetFullPathNameW, [:buffer_in, :dword, :buffer_out, :pointer], :dword
  attach_function :RemoveDirectoryW, [:buffer_in], :bool

  # CSIDL constants
  csidl = Hash[
    'DESKTOP',                  0x0000,
    'INTERNET',                 0x0001,
    'PROGRAMS',                 0x0002,
    'CONTROLS',                 0x0003,
    'PRINTERS',                 0x0004,
    'PERSONAL',                 0x0005,
    'FAVORITES',                0x0006,
    'STARTUP',                  0x0007,
    'RECENT',                   0x0008,
    'SENDTO',                   0x0009,
    'BITBUCKET',                0x000a,
    'STARTMENU',                0x000b,
    'MYDOCUMENTS',              0x000c,
    'MYMUSIC',                  0x000d,
    'MYVIDEO',                  0x000e,
    'DESKTOPDIRECTORY',         0x0010,
    'DRIVES',                   0x0011,
    'NETWORK',                  0x0012,
    'NETHOOD',                  0x0013,
    'FONTS',                    0x0014,
    'TEMPLATES',                0x0015,
    'COMMON_STARTMENU',         0x0016,
    'COMMON_PROGRAMS',          0X0017,
    'COMMON_STARTUP',           0x0018,
    'COMMON_FAVORITES',         0x001f,
    'COMMON_DESKTOPDIRECTORY',  0x0019,
    'APPDATA',                  0x001a,
    'PRINTHOOD',                0x001b,
    'LOCAL_APPDATA',            0x001c,
    'ALTSTARTUP',               0x001d,
    'COMMON_ALTSTARTUP',        0x001e,
    'INTERNET_CACHE',           0x0020,
    'COOKIES',                  0x0021,
    'HISTORY',                  0x0022,
    'COMMON_APPDATA',           0x0023,
    'WINDOWS',                  0x0024,
    'SYSTEM',                   0x0025,
    'PROGRAM_FILES',            0x0026,
    'MYPICTURES',               0x0027,
    'PROFILE',                  0x0028,
    'SYSTEMX86',                0x0029,
    'PROGRAM_FILESX86',         0x002a,
    'PROGRAM_FILES_COMMON',     0x002b,
    'PROGRAM_FILES_COMMONX86',  0x002c,
    'COMMON_TEMPLATES',         0x002d,
    'COMMON_DOCUMENTS',         0x002e,
    'CONNECTIONS',              0x0031,
    'COMMON_MUSIC',             0x0035,
    'COMMON_PICTURES',          0x0036,
    'COMMON_VIDEO',             0x0037,
    'RESOURCES',                0x0038,
    'RESOURCES_LOCALIZED',      0x0039,
    'COMMON_OEM_LINKS',         0x003a,
    'CDBURN_AREA',              0x003b,
    'COMMON_ADMINTOOLS',        0x002f,
    'ADMINTOOLS',               0x0030
  ]

  class SHFILEINFO < FFI::Struct
    layout(
      :hIcon, :ulong,
      :iIcon, :int,
      :dwAttributes, :dword,
      :szDisplayName, [:char, 256],
      :szTypeName, [:char, 80]
    )
  end

  # I fudge a bit, assuming a MountPointReparseBuffer
  class REPARSE_JDATA_BUFFER < FFI::Struct
    layout(
      :ReparseTag, :ulong,
      :ReparseDataLength, :ushort,
      :Reserved, :ushort,
      :SubstituteNameOffset, :ushort,
      :SubstituteNameLength, :ushort,
      :PrintNameOffset, :ushort,
      :PrintNameLength, :ushort,
      :PathBuffer, :pointer
    )
  end

  # Dynamically set each of the CSIDL constants
  csidl.each{ |key, value|
    buf  = 0.chr * 1024
    path = nil
    buf.encode!('UTF-16LE')

    if SHGetFolderPathW(0, value, 0, 0, buf) == 0
      path = buf.strip
    else
      ptr   = FFI::MemoryPointer.new(:long)
      info  = SHFILEINFO.new
      flags = 520 # SHGFI_DISPLAYNAME | SHGFI_PIDL

      if SHGetFolderLocation(0, value, 0, 0, ptr) == 0
        if SHGetFileInfo(ptr.read_long, 0, info, info.size, flags) != 0
          path = info[:szDisplayName]
        end
      end
    end

    Dir.const_set(key, path) if path
  }

  # Set Dir::MYDOCUMENTS to the same as Dir::PERSONAL if undefined
  unless defined? MYDOCUMENTS
    # Same as Dir::PERSONAL
    MYDOCUMENTS = PERSONAL
  end

  class << self

    # Same as the standard MRI Dir.glob method except that it handles
    # backslashes in path names.
    #
    def glob(glob_pattern, flags = 0, &block)
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
    def getwd
      path1 = 0.chr * 1024
      path2 = 0.chr * 1024
      path3 = 0.chr * 1024

      path1.encode!('UTF-16LE')

      if GetCurrentDirectoryW(path1.size, path1) == 0
        raise SystemCallError, GetLastError(), "GetCurrentDirectoryW"
      end

      path2.encode!('UTF-16LE')

      if GetShortPathNameW(path1, path2, path2.size) == 0
        raise SystemCallError, GetLastError(), "GetShortPathNameW"
      end

      path3.encode!('UTF-16LE')

      if GetLongPathNameW(path2, path3, path3.size) == 0
        raise SystemCallError, GetLastError(), "GetLongPathNameW"
      end

      path3.strip
    end

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

    to_path    = 0.chr * 1024
    from_path  = 0.chr * 1024
    buf_target = 0.chr * 1024

    from_path.encode!('UTF-16LE')

    length = GetFullPathNameW(from.encode('UTF-16LE'), from_path.size, from_path, nil)

    if length == 0
      raise SystemCallError, GetLastError(), "GetFullPathNameW"
    else
      from_path.strip!
    end

    to_path.encode!('UTF-16LE')

    length = GetFullPathNameW(to.encode('UTF-16LE'), to_path.size, to_path, nil)

    if length == 0
      raise SystemCallError, GetLastError(), "GetFullPathNameW"
    else
      to_path.strip!
    end

    # You can create a junction to a directory that already exists, so
    # long as it's empty.
    rv = CreateDirectoryW(to_path, nil)

    if rv == 0 && rv != 183 # ERROR_ALREADY_EXISTS
      raise SystemCallError, GetLastError(), "CreateDirectoryW"
    end

    begin
      # Generic read & write + open existing + reparse point & backup semantics
      handle = CreateFileW(to_path, 3221225472, 0, nil, 3, 35651584, 0)

      if handle == 0xFFFFFFFF # INVALID_HANDLE_VALUE
        raise SystemCallError, GetLastError(), "CreateFileW"
      end

      target = "\\??\\".encode('UTF-16LE') << from_path

      rdb = REPARSE_JDATA_BUFFER.new
      rdb[:ReparseTag] = 2684354563 # IO_REPARSE_TAG_MOUNT_POINT
      rdb[:ReparseDataLength] = target.size + 12
      rdb[:Reserved] = 0
      rdb[:SubstituteNameOffset] = 0
      rdb[:SubstituteNameLength] = target.size
      rdb[:PrintNameOffset] = target.size + 2
      rdb[:PrintNameLength] = 0
      rdb[:PathBuffer] = FFI::MemoryPointer.from_string(target)

      bytes = FFI::MemoryPointer.new(:ulong)

      begin
        bool = DeviceIoControl(
          handle,
          CTL_CODE(9, 41, 0, 0),
          rdb,
          rdb.size,
          nil,
          0,
          bytes,
          nil
        )

        unless bool
          error = GetLastError()
          RemoveDirectoryW(to_path)
          raise SystemCallError, error, "DeviceIoControl"
        end
      ensure
        CloseHandle(handle)
      end
    end

    self
  end

  # Returns whether or not +path+ is empty.  Returns false if +path+ is not
  # a directory, or contains any files other than '.' or '..'.
  #
  def self.empty?(path)
    path = path << "\0"
    path = path.encode('UTF-16LE')
    PathIsDirectoryEmptyW(path)
  end

  # Returns whether or not +path+ is a junction.
  #
  def self.junction?(path)
    bool = true
    path = path << "\0"
    path.encode!('UTF-16LE')

    attrib = GetFileAttributesW(path)

    # Only directories with a reparse point attribute can be junctions
    if (attrib == 0xFFFFFFFF) || (attrib & 0x00000010 == 0) || (attrib & 0x00000400 == 0)
      bool = false
    end

    bool
  end

  # Class level aliases
  #
  class << self
    alias reparse_dir? junction?
  end

  private

  def self.CTL_CODE(device, function, method, access)
    ((device) << 16) | ((access) << 14) | ((function) << 2) | (method)
  end
end
