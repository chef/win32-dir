require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include('**/*.gem', '**/*.log')

namespace 'gem' do
  desc "Build the win32-dir gem"
  task :create => [:clean] do
    require 'rubygems/package'
    Dir["*.gem"].each{ |f| File.delete(f) }
    spec = eval(IO.read('win32-dir.gemspec'))
    Gem::Package.build(spec)
  end

  desc "Install the win32-dir gem"
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

desc "Run the example program"
task :example do
  sh "ruby -Ilib examples/dir_example.rb"
end

Rake::TestTask.new do |t|
  t.warning = true
  t.verbose = true
end

task :default => :test
