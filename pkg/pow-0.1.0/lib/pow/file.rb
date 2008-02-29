class Pow
  class File < Pow
    
    # ====================
    # = Instance Methods =
    # ====================    
    def initialize(path, mode="r+", &block)
      super
      open(mode, &block) if block_given?
    end
    
    def delete
      ::File.delete(path.to_s)
    end
    
    def extention
      ::File.extname(path.to_s).sub /^\./, ""
    end
    
    def open(mode="r", &block)
      Kernel.open(path.to_s, mode, &block)
    end
    
    def create
      create_file
    end 
    
    def empty?
      ::File.size(path) == 0
    end
    
    def copy_to(dest)
      FileUtils.cp(path.to_s, dest.to_s)
    end
    
    def move_to(dest)
      FileUtils.mv(path.to_s, dest.to_s)
    end
  end
end