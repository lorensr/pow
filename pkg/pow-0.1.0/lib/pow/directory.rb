class Pow
  class Directory < Pow
    include Enumerable
  
    # ====================
    # = Instance Methods =
    # ====================
    def initialize(path, &block)
      super
      open(&block) if block_given?
    end

    def delete
      raise PowError, "'#{path.realpath}' must be empty before you delete it!" unless path.children(true).empty?
      path.rmdir
    end
    
    def delete!
      path.rmtree
    end
    
    def open(mode=nil, &block)
      raise PowError, "'#{path.realpath}' does not exist!" unless exists?
      
      begin
        former_dir = Dir.pwd
        Dir.chdir self.to_s
        block.call self
      ensure
        Dir.chdir(former_dir)
      end
    end
    
    def copy_to(dest)
      FileUtils.cp_r(path.to_s, dest.to_s)
    end
    
    def move_to(dest)
      FileUtils.mv(path.to_s, dest.to_s)
    end
    
    def create
      create_directory
    end
  
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
      children(true, false)
    end

    def directories
      children(false, true)
    end
  
    def children(include_files=true, include_directories=true)
      path.children(true).inject([]) do |children, sub_path|
        children << Pow.open(sub_path) if (include_files and sub_path.file?) or (include_directories and sub_path.directory?)
        children
      end
    end
  
    def each(&block)
      raise PowError, "'#{path.realpath}' does not exist!" unless exists?
      
      children.each(&block)
    end
  end
end