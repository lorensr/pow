class PowError < StandardError; end

def Pow(*args, &block)
  Pow::Base.open(*args, &block)
end

def Pow!(*args, &block)
  file_path = File::expand_path(::File.dirname(caller[0]))
  Pow(file_path, *args, &block)
end

def fart
  go
end

module Pow
  class Base
    attr_accessor :path

    def self.open(*paths, &block)
      paths.collect! {|path| path.to_s}
      path = ::File.join(paths)
  
      klass = if ::File.directory?(path)
        Directory
      elsif ::File.file?(path)
        File
      else
        self
      end
  
      klass.new(path, &block)
    end
    
    # Returns the path to the current working directory as a Pow::Dir object.
    def self.working_directory
      Pow(Dir.getwd)
    end
    class <<self; alias_method :cwd, :working_directory; end

    def initialize(path, mode=nil, &block)
      self.path = ::File.expand_path(path)
    end

    def open(mode=nil, &block)
      raise PowError, "Path (#{path}) does not exist."
    end

    # String representation of the expanded path
    def to_s
      path
    end
    
    # Shortcut to combine paths
    #   path = Pow("tmp")
    #   readme_path = path[:README]
    def [](*paths, &block)
      Pow(path, *paths, &block)
    end

    # Shortcut to append info onto a Pow object
    #   path = Pow("tmp")
    #   readme_path = path/"subdir"/"README"
    def /(name=nil)
      self.class.open(path, name)
    end
  
    def ==(other)
      other.to_s == self.to_s
    end
  
    def eql?(other)
      other.eql? self.to_s
    end

    # Regex match on the basename for the path
    # path = Pow("/tmp/a_file.txt")
    # path =~ /file/ #=> 2
    # path =~ /tmp/ #=> nil
    def =~(pattern)
      name =~ pattern
    end

    def name
      ::File.basename path
    end
  
    def exists?
      ::File.exist? path
    end
    alias_method :exist?, :exists?
  
    def parent
      Pow(::File.dirname(path))
    end

    def permissions=(mode)
      mode = mode.to_s.to_i(8) # convert from octal
      FileUtils.chmod(mode, path)
    end

    def permissions
      ("%o" % ::File.stat(path.to_s).mode)[2..-1].to_i # Forget about the first two numbers
    end

    def empty?
      true
    end

    def accessed_at
      path.atime
    end

    def changed_at
      path.ctime
    end

    def modified_at
      path.mtime
    end

    #If there is a . in the name, then assume it is a file
    def create(&block)
      name =~ /\./ ? create_file(&block) : create_directory(&block)
    end
  
    def create_file(&block)
      FileUtils.mkdir_p(::File.dirname(self.to_s))
      file = File.new(self.to_s)
      file.open("w+", &block) # Create the file
    
      file
    end
  
    def create_directory(&block)
      FileUtils.mkdir_p(self.to_s)
      dir = Directory.new(self.to_s)
    
      dir.open(&block) if block_given?
    
      dir
    end
  end
end