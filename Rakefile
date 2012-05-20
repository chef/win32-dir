require 'rake'
require 'rake/clean'
require 'rake/testtask'

CLEAN.include('**/*.gem', '**/*.log')

namespace 'gem' do
  desc "Create the win32-dir gem"
  task :build => [:clean] do
    Dir["*.gem"].each{ |f| File.delete(f) }
    spec = eval(IO.read('win32-dir.gemspec'))
    Gem::Builder.new(spec).build
  end
  
  desc "Install the win32-dir gem"
  task :install => [:build] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
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
