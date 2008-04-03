require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe SpecFile = Nanite::Specification::File do
  
  describe ".new" do
    it "should not require arguments" do
      lambda { SpecFile.new }.should_not raise_error
    end
    
    describe "should set attribute" do
      
      it "#path to first argument of #new" do
        @file = SpecFile.new('/tmp/test')
        @file.path.should == '/tmp/test'
      end
      
      %w( owner perms group ).each do |attr|
        it "##{attr} when sent ##{attr}=" do
          @file = SpecFile.new
          @file.send("#{attr}=", 'value')
          @file.send(attr).should == 'value'
        end
      end
    end
    
  end
  
  describe '#perms=' do
    it "should only accept strings" do
      file = SpecFile.new("/tmp/test")
      lambda { file.perms = 755 }.should raise_error ArgumentError
      lambda { file.perms = 0755 }.should raise_error ArgumentError
      lambda { file.perms = "755"}.should_not raise_error
    end
  end
  
  describe '#content' do
    before do
      @file = SpecFile.new
    end
    
    it "should set #content" do
      @file.content 'asdf'
      @file.read_content.should == 'asdf'
    end
    
    it "should accept a String, Symbol or object that responds to #read" do
      lambda { @file.content 'asdf' }.should_not raise_error
      lambda { @file.content StringIO.new('asdf') }.should_not raise_error
      lambda { @file.content :something }.should_not raise_error
    end
    
    it "should raise ArgumentError when given anything but String, Symbol or object that responds to #read" do
      lambda { @file.content 1 }.should raise_error(ArgumentError)
      lambda { @file.content Object }.should raise_error(ArgumentError)
    end
    
  end
  
  describe '#read_content' do
    before do
      @file = SpecFile.new
    end
    
    it "should return a string when #content= is given a string" do
      @file.content "asdf"
      @file.read_content.should == 'asdf'
    end
    
    it "should return value of #read when #content is given an object that responds to #read" do
      @file.content StringIO.new('test')
      @file.read_content.should == 'test'
    end
    
    it "should call a method when #content is a symbol"
    
    it "should filter #content"
  end
  
  describe '#update_system' do
    before do
      @file = SpecFile.new('/tmp/test')
      @mock_file = mock("file")
      @mock_stat = mock('stat')
      @mock_file.should_receive(:stat).with(no_args()).and_return(@mock_stat)
      ::File.should_receive(:new).with('/tmp/test').and_return(@mock_file)
    end
    
    describe "should update file permissions" do
      it "if permissions set" do
        @mock_stat.should_receive(:mode).and_return("100644")
        @mock_file.should_receive(:chmod).with(0755)
        @file.perms = "755"
        @file.update_system
      end
    
      it "unless permissions not set" do
        @mock_stat.stub!(:mode).and_return('100644')
        @mock_file.should_not_receive(:chmod)
        @file.update_system
      end
    
      it "unless permissions match current" do
        @mock_stat.stub!(:mode).and_return('100744')
        @mock_file.should_not_receive(:chmod)
        @file.perms = '744'
        @file.update_system
      end
    end
    
    describe "should update owner" do
      it "if owner set" do
        @mock_stat.should_receive(:gid).with(no_args()).and_return(1)
        @mock_stat.should_receive(:uid).with(no_args()).and_return(0)
        Etc.should_receive(:getpwnam).with('somebody').and_return(10)
        @mock_file.should_receive(:chown).with(10,1)
        @file.owner = 'somebody'
        @file.update_system
      end
    
      it "unless owner not set" do
        Etc.should_not_receive(:getpwnam)
        @mock_file.should_not_receive(:chown)
        @file.update_system
      end
      
      it "unless owner matches current" do
        @mock_stat.should_receive(:uid).with(no_args()).and_return(10)
        Etc.should_receive(:getpwuid).with(10).and_return('somebody')
        @mock_file.should_not_receive(:chown)
        @file.owner = 'somebody'
        @file.update_system
      end
    end
    
    describe "should update group" do
      it "if group set" do
        @mock_stat.should_receive(:gid).with(no_args()).and_return(1)
        @mock_stat.should_receive(:uid).with(no_args()).and_return(1)
        Etc.should_receive(:getgrnam).with('somebody').and_return(10)
        @mock_file.should_receive(:chown).with(1,10)
        @file.group = 'somebody'
        @file.update_system
      end
    
      it "unless group not set" do
        Etc.should_not_receive(:getgrnam)
        @mock_file.should_not_receive(:chown)
        @file.update_system
      end
      
      it "unless group matches current" do
        @mock_stat.should_receive(:gid).with(no_args()).and_return(10)
        Etc.should_receive(:getgrgid).with(10).and_return('somebody')
        @mock_file.should_not_receive(:chown)
        @file.group = 'somebody'
        @file.update_system
      end
    end
    
    it "should update content using #read_content"
    
  end
end