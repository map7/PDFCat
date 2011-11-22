require 'spec_helper'

describe Category do

  # Write tests for the model, break down move / creating of files.
  describe "#new_dir_exists" do
    before do
      @cat = Category.make(:name => "new")
      @pdf = Pdf.make(:firm => @cat.firm, :category => @cat)
      Pdf.stub!(:find).and_return([@pdf])
    end
    
    context "for multiple pdfs with diff category name" do
      it "checks new category dir doesn't exists" do
        @pdf.stub!(:category_dir_exists?).and_return(false)
        @cat.new_dir_exists?.should be_false
      end
    end

    context "for multiple pdfs with same category name" do
      it "checks new category dir exists" do
        @pdf.stub!(:category_dir_exists?).and_return(true)
        @cat.new_dir_exists?.should be_true
      end
    end
  end

  
end
