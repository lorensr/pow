require 'rubygems'

require File.dirname(__FILE__) + "/lib/pow.rb"

task "gemspec" => "update_version"

task "update_version" do
  `echo '#{Pow::VERSION}' > VERSION`
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "pow"
    gemspec.summary = "Easy file and directory handling"
    gemspec.description = "Manipulating files and directories in Ruby is boring and tedious -- it's missing POW! Pow treats files and directories as ruby objects giving you more power and flexibility."
    gemspec.email = "probablycorey@gmail.com"
    gemspec.homepage = "http://github.com/probablycorey/pow"
    gemspec.authors = ["Corey Johnson"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
