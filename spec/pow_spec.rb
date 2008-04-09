require File.dirname(__FILE__) + '/spec_helper.rb'

require 'pow'

describe Pow::Base, "object creation" do
  setup do
    @dir_pathname = "./test_dir"
    FileUtils.mkdir(@dir_pathname)
    
    @file_pathname = "./test_dir/file"
    open(@file_pathname, "w+")
  end 
  
  teardown do
    FileUtils.rmtree @dir_pathname
  end
  
  it "opens an exsiting directory as a Pow::Directory" do
    path = Pow::Base.open(@dir_pathname)
    path.should be_instance_of(Pow::Directory)
    
    path.to_s.should == File.expand_path(@dir_pathname)  
  end
  
  it "opens an exsiting file as a File" do
    path = Pow::Base.open(@file_pathname)
    path.should be_instance_of(Pow::File)

    path.to_s.should == File.expand_path(@file_pathname)    
  end
  
  it "opens an non-exsiting path as a Pow" do
    path = Pow::Base.open("./blah/blah/blah/blah")
    path.should be_instance_of(Pow::Base)
  end

  it "opens path with Pow method." do    
    path = Pow(@dir_pathname)
    path.should be_kind_of(Pow::Directory)
    
    path.to_s.should == File.expand_path(@dir_pathname)    
  end
  
  it "opens using string with Pow::Base.open." do    
    path = Pow(@dir_pathname.to_s)
    path.should be_kind_of(Pow::Directory)
    
    path.to_s.should == File.expand_path(@dir_pathname)
  end  
  
  it "opens using Pow object with Pow::Base.open." do    
    pow = Pow::Base.open(@dir_pathname.to_s)
    path = Pow::Base.open(pow)
    path.should be_kind_of(Pow::Directory)

    path.to_s.should == File.expand_path(@dir_pathname)    
  end
  
  it "appends paths using the / operator." do
    subdir_name = "sub_dir"
    subdir_pathname = "#{@dir_pathname}/#{subdir_name}"
    FileUtils.mkdir(subdir_pathname)
    
    path = Pow(@dir_pathname)
    
    subdir_path = path/subdir_name
    subdir_path.should be_kind_of(Pow::Directory)
    FileTest.exist?(subdir_path.to_s).should be_true
    subdir_path.to_s.should == File.expand_path(subdir_pathname)
  end
end

describe Pow::Base, "object equality" do
  setup do
    @path = "./blah1/blah2/blah3/blah4"
    @pow = Pow::Base.open(@path)
  end 
  
  it "equals an equivalent Pow object." do    
    (@pow == Pow::Base.open(@path)).should be_true
  end

  it "should know it's parent" do    
    @pow.parent.should == Pow("./blah1/blah2/blah3")
  end
end

describe Pow::Base, "nonexistent paths" do
  setup do
    @pow = Pow::Base.open("./blah/blah/blah/blah")
  end 
  
  it "should know it doesn't exist" do
    @pow.exists?.should be_false
  end
  
  it "can't be opened" do
    lambda {@pow.open}.should raise_error(PowError)
  end
end

describe Pow::Base, "creation" do
  setup do
    FileUtils.mkpath "./test_dir/"
    @dir = Pow("./test_dir").create
  end
  
  teardown do
    FileUtils.rm_r @dir.to_s if FileTest.exist?(@dir.to_s)
  end
  
  it "creates as a file if . found" do
    path = @dir["new.file"].create

    path.should be_kind_of(Pow::File)
    File.exists?(path.to_s)
  end

  it "should be created as a directory if no . is found" do
    path = @dir["new_directory"].create

    path.should be_kind_of(Pow::Directory)
    File.exists?(path.to_s)
  end
end