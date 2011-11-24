require 'spec_helper'

describe Pdf do
  let(:pdf) {Pdf.make}
  
  let(:filename)   {"20100128-unit_trust_deed.pdf"}
  let(:client_dir) {"/home/map7/pdfcat_test_clt/publishing solutions"}
  let(:full_dir)   {"#{client_dir}/general"}
  let(:full_path)  {"#{full_dir}/#{filename}"}  
  
  describe "#client_name" do
    it "should return client name in downcase" do
      pdf.client_name.should == "publishing solutions"
    end
  end
  
  describe "#category_name" do
    it "should return category name in downcase" do
      pdf.category_name.should == "general"
    end
  end

  describe "#client_dir" do
    it "should return storage dir + client for the pdf in question" do
      pdf.client_dir.should == client_dir
    end
  end

  describe "#full_dir" do
    it "should return full pdf directory in downcase" do
      pdf.full_dir.should == full_dir
    end
  end

  describe "#full_path" do
    it "should return the full path including filename" do
      pdf.full_path.should == full_path
    end
  end
  
  describe "#new_full_path" do
    it "should return the full path including new filename" do
      pdf.pdfname = "test"
      pdf.new_full_path.should == "#{full_dir}/#{pdf.get_new_filename2}"
    end
  end
  
  describe "#category_dir_exists?" do
    let(:cat_name) { "general"}
    
    context "when new directory already exists" do 
      it "should return true" do
        File.stub!(:exists?).and_return(true)
        pdf.category_dir_exists?(cat_name).should be_true
      end
    end
    
    context "when new directory does not exist" do 
      it "should return false" do
        dir = pdf.client_dir + "/" + cat_name
        File.stub!(:exists?).with(dir).and_return(false)
        pdf.category_dir_exists?(cat_name).should be_false
      end
    end    
  end

  describe "#prev_full_path" do
    context "when client changes" do
      it "should return previous path" do
        pdf.client = Client.make(:name => "fred")
        pdf.prev_full_path.should == full_path
      end
    end
    
    context "when category changes" do
      it "should return previous path" do 
        pdf.category = Category.make(:name => "new")
        pdf.prev_full_path.should == full_path
      end
      
      context "but path is the same" do
        it "should trust the path variable" do
          pdf = Pdf.make(:path => "mypath")
          pdf.category = Category.make(:name => "new")          
          pdf.prev_full_path.should == "mypath"
        end
      end
    
      context "but path has changed" do
        it "should trust the path variable" do
          pdf = Pdf.make(:path => "mypath")
          pdf.path = "changed"
          pdf.category = Category.make(:name => "new")          
          pdf.prev_full_path.should == "mypath"
        end
      end
    end  
  end
  
  describe "#get_new_filename" do
    it "should return new filename" do
      pdf.pdfname = "foobar"
      pdf.get_new_filename2.should == "20100128-foobar.pdf"
    end
  end
  
  describe "#move_file2" do
    context "when changing category" do

      let(:dest_dir){"#{client_dir}/#{@cat.name}"}
      
      before do
        @pdf = pdf
        @cat = Category.make(:name => "new")
        @pdf.category = @cat
        FileUtils.stub!(:mv)
        File.stub!(:exists).and_return(true)
        FileUtils.stub!(:mkdir_p)
      end
      
      it "should move the pdf" do
        FileUtils.should_receive(:mv).with(full_path,
                                           "#{client_dir}/#{@cat.name}/#{filename}")
        @pdf.move_file2
      end


      context "new full path doesn't exist" do 

        before do 
          @pdf.stub!(:does_new_full_path_exist?).and_return(true)
          File.stub!(:exists?).with(dest_dir).and_return(false)
        end

        it "shouldn't move" do
          FileUtils.should_not_receive(:mkdir_p)
          @pdf.move_file2
        end
      end
      
      context "new full path doesn't exist" do 

        before do 
          @pdf.stub!(:does_new_full_path_exist?).and_return(false)
        end

        context "dest dir doesn't exist" do 
          it "should create the destination directory" do

            File.should_receive(:exists?).with(dest_dir).and_return(false)
            FileUtils.should_receive(:mkdir_p).with(dest_dir, :mode => 0775)
            @pdf.move_file2
          end
        end

        context "dest dir does exist" do 
          it "should check the destination directory only" do
            
            File.should_receive(:exists?).with(dest_dir).and_return(true)
            FileUtils.should_not_receive(:mkdir_p)
            @pdf.move_file2
          end
        end
      end
    end
  end

  
end
