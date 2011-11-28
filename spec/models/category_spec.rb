require 'spec_helper'


describe Category do

  let(:cat) {Category.make}
  
  describe "#category_dir" do    
    context "when main category" do
      it "should return the name in downcase" do 
        cat.category_dir.should == "general"
      end
    end

    context "when sub category" do
      it "should return parent/sub in downcase" do
        sub = Category.make(:name => "Sub1")
        sub.move_to_child_of cat
        sub.category_dir.should == "general/sub1"
      end
    end

  end
  
  describe "#move_dir" do
    context "when it's a main category" do
      before do 
        @pdf = Pdf.make(:category => cat)
      end
      
      it "will move the directory" do
        
      end
    end

    context "when it's a sub-category"
  end

  # Write tests for the model, break down move / creating of files.
  describe "#new_dir_available" do
    
    before do 
      @pdf = Pdf.make(:category => cat)
    end
    
    context "when category name hasn't changed" do
      before do
        @pdf_dir = "#{@pdf.firm.store_dir}/#{@pdf.client.name}/#{cat.name}".downcase
      end

      it "should not check if file exists" do
        File.should_not_receive(:exists?)
        cat.new_dir_available?.should be_true
      end
    end

    context "when category name has changed" do 
      before do
        cat.name = 'new_cat_name'
        @pdf_dir = "#{@pdf.firm.store_dir}/#{@pdf.client.name}/#{cat.name}".downcase
      end
      
      context "for one pdf with new category name not existing" do
        it "checks new category dir doesn't exists" do
          File.stub!(:exists?).with(@pdf_dir).and_return(false)
          cat.new_dir_available?.should be_true
        end
      end

      context "for one pdf with new category name existing" do
        it "checks new category dir exists" do
          
          File.stub!(:exists?).with(@pdf_dir).and_return(true)
          cat.new_dir_available?.should be_false
        end
      end
      
      context "multiple pdfs one with existing category name" do
        it "should store the result and return" do
          @pdf2 = Pdf.make(:client => Client.make(:name => "fred"), :category => cat)

          # The second pdf is available but not the first.
          File.stub!(:exists?).with(@pdf_dir).and_return(false)
          File.stub!(:exists?).
            with("#{@pdf2.firm.store_dir}/#{@pdf2.client.name}/#{cat.name}".downcase).
            and_return(true)
          
          cat.new_dir_available?.should be_false
        end
      end
    end
  end
end
