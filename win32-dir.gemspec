require 'rubygems'

spec = Gem::Specification.new do |gem|
   gem.name      = 'win32-dir'
   gem.version   = '0.3.5'
   gem.authors   = ['Daniel J. Berger', 'Park Heesob']
   gem.license   = 'Artistic 2.0'
   gem.email     = 'djberg96@gmail.com'
   gem.homepage  = 'http://www.rubyforge.org/projects/win32utils'
   gem.platform  = Gem::Platform::RUBY
   gem.summary   = 'Extra constants and methods for the Dir class on Windows.'
   gem.test_file = 'test/test_dir.rb'
   gem.files     = Dir['**/*'].reject{ |f| f.include?('CVS') }

   gem.rubyforge_project = 'win32utils'
   gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

   gem.add_dependency('windows-pr', '>= 0.9.3')
   gem.add_development_dependency('test-unit', '>= 2.0.3')

   gem.description = <<-EOF
      The win32-dir library provides extra methods and constants for the
      builtin Dir class. The constants provide a convenient way to identify
      certain directories across all versions of Windows. Some methods have
      been added, such as the ability to create junctions. Others have been
      modified to provide a more consistent result for MS Windows.
   EOF
end

Gem::Builder.new(spec).build
