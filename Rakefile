require "bundler/gem_tasks"

require 'rake/testtask'

desc "Run the unit test suite"
task :default => 'test:units'

task :test => 'test:units'

namespace :test do

  Rake::TestTask.new(:units) do |t|
    t.pattern = 'test/unit/**/*_test.rb'
    t.ruby_opts << '-rubygems'
    t.libs << 'test'
    t.verbose = true
  end

end
