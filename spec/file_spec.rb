require File.dirname(__FILE__) + '/spec_helper.rb'

require 'fileutils'

require 'rubygems'
require 'spec'

require File.dirname(__FILE__) + '/../lib/pow'

describe Pow::File do
  before do
    @dir_pathname = "./test_dir"
    @filename = "file.txt"  
    FileUtils.mkpath @dir_pathname
    open("#{@dir_pathname}/#{@filename}", "w+") {|f| f.write "hello"}
    
    @dir = Pow(@dir_pathname)
    @file = Pow("#{@dir_pathname}/#{@filename}")
  end 
  
  after do
    FileUtils.rm_r @dir_pathname
  end

  it "has correct name" do    
    @file.name.should == "file.txt"
  end
  
  it "gets name without extension" do    
    @file.name(false).should == "file"
  end

  it "gets name without extension, even when there is no extension" do    
    Pow("./this/word").name(false).should == "word"
  end  

  it "matches regular expression for extension" do    
    @file.name.should =~ /txt/
  end

  it "matches regular expression for basename" do    
    @file.name.should =~ /file/
  end

  it "has correct extension" do    
    @file.extension.should == "txt"
  end

  it "returns nil if there is no extension" do
    open("#{@dir_pathname}/README", "w+") {|f| f.write "readme"}
    extensionless_file = Pow("#{@dir_pathname}/README")
    
    extensionless_file.extension.should == nil
  end

  it "is aware of its existence" do    
    @file.exists?.should be_true
  end
  
  it "is aware of its inexistence" do    
    Pow(@dir, :this, :is, :a, :fake, :file).exists?.should be_false
  end

  it "knows when it is not empty" do    
    @file.empty?.should be_false
  end
  
  it "knows when it is empty" do    
    empty_file = Pow("#{@dir_pathname}/empty.txt")
    open(empty_file.path, "w+") {|f| f.write ""}
    empty_file.empty?.should be_true
  end
  
  it "deletes itself" do
    ::File.should_receive(:delete).with(@file.path)
    @file.delete
  end
    
  it "can set its permissions" do    
    @file.permissions = 515
    File.should_not be_writable(@file.to_s)

    @file.permissions = 777
    File.should be_writable(@file.to_s)
  end
  
  it "can read the permissions" do    
    FileUtils.chmod(0514, @file.path.to_s)
    @file.permissions.should == 514

    FileUtils.chmod(0731, @file.path.to_s)
    @file.permissions.should == 731
  end
  
  it "can be read" do    
    @file.open do |file|
      file.read.should == "hello"
    end
  end
  
  it "can be copied" do    
    copy_path = @file.path + ".copy"
    @file.copy_to(copy_path)
    
    File.exists?(copy_path).should be_true
    Pow(copy_path).should be_kind_of(Pow::File)
  end
  
  it "can be copied to nonexistant dirs" do    
    copy_path = @file.parent / "/new_dir/#{@file.name}.copy"
    @file.copy_to!(copy_path)
    
    File.exists?(copy_path).should be_true
    Pow(copy_path).should be_kind_of(Pow::File)
  end
  
  it "can be moved" do    
    move_path = @file.path + ".move"
    old_path = @file.path
    @file.move_to(move_path)
    
    File.exists?(move_path).should be_true
    File.exists?(old_path).should_not be_true
    Pow(move_path).should be_kind_of(Pow::File)
    @file.path.should == move_path
  end

  it "can be moved to nonexistant dirs" do
    move_path = @file.parent / "/new_dir/#{@file.name}.move"
    old_path = @file.path
    @file.move_to!(move_path)
    
    File.exists?(move_path).should be_true
    File.exists?(old_path).should_not be_true
    Pow(move_path).should be_kind_of(Pow::File)
    @file.path.should == move_path
  end

  it "can be renamed" do    
    new_name = "humpty_dumpty.splat"
    new_path = @file.parent / new_name
    old_path = @file.path
    @file.rename_to(new_name)
    
    File.exists?(old_path).should_not be_true
    File.exists?(new_path).should be_true    
    Pow(new_path).should be_kind_of(Pow::File)
    @file.name.should == new_name    
    @file.path.should == new_path    
  end

  
  it "has a parent dir" do    
    @file.parent.should == @dir
  end
end
