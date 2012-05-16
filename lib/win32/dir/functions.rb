require 'ffi'

module Dir::Functions
  extend FFI::Library

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
end
