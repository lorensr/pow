require File.dirname(__FILE__) + '/spec_helper.rb'

require 'fileutils'

require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../lib/pow'

context "A File object" do
  setup do
    @dir_pathname = "./test_dir"
    @filename = "file.txt"  
    FileUtils.mkpath @dir_pathname
    open("#{@dir_pathname}/#{@filename}", "w+") {|f| f.write "hello"}
    
    @dir = Pow.open(@dir_pathname)
    @file = Pow.open("#{@dir_pathname}/#{@filename}")
  end 
  
  teardown do
    FileUtils.rm_r @dir_pathname
  end

  specify "should have a correct name." do    
    @file.name.should == "file.txt"
  end

  specify "should have a correct extension." do    
    @file.extention.should == "txt"
  end

  specify "should have an empty extention if there is none." do    
    open("#{@dir_pathname}/README", "w+") {|f| f.write "readme"}
    extensionless_file = Pow.open("#{@dir_pathname}/README")
    
    extensionless_file.extention.should == ""
  end

  specify "should know it exists." do    
    @file.exists?.should be_true
  end
  
  specify "should remove itself." do    
    @file.delete
    @file.should_not be_exist
  end
    
  specify "should be able to set the permissions." do    
    @file.permissions = 555
    File.should_not be_writable(@file.to_s)

    @file.permissions = 777
    File.should be_writable(@file.to_s)
  end
  
  specify "should be able to read the permissions." do    
    FileUtils.chmod(0555, @file.path.to_s)
    @file.permissions.should == 555

    FileUtils.chmod(0777, @file.path.to_s)
    @file.permissions.should == 777
  end
  
  specify "should be openable!" do    
    @file.open do |file|
      file.read.should == "hello"
    end
  end
  
  specify "should be copyable" do    
    copy_path = "./test_dir/file_copy.txt"
    @file.copy_to(copy_path)
    
    File.exists?(copy_path).should be_true
    Pow[copy_path].should be_kind_of(Pow::File)
  end
  
  specify "should be moveable" do    
    move_path = "./test_dir/file_move.txt"
    @file.move_to(move_path)
    
    File.exists?(move_path).should be_true
    File.exists?(@file.to_s).should_not be_true
    Pow[move_path].should be_kind_of(Pow::File)
  end
  
  specify "should have a parent dir" do    
    @file.parent.should == @dir
  end
end