# Necessary to force JRuby to use the gem, not its builtin version
if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Dir::Functions
  extend FFI::Library

  ffi_lib :shell32

  attach_function :SHGetFolderPathW, [:ulong, :int, :ulong, :ulong, :buffer_out], :ulong
  attach_function :SHGetFolderLocation, [:ulong, :int, :ulong, :ulong, :pointer], :ulong
  attach_function :SHGetFileInfo, [:ulong, :ulong, :pointer, :uint, :uint], :ulong

  ffi_lib :shlwapi

  attach_function :PathIsDirectoryEmptyW, [:buffer_in], :bool

  ffi_lib :kernel32

  attach_function :CloseHandle, [:ulong], :bool
  attach_function :CreateDirectoryW, [:buffer_in, :pointer], :bool
  attach_function :CreateFileW, [:buffer_in, :ulong, :ulong, :pointer, :ulong, :ulong, :ulong], :ulong
  attach_function :DeviceIoControl, [:ulong, :ulong, :pointer, :ulong, :pointer, :ulong, :pointer, :pointer], :bool
  attach_function :GetCurrentDirectoryW, [:ulong, :buffer_out], :ulong
  attach_function :GetFileAttributesW, [:buffer_in], :ulong
  attach_function :GetLastError, [], :ulong
  attach_function :GetShortPathNameW, [:buffer_in, :buffer_out, :ulong], :ulong
  attach_function :GetLongPathNameW, [:buffer_in, :buffer_out, :ulong], :ulong
  attach_function :GetFullPathNameW, [:buffer_in, :ulong, :buffer_out, :pointer], :ulong
  attach_function :RemoveDirectoryW, [:buffer_in], :bool
end
