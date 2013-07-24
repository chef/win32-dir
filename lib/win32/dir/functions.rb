# Necessary to force JRuby to use the gem, not its builtin version
if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Dir::Functions
  module FFI::Library
    # Wrapper method for attach_function + private
    def attach_pfunc(*args)
      attach_function(*args)
      private args[0]
    end
  end

  extend FFI::Library

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :uintptr_t, :hwnd
  typedef :pointer, :ptr

  ffi_lib :shell32

  attach_pfunc :SHGetFolderPathW, [:hwnd, :int, :handle, :dword, :buffer_out], :dword
  attach_pfunc :SHGetFolderLocation, [:hwnd, :int, :handle, :dword, :ptr], :dword
  attach_pfunc :SHGetFileInfo, [:dword, :dword, :ptr, :uint, :uint], :dword

  ffi_lib :shlwapi

  attach_pfunc :PathIsDirectoryEmptyW, [:buffer_in], :bool

  ffi_lib :kernel32

  attach_pfunc :CloseHandle, [:handle], :bool
  attach_pfunc :CreateDirectoryW, [:buffer_in, :ptr], :bool
  attach_pfunc :CreateFileW, [:buffer_in, :dword, :dword, :ptr, :dword, :dword, :handle], :handle
  attach_pfunc :DeviceIoControl, [:handle, :dword, :ptr, :dword, :ptr, :dword, :ptr, :ptr], :bool
  attach_pfunc :GetCurrentDirectoryW, [:dword, :buffer_out], :dword
  attach_pfunc :GetFileAttributesW, [:buffer_in], :dword
  attach_pfunc :GetLastError, [], :dword
  attach_pfunc :GetShortPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_pfunc :GetLongPathNameW, [:buffer_in, :buffer_out, :dword], :dword
  attach_pfunc :GetFullPathNameW, [:buffer_in, :dword, :buffer_out, :ptr], :dword
  attach_pfunc :RemoveDirectoryW, [:buffer_in], :bool
end

class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  def wincode
    (self.tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode('UTF-16LE')
  end
end
