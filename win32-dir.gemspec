require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'win32-dir'
  spec.version   = '0.4.9'
  spec.authors   = ['Daniel J. Berger', 'Park Heesob']
  spec.license   = 'Artistic 2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://github.com/djberg96/win32-dir'
  spec.summary   = 'Extra constants and methods for the Dir class on Windows.'
  spec.test_file = 'test/test_win32_dir.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']
  spec.required_ruby_version = '>= 1.9.2'

  spec.add_dependency('ffi', '>= 1.0.0')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('test-unit', '>= 2.4.0')

  spec.description = <<-EOF
    The win32-dir library provides extra methods and constants for the
    builtin Dir class. The constants provide a convenient way to identify
    certain directories across all versions of Windows. Some methods have
    been added, such as the ability to create junctions. Others have been
    modified to provide a more consistent result for MS Windows.
  EOF
end
