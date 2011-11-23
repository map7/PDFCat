require 'spec_helper'

describe Pdf do
  let(:pdf) {Pdf.make}

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
      pdf.client_dir.should == "/home/map7/pdfcat_test_clt/publishing solutions"
    end
  end

  describe "#full_dir" do
    it "should return full pdf directory in downcase" do
      pdf.full_dir.should == "/home/map7/pdfcat_test_clt/publishing solutions/general"
    end
  end

  describe "#full_path" do
    it "should return the full path including filename" do
      pdf.full_path.should == "/home/map7/pdfcat_test_clt/publishing solutions/general/20100128-unit_trust_deed.pdf"
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

  
  describe "#move_dir" do
    context "when directory exists" do
      it "should move the pdf" do
        pdf = Pdf.make
        #puts pdf.full_dir
      end
    end

    context "when directory doesn't exist"
  end
  
  
end
