class PowError < StandardError; end

def Pow(*args, &block)
  Pow.open(*args, &block)
end

class Pow
  attr_accessor :path

  # =================
  # = Class Methods =
  # =================

  def self.open(*paths, &block)
    paths.collect! {|path| path.to_s}
    path = ::File.join(paths)) 
  
    klass = if ::File.directory?(path)
      Directory
    elsif ::File.file?(path)
      File
    else
      self
    end
  
    klass.new(path, &block)
  end
  
  def self.[](*paths)
    open(*paths)
  end

  def self.working_directory
    Dir.getwd
  end

  # ====================
  # = Instance Methods =
  # ====================

  def initialize(path, mode=nil, &block)
    self.path = ::File.expand_path(path)
  end

  def to_s
    path
  end

  def [](*paths)
    Pow.open(path, *paths)
  end

  def /(name=nil)
    Pow.open(path, name)
  end
  
  def ==(other)
    other.to_s == self.to_s
  end
  
  def eql?(other)
    other.eql? self.to_s
  end

  def =~(other)
    name =~ other
  end

  def name
    ::File.basename path
  end
  
  alias_method :exist? :exists?
  def exists?
    ::File.exist? path
  end
  
  def parent
    Pow(::File(dirname))
  end

  def permissions=(mode)
    mode = mode.to_s.to_i(8) # convert from octal
    path.chmod(mode)
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
  
  def open(mode=nil, &block)
    raise PowError, "Path (#{path}) does not exist."
  end
end