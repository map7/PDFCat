require 'spec_helper'

describe Category do

  # Write tests for the model, break down move / creating of files.
  describe "#new_dir_available" do
    before do
      @cat = Category.make
      @pdf = Pdf.make(:category => @cat)
      @pdf_dir = "#{@pdf.firm.store_dir}/#{@pdf.client.name}/#{@cat.name}".downcase
    end
    
    context "for one pdf with new category name not existing" do
      it "checks new category dir doesn't exists" do
        File.stub!(:exists?).with(@pdf_dir).and_return(false)
        @cat.new_dir_available?.should be_true
      end
    end

    context "for one pdf with new category name existing" do
      it "checks new category dir exists" do
        File.stub!(:exists?).with(@pdf_dir).and_return(true)
        @cat.new_dir_available?.should be_false
      end
    end
    
    context "multiple pdfs one with existing category name" do
      it "should store the result and return" do
        @pdf2 = Pdf.make(:client => Client.make(:name => "fred"), :category => @cat)

        # The second pdf is available but not the first.
        File.stub!(:exists?).with(@pdf_dir).and_return(false)
        File.stub!(:exists?).
          with("#{@pdf2.firm.store_dir}/#{@pdf2.client.name}/#{@cat.name}".downcase).
          and_return(true)
        
        @cat.new_dir_available?.should be_false
      end
    end
  end  
end
