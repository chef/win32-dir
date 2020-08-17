require_relative "lib/win32/dir/version"

Gem::Specification.new do |spec|
  spec.name       = "win32-dir"
  spec.version    = Win32::Dir::VERSION
  spec.authors    = ["Daniel J. Berger", "Park Heesob"]
  spec.license    = "Artistic 2.0"
  spec.email      = "djberg96@gmail.com"
  spec.homepage   = "https://github.com/chef/win32-dir"
  spec.summary    = "Extra constants and methods for the Dir class on Windows."
  spec.files         = Dir["LICENSE", "lib/**/*"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_dependency("ffi", ">= 1.0.0")

  spec.description = <<-EOF
    The win32-dir library provides extra methods and constants for the
    builtin Dir class. The constants provide a convenient way to identify
    certain directories across all versions of Windows. Some methods have
    been added, such as the ability to create junctions. Others have been
    modified to provide a more consistent result for MS Windows.
  EOF
end
