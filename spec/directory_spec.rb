require File.dirname(__FILE__) + '/spec_helper.rb'

require 'rubygems'
require 'spec'

require 'pathname'

require File.dirname(__FILE__) + '/../lib/pow'

describe "A Directory object" do
  setup do
    FileUtils.mkpath "./test_dir/sub_dir"
    
    @dir = Pow("./test_dir")
    @sub_dir = @dir/"sub_dir"
  end 
  
  teardown do
    #FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end

  it "has valid name" do    
    @dir.name.should == "test_dir"
  end

  it "knows it exists" do    
    @sub_dir.exists?.should be_true
  end
  
  it "removes itself" do    
    ::Dir.should_receive(:rmdir).with(@sub_dir.path)
    @sub_dir.delete
  end
  
  it "removes all subdirectories." do
    ::FileUtils.should_receive(:rmtree).with(@dir.path)
    @dir.delete!
  end
  
  it "raises an error if directory tries to delete itself but is not empty." do    
    lambda {@dir.delete}.should raise_error(PowError)
    ::File.should be_exist(@sub_dir)
  end
  
  it "should be able to set the permissions." do    
    @dir.permissions = 555
    File.should_not be_writable(@dir.to_s)

    @dir.permissions = 777
    File.should be_writable(@dir.to_s)
  end
  
  it "should be able to read the permissions." do    
    FileUtils.chmod(555, @dir.path.to_s)
    @dir.permissions.should == 555

    FileUtils.chmod(777, @dir.path.to_s)
    @dir.permissions.should == 777
  end
  
  it "should be copyable" do    
    copy_path = "./test_dir/sub_dir_copy"
    @sub_dir.copy_to(copy_path)
    
    File.exists?(copy_path)
    Pow[copy_path].should be_kind_of(Pow::Directory)
  end
  
  it "should be moveable" do    
    move_path = "./test_dir/moved_sub_dir"
    @sub_dir.move_to(move_path)
    
    File.exists?(move_path).should be_true
    File.exists?(@sub_dir.to_s).should_not be_true
    Pow[move_path].should be_kind_of(Pow::Directory)
  end
  
  it "should have a parent dir" do    
    @sub_dir.parent.should == @dir
  end
end

describe "The children of a Directory" do
  setup do
    FileUtils.mkpath "./earth/people"
    FileUtils.mkpath "./earth/places"
    FileUtils.mkpath "./earth/things"
    open("./earth/evolution", "w+")
    open("./earth/history.txt", "w+")
    
    @dir = Pow.open("./earth/")
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "should include all files and directories." do
    @dir.should have(5).children
    @dir.children.each { |child| [Pow::File, Pow::Directory].should be_member(child.class) }
  end
  
  it "should allow you to select files." do
    @dir.should have(2).children(true, false)
    @dir.children(true, false).should == @dir.files
    
    @dir.files.each { |file| file.should be_kind_of(Pow::File) }
    @dir.files.collect {|file| file.name}.should be_member("evolution")
    @dir.files.collect {|file| file.name}.should be_member("history.txt")
  end

  it "should allow you to select directories." do
    @dir.should have(3).children(false, true)
    @dir.children(false, true).should == @dir.directories
    
    @dir.directories.each { |directory| directory.should be_kind_of(Pow::Directory) }
    
    @dir.directories.collect {|directory| directory.name}.should be_member("people")
    @dir.directories.collect {|directory| directory.name}.should be_member("places")
    @dir.directories.collect {|directory| directory.name}.should be_member("things")
  end
  
  it "should be accessable via glob." do
    @dir.glob("*").size.should == 5
    @dir.glob("*").each { |child| [Pow::File, Pow::Directory].should be_member(child.class) }
    @dir.glob("*").collect {|path| path.name}.should be_member("history.txt")
    @dir.glob("*").collect {|path| path.name}.should be_member("evolution")
    @dir.glob("*").collect {|path| path.name}.should be_member("people")
    @dir.glob("*").collect {|path| path.name}.should be_member("places")
    @dir.glob("*").collect {|path| path.name}.should be_member("things")
  end
end
  
describe "Then enumerable bits of a Directory" do
  it "should include enumerable." do
    Pow::Directory.ancestors.should be_member(Enumerable)
  end
  
  it "should call every child when each is called." do
    dir = Pow::Directory[("./test_dir")].create
    
    child_one = mock("child_one")
    child_two = mock("child_two")
    dir.stub!(:children).and_return([child_one,child_two])
    
    child_one.should_receive(:yes)
    child_two.should_receive(:yes)

    dir.each do |child|
      child.yes
    end
  end
end

describe "Nested directory objects" do
  setup do
    FileUtils.mkpath "./test_dir/sub_dir"
    @dir = Pow::Directory["./test_dir"]
    @sub_dir = Pow::Directory.open("./test_dir/sub_dir")
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "should be accessible when joined" do
   path = Pow::Directory["test_dir", "sub_dir"]
   path.exists?.should be_true
   path.should be_instance_of(Pow::Directory)
  end
  
  it "should be accessible from path object" do
   path = @dir["sub_dir"]
   path.exists?.should be_true
   path.should be_instance_of(Pow::Directory)
  end
end

describe "Using blocks to create Directory structure" do
  setup do
    FileUtils.mkpath "./test_dir/"
    @dir = Pow.open("./test_dir")
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "should change the working directory" do
    @dir.open do |path|
      Dir.pwd.should == path.to_s
    end
  end
  
  it "should go back to old dir if block raises error" do
    current_dir = Dir.pwd
    
    begin
      @dir.open do |path|
        raise "no problem"
      end
    rescue
    end
    
    Dir.pwd.should == current_dir
  end
  
  it "should create sub directories when within a block" do
    @dir["sub_dir"].create do
      Pow["sub_sub_dir"].create
    end
    
    sub_dir = Pow["./test_dir/sub_dir"]
    sub_sub_dir = Pow["./test_dir/sub_dir/sub_sub_dir"]

    sub_dir.should be_kind_of(Pow::Directory)
    sub_dir.exists?.should be_true

    sub_sub_dir.should be_kind_of(Pow::Directory)
    sub_sub_dir.exists?.should be_true
  end
end