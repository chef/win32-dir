require 'ffi'

module Dir::Structs
  extend FFI::Library

  class SHFILEINFO < FFI::Struct
    layout(
      :hIcon, :ulong,
      :iIcon, :int,
      :dwAttributes, :ulong,
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
      :PathBuffer, [:char, 1024]
    )
  end
end
