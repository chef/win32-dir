require 'rubygems'

Gem::Specification.new do |spec|
  spec.name      = 'win32-dir'
  spec.version   = '0.3.7'
  spec.authors   = ['Daniel J. Berger', 'Park Heesob']
  spec.license   = 'Artistic 2.0'
  spec.email     = 'djberg96@gmail.com'
  spec.homepage  = 'http://www.rubyforge.org/projects/win32utils'
  spec.platform  = Gem::Platform::RUBY
  spec.summary   = 'Extra constants and methods for the Dir class on Windows.'
  spec.test_file = 'test/test_win32_dir.rb'
  spec.files     = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'win32utils'
  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.add_dependency('windows-pr', '>= 1.0.9')
  spec.add_development_dependency('test-unit', '>= 2.0.6')

  spec.description = <<-EOF
    The win32-dir library provides extra methods and constants for the
    builtin Dir class. The constants provide a convenient way to identify
    certain directories across all versions of Windows. Some methods have
    been added, such as the ability to create junctions. Others have been
    modified to provide a more consistent result for MS Windows.
  EOF
end
