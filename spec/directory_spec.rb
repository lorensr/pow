require File.dirname(__FILE__) + '/spec_helper.rb'

require 'rubygems'
require 'spec'

require 'fileutils'

require File.dirname(__FILE__) + '/../lib/pow'

describe "A Directory object" do
  setup do
    FileUtils.mkpath "./test_dir/sub_dir"
    
    @dir = Pow("./test_dir")
    @sub_dir = @dir/"sub_dir"
  end 
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end

  it "has valid name" do    
    @dir.name.should == "test_dir"
  end

  it "knows it exists" do    
    @sub_dir.exists?.should be_true
  end
  
  it "removes itself" do
    @sub_dir.delete
    File.should_not be_exist(@sub_dir.path) 
  end
  
  it "removes all subdirectories" do
    @dir.delete!
    File.should_not be_exist(@sub_dir.path)
    File.should_not be_exist(@dir.path)
  end
  
  it "raises an error if directory tries to delete itself but is not empty" do    
    lambda {@dir.delete}.should raise_error(PowError)
    File.should be_exist(@sub_dir.path)
    File.should be_exist(@dir.path)
  end
  
  it "sets permissions" do    
    @dir.permissions = 333
    File.should_not be_readable(@dir.to_s)

    @dir.permissions = 777
    File.should be_readable(@dir.to_s)
  end
  
  it "read permissions" do    
    FileUtils.chmod(0755, @dir.path.to_s)
    @dir.permissions.should == 755

    FileUtils.chmod(0717, @dir.path.to_s)
    @dir.permissions.should == 717
  end
  
  it "is copyable" do    
    copy_path = "./test_dir/sub_dir_copy"
    @sub_dir.copy_to(copy_path)
    
    File.should be_exists(copy_path)
    Pow(copy_path).should be_kind_of(Pow::Directory)
  end
  
  it "is moveable" do    
    move_path = "./test_dir/moved_sub_dir"
    @sub_dir.move_to(move_path)
    
    File.should be_exists(move_path)
    File.should_not be_exists(@sub_dir.to_s)
    Pow(move_path).should be_kind_of(Pow::Directory)
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
    
    @dir = Pow("./earth/")
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "includes all files and directories" do
    @dir.should have(5).children
    @dir.children.each { |child| [Pow::File, Pow::Directory].should be_member(child.class) }
  end
  
  it "allow you to select files" do
    @dir.should have(2).children(:no_dirs => true)
    @dir.children(:no_dirs => true).should == @dir.files
    
    @dir.files.each { |file| file.should be_kind_of(Pow::File) }
    @dir.files.collect {|file| file.name}.should be_member("evolution")
    @dir.files.collect {|file| file.name}.should be_member("history.txt")
  end

  it "should allow you to select directories" do
    @dir.should have(3).children(:no_files => true)
    @dir.children(:no_files => true).should == @dir.directories
    
    @dir.directories.each { |directory| directory.should be_kind_of(Pow::Directory) }
    
    @dir.directories.collect {|directory| directory.name}.should be_member("people")
    @dir.directories.collect {|directory| directory.name}.should be_member("places")
    @dir.directories.collect {|directory| directory.name}.should be_member("things")
  end
  
  it "should be accessable via glob" do
    @dir.glob("*").size.should == 5
    @dir.glob("*").each { |child| [Pow::File, Pow::Directory].should be_member(child.class) }
    @dir.glob("*").collect {|path| path.name}.should be_member("history.txt")
    @dir.glob("*").collect {|path| path.name}.should be_member("evolution")
    @dir.glob("*").collect {|path| path.name}.should be_member("people")
    @dir.glob("*").collect {|path| path.name}.should be_member("places")
    @dir.glob("*").collect {|path| path.name}.should be_member("things")
  end
end
  
describe "Enumerable parts of Directory" do
  setup do
    FileUtils.mkpath "./test_dir/sub_dir"
    
    @dir = Pow("./test_dir")
    @sub_dir = @dir/"sub_dir"
  end 
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  
  it "is enumerable, duh" do
    Pow::Directory.ancestors.should be_member(Enumerable)
  end
  
  it "calls every child when 'each' is called" do
    child_one = mock("child_one")
    child_two = mock("child_two")
    @dir.stub!(:children).and_return([child_one,child_two])
    
    child_one.should_receive(:yes)
    child_two.should_receive(:yes)

    @dir.each do |child|
      child.yes
    end
  end
end

describe "Using blocks to create Directory structure" do
  setup do
    FileUtils.mkpath "./test_dir/"
    @dir = Pow("./test_dir")
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "changes the working directory" do
    @dir.open do |path|
      Dir.pwd.should == path.to_s
    end
  end
  
  it "goes back to old dir if block raises error" do
    current_dir = Dir.pwd
    
    begin
      @dir.open do |path|
        raise "no problem"
      end
    rescue
    end
    
    Dir.pwd.should == current_dir
  end
  
  it "creates sub directories when within a block" do
    @dir["sub_dir"].create do
      Pow("sub_sub_dir").create
    end
    
    sub_dir = Pow("./test_dir/sub_dir")
    sub_sub_dir = Pow("./test_dir/sub_dir/sub_sub_dir")

    sub_dir.should be_kind_of(Pow::Directory)
    sub_dir.exists?.should be_true

    sub_sub_dir.should be_kind_of(Pow::Directory)
    sub_sub_dir.exists?.should be_true
  end
end