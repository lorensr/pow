require File.dirname(__FILE__) + '/spec_helper.rb'

require 'fileutils'

require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../lib/pow'

describe Pow::File do
  setup do
    @dir_pathname = "./test_dir"
    @filename = "file.txt"  
    FileUtils.mkpath @dir_pathname
    open("#{@dir_pathname}/#{@filename}", "w+") {|f| f.write "hello"}
    
    @dir = Pow(@dir_pathname)
    @file = Pow("#{@dir_pathname}/#{@filename}")
    
    ::File.stub!(:delete).and_return(true)
  end 
  
  teardown do
    FileUtils.rm_r @dir_pathname
  end

  it "has correct name" do    
    @file.name.should == "file.txt"
  end

  it "matches regular expression for extention" do    
    @file.name.should =~ /txt/
  end

  it "matches regular expression for basename" do    
    @file.name.should =~ /file/
  end

  it "has correct extension" do    
    @file.extention.should == "txt"
  end

  it "returns nil if there is no extension" do
    open("#{@dir_pathname}/README", "w+") {|f| f.write "readme"}
    extensionless_file = Pow("#{@dir_pathname}/README")
    
    extensionless_file.extention.should == nil
  end

  it "is aware of its existence" do    
    @file.exists?.should be_true
  end
  
  it "is aware of its inexistence" do    
    Pow(@dir, :this, :is, :a, :fake, :file).exists?.should be_false
  end
  
  it "should remove itself" do
    @file.delete
    ::File.should_receive(:delete).with(@file.path)
  end
    
  it "should be able to set the permissions" do    
    @file.permissions = 555
    File.should_not be_writable(@file.to_s)

    @file.permissions = 777
    File.should be_writable(@file.to_s)
  end
  
  it "should be able to read the permissions" do    
    FileUtils.chmod(0555, @file.path.to_s)
    @file.permissions.should == 555

    FileUtils.chmod(0777, @file.path.to_s)
    @file.permissions.should == 777
  end
  
  it "should be openable!" do    
    @file.open do |file|
      file.read.should == "hello"
    end
  end
  
  it "should be copyable" do    
    copy_path = "./test_dir/file_copy.txt"
    @file.copy_to(copy_path)
    
    File.exists?(copy_path).should be_true
    Pow[copy_path].should be_kind_of(Pow::File)
  end
  
  it "should be moveable" do    
    move_path = "./test_dir/file_move.txt"
    @file.move_to(move_path)
    
    File.exists?(move_path).should be_true
    File.exists?(@file.to_s).should_not be_true
    Pow[move_path].should be_kind_of(Pow::File)
  end
  
  it "should have a parent dir" do    
    @file.parent.should == @dir
  end
end