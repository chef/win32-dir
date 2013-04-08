# Necessary to force JRuby to use the gem, not its builtin version
if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Dir::Functions
  extend FFI::Library

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :uintptr_t, :hwnd
  typedef :pointer, :ptr

  ffi_lib :shell32

  attach_function :SHGetFolderPathW, [:hwnd, :int, :handle, :dword, :buffer_out], :dword
  attach_function :SHGetFolderLocation, [:hwnd, :int, :handle, :dword, :ptr], :dword
  attach_function :SHGetFileInfo, [:dword, :dword, :ptr, :uint, :uint], :dword

  ffi_lib :shlwapi

  attach_function :PathIsDirectoryEmptyW, [:buffer_in], :bool

  ffi_lib :kernel32

  attach_function :CloseHandle, [:handle], :bool
  attach_function :CreateDirectoryW, [:buffer_in, :ptr], :bool
  attach_function :CreateFileW, [:buffer_in, :dword, :dword, :ptr, :dword, :dword, :handle], :handle
  attach_function :DeviceIoControl, [:handle, :dword, :ptr, :dword, :ptr, :dword, :ptr, :ptr], :bool
  attach_function :GetCurrentDirectoryW, [:dword, :buffer_out], :dword
  attach_function :GetFileAttributesW, [:buffer_in], :dword
  attach_function :GetLastError, [], :dword
  attach_function :GetShortPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_function :GetLongPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_function :GetFullPathNameW, [:buffer_in, :dword, :buffer_out, :ptr], :dword
  attach_function :RemoveDirectoryW, [:buffer_in], :bool
end

class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  def wincode
    (self.tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
  end
end
