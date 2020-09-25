# Necessary to force JRuby to use the gem, not its builtin version
if RUBY_PLATFORM == "java"
  require "rubygems" unless defined?(Gem)
  gem "ffi"
end

require "ffi" unless defined?(FFI)

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
  ffi_convention :stdcall

  attach_pfunc :SHGetFolderPathW, %i{hwnd int handle dword buffer_out}, :dword
  attach_pfunc :SHGetFolderLocation, %i{hwnd int handle dword ptr}, :dword
  attach_pfunc :SHGetFileInfo, %i{uint64 dword ptr uint uint}, :dword

  ffi_lib :shlwapi
  ffi_convention :stdcall

  attach_pfunc :PathIsDirectoryEmptyW, [:buffer_in], :bool

  ffi_lib :kernel32
  ffi_convention :stdcall

  attach_pfunc :CloseHandle, [:handle], :bool
  attach_pfunc :CreateDirectoryW, %i{buffer_in ptr}, :bool
  attach_pfunc :CreateFileW, %i{buffer_in dword dword ptr dword dword handle}, :handle
  attach_pfunc :DeviceIoControl, %i{handle dword ptr dword ptr dword ptr ptr}, :bool
  attach_pfunc :GetCurrentDirectoryW, %i{dword buffer_out}, :dword
  attach_pfunc :GetFileAttributesW, [:buffer_in], :dword
  attach_pfunc :GetLastError, [], :dword
  attach_pfunc :GetShortPathNameW, %i{buffer_in buffer_out dword}, :dword
  attach_pfunc :GetLongPathNameW, %i{buffer_in buffer_out dword}, :dword
  attach_pfunc :GetFullPathNameW, %i{buffer_in dword buffer_out ptr}, :dword
  attach_pfunc :RemoveDirectoryW, [:buffer_in], :bool
end

class String
  # Convenience method for converting strings to UTF-16LE for wide character
  # functions that require it.
  def wincode
    (tr(File::SEPARATOR, File::ALT_SEPARATOR) + 0.chr).encode("UTF-16LE")
  end

  # Read a wide character string up until the first double null, and delete
  # any remaining null characters.
  def wstrip
    force_encoding("UTF-16LE").encode("UTF-8", invalid: :replace, undef: :replace)
      .split("\x00")[0].encode(Encoding.default_external)
  end
end
