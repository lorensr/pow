class PowError < StandardError; end

def Pow(*args, &block)
  Pow::Base.open(*args, &block)
end

def Pow!(*args, &block)
  file_path = ::File.dirname(caller[0])
  Pow(file_path, *args, &block)
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
      path_must_exist
    end
    
    def copy_to(dest)
      path_must_exist
    end
    alias_method :cp, :copy_to
    
    def copy_to!(dest)
      path_must_exist
    end
    alias_method :cp!, :copy_to!
    
    def move_to(dest)
      path_must_exist
    end
    alias_method :mv, :move_to
    
    def move_to!(dest)
      path_must_exist
    end
    alias_method :mv!, :move_to!
    
    def rename_to(new_name)
      move_to(parent / new_name)
    end
        
    def permissions=(mode)
      mode = mode.to_s.to_i(8) # convert from octal
      FileUtils.chmod(mode, path)
    end

    def permissions
      ("%o" % ::File.stat(path.to_s).mode)[2..-1].to_i # Forget about the first two numbers
    end
    
    def size
      ::File.size(path)
    end

    def accessed_at
      ::File.atime(path)
    end
    alias_method :atime, :accessed_at

    def changed_at
      ::File.ctime(path)
    end
    alias_method :ctime, :changed_at

    def modified_at
      ::File.mtime(path)
    end
    alias_method :mtime, :modified_at
    
    # String representation of the expanded path
    def to_s
      path
    end
    alias_method :to_str, :to_s
    
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

    def name(with_extention=true)
      ::File.basename path, (with_extention ? "" : ".#{extention}")
    end
    
    def extention
      ::File.extname(path)[1..-1] # Gets rid of the dot
    end
  
    def exists?
      ::File.exist? path
    end
    alias_method :exist?, :exists?
  
    def parent
      Pow(::File.dirname(path))
    end

    def empty?
      true
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
    
    private
    def path_must_exist
      raise PowError, "Path (#{path}) does not exist."
    end
    
    def path=(value)
      @path = ::File::expand_path(value)
    end
  end
end