module Pow
  class File < Base
    
    # ====================
    # = Instance Methods =
    # ====================    
    def initialize(path, mode="r+", &block)
      super
      open(mode, &block) if block_given?
    end
    
    def open(mode="r", &block)
      Kernel.open(path.to_s, mode, &block)
    end
    
    def create(&block)
      create_file(&block)
    end 
    
    def read(length=nil, offset=nil)
      ::File.read(path.to_s, length, offset)
    end
    
    def delete
      ::File.delete(path)
    end
    
    def extention
      ::File.extname(path)[1..-1] # Gets rid of the dot
    end

    def empty?
      ::File.size(path) == 0
    end
    
    def copy_to(dest)
      FileUtils.cp(path.to_s, dest.to_s)
    end
    alias_method :cp, :copy_to
    
    def move_to(dest)
      FileUtils.mv(path.to_s, dest.to_s)
    end
    alias_method :mv, :move_to
    
  end
end