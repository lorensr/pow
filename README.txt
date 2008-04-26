== Pow
  by Corey Johnson
  http://github.com/probablycorey/pow/tree/master

== Description:

Manipulating files and directories in Ruby is boring and tedious -- it's missing POW!
Pow treats files and directories as ruby objects giving you more power and flexibility.

Why not just use File, FileUtils, Find, FileTest, Pathname, etc...? Because Pow combines the power of those libraries into one rubyish interface. 

== Basic Usage

Consider this directory structure

  /tmp
    README
    /sub_dir
      /deeper_dir
      file.txt
      program
    /extra_dir

To open a directory
  path = Pow("tmp")

Check out what's inside a directory
  path = Pow("tmp")
  path.each {|child| puts "#{child} - #{child.class.name}!" }

  # Output!
  # -------
  /tmp/README - Pow::File
  /tmp/subdir - Pow::Directory
  /tmp/sub_dir/deeper_dir - Pow::Directory
  /tmp/sub_dir/file.txt - Pow::File
  /tmp/sub_dir/program - Pow::File
  /tmp/extra_dir - Pow::Directory
  
Access a file in that directory
  # The / operator accepcts symbols, strings or other Pow objects
  file = path / :subdir / "file.txt"

  # You can also use brackets to access paths
  file = path[:subdir, "file.txt"]
  
Create nested directories
  # When you create a directory, the block will change the current working directory to the newly created directory 

  Pow("MOAR").create do
    Pow("sub_dir").create do
      Pow("info.txt").create {|file| file.puts "Here is the info you desired!"}
    end

    Pow("README").create_file {|file| file.puts "I'm so glad you read this."}
  end
  
  # Creates directory structure
  /MOAR
    /sub_dir
      info.txt
    README
  
Open a file
  Pow(:tmp, :sub_dir, :file.txt) do |file|
    # All the stuff you usually do with an open file!
  end

Create a file
  Pow("tmp/sub_dir/new_file.txt").create do |file|
    # All the stuff you usually do with an new file!
  end
  
Do you hate having to write <b>require File.expand_path(File.dirname(__FILE__) + "/lib/something_else")</b> all the time, instead try this
  # The Pow! method will automatically create a path based on the current files parent
  require Pow!("lib/something_else")
  # Instead of 
  require File.expand_path(File.dirname(__FILE__) + "/lib/something_else")
  
Other things you can do (read more about them in the docs)
  - Directories that actually use Enumerable!
  - Move files/directores
  - Copy files/directories
  - Get/set permissions
  - Delete and recursive deletes
  - Combining paths with the / operator
  - And much much more!
  
== Installation:
  
  $ sudo gem install pow

== Why Is It Called Pow:

  1.) Pow is fun to say.
  2.) Pow is easy to type.
  3.) It knocks you on your ass.

== Requirements:

* A computer

== Install:

* sudo gem install pow

== Special Thanks:

* Chris Shea http://ruby.tie-rack.org/

== License:

Copyright (c) 2007 Corey Johnson and the rest of the Ruby Hit Squad

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.