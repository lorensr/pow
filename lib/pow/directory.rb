module Pow
  class Directory < Base
    include Enumerable

  
    # ====================
    # = Instance Methods =
    # ====================
    def initialize(path, mode=nil, &block)
      super
      open(&block) if block_given?
    end

    def open(mode=nil, &block)
      raise PowError, "'#{path}' does not exist!" unless exists?
      
      begin
        former_dir = Dir.pwd
        Dir.chdir self.to_s
        block.call self
      ensure
        Dir.chdir(former_dir)
      end
    end
    
    def create(&block)
      create_directory(&block)
    end

    def delete
      raise PowError, "Can not delete '#{path}'. It must be empty before you delete it!" unless children.empty?
      Dir.rmdir path
    end
    
    def delete!
      FileUtils.rmtree path
    end
    
    def copy_to(dest)
      FileUtils.cp_r(path, dest.to_s)
    end
    alias_method :cp, :copy_to
    
    def move_to(dest)
      FileUtils.mv(path, dest.to_s)
    end
    alias_method :mv, :move_to
  
    def empty?
      children.empty?
    end
  
    # ===============
    # = My Children =
    # ===============
    def glob(pattern, *flags)
      Dir[::File.join(to_s, pattern), *flags].collect {|path| Pow.open(path)}
    end
    
    def files
      children(:include_dirs => true)
    end

    def directories
      children(:include_files => true)
    end
    alias_method :dirs, :directories
  
    def children(options={})
      options = {:include_dirs => true, :include_files => true}.merge(options)

      children = []
      Dir.foreach(path) do |child|
        next if e == '.'
        next if e == '..'
        next if (::File.file?(child) and not options[:include_files]) 
        next if (::File.directory? and not options[:include_dirs])
        children << Pow.open(path, child) 
      end
    end
  
    def each(&block)
      raise PowError, "'#{path.realpath}' does not exist!" unless exists?
      children.each(&block)
    end
  end
end