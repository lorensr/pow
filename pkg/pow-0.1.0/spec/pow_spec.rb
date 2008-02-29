require File.dirname(__FILE__) + '/spec_helper.rb'

require 'fileutils'

require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../pow'

context "A Pow object" do
  setup do
    @dir_pathname = Pathname.new("./test_dir")
    @dir_pathname.mkdir
    
    @file_pathname = "./test_dir/file"
    open(@file_pathname, "w+")
  end 
  
  teardown do
    @dir_pathname.rmtree
  end
  
  specify "should open an exsiting directory as a Pow::Directory" do
    path = Pow.open(@dir_pathname)
    path.should be_instance_of(Pow::Directory)
  end
  
  specify "should open an exsiting file as a File" do
    path = Pow.open(@file_pathname)
    path.should be_instance_of(Pow::File)
  end
  
  specify "should open an non-exsiting path as a Pow" do
    path = Pow.open("./blah/blah/blah/blah")
    path.should be_instance_of(Pow)
  end

  specify "should succeed in opening with brackets." do    
    path = Pow[@dir_pathname]
    path.should be_kind_of(Pow::Directory)
    FileTest.exist?(path.to_s).should be_true
    path.to_s.should == @dir_pathname.expand_path.to_s
  end
  
  specify "should succeed using string with Pow.open." do    
    path = Pow.open(@dir_pathname.to_s)
    path.should be_kind_of(Pow::Directory)
    FileTest.exist?(path.to_s).should be_true
    path.to_s.should == @dir_pathname.expand_path.to_s
  end  
  
  specify "should succeed using pathname with Pow.open." do
    path = Pow.open(@dir_pathname)
    path.should be_kind_of(Pow::Directory)
    FileTest.exist?(path.to_s).should be_true
    path.to_s.should == @dir_pathname.expand_path.to_s
  end
  
  specify "should succeed using Pow with Pow.open." do    
    path = Pow.open(Pow.open(@dir_pathname.to_s))
    path.should be_kind_of(Pow::Directory)
    FileTest.exist?(path.to_s).should be_true
    path.to_s.should == @dir_pathname.expand_path.to_s
  end
  
  specify "should succeed using the / operator." do
    subdir_name = "sub_dir"
    subdir_pathname = Pathname.new("#{@dir_pathname}/#{subdir_name}")
    subdir_pathname.mkdir
    
    path = Pow.open(@dir_pathname)
    
    subdir_path = path/subdir_name
    subdir_path.should be_kind_of(Pow::Directory)
    FileTest.exist?(subdir_path.to_s).should be_true
    subdir_path.to_s.should == subdir_pathname.expand_path.to_s
  end
end

context "A Pow object" do
  setup do
    @dir = Pow.open("./blah1/blah2/blah3/blah4")
  end 
  
  specify "should equal an equivalent path object." do    
    @dir.should == Pow.open(@dir)
  end
  
  specify "should know it's parent" do    
    @dir.parent.should == Pow["./blah1/blah2/blah3"]
  end
end

context "A Pow object pointing to a non-existing path" do
  setup do
    @dir = Pow.open("./blah/blah/blah/blah")
  end 
  
  specify "should know it doesn't exists" do    
    @dir.should_not be_exist
  end
end

context "A new Pow" do
  setup do
    FileUtils.mkpath "./test_dir/"
    @dir = Pow["./test_dir"].create
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  specify "should be of type Pow before created" do
    @dir["non_existant"].should be_kind_of(Pow)
  end

  specify "should not exist" do
    @dir["non_existant"].exists?.should be_false
  end

  specify "should be created as a file . found" do
    path = @dir["new.file"].create

    path.should be_kind_of(Pow::File)
    path.exists?.should be_true
  end

  specify "should be created as a directory if no . is found" do
    path = @dir["new_directory"].create

    path.should be_kind_of(Pow::Directory)
    path.exists?.should be_true
  end
end