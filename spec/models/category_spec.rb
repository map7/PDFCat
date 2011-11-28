require 'spec_helper'

describe Category do
  let(:cat) {Category.make}
  
  before do 
    @sub = Category.make(:name => "Sub1")
    @sub.move_to_child_of cat
  end
  
  describe "#category_dir" do    
    context "when main category" do
      it "should return the name in downcase" do 
        cat.category_dir.should == "general"
      end
    end

    context "when sub category" do
      it "should return parent/sub in downcase" do
        @sub.category_dir.should == "general/sub1"
      end
    end
  end

  describe "#prev_category_dir" do
    before do
      cat.name = "tax"
      @sub.name = "new"
    end
    
    context "when main category" do
      it "should return the name in downcase" do 
        cat.prev_category_dir.should == "general"
      end
    end

    context "when sub category" do
      it "should return parent/sub in downcase" do
        @sub.prev_category_dir.should == "general/sub1"
      end
    end
    
    context "when sub changes parent" do
      before do 
        cat2 = Category.make(:name => "mail")
        @sub.parent_id = cat2.id
      end
      
      it "should return parent/sub in downcase" do
        @sub.prev_category_dir.should == "general/sub1"
        @sub.category_dir.should == "mail/new"
      end
    end
  end
  
  describe "#move_dir" do
    context "when it's a main category" do
      before do 
        @pdf = Pdf.make
        @old_dir = "/home/map7/pdfcat_test_clt/publishing solutions/general"
        @new_dir = "/home/map7/pdfcat_test_clt/publishing solutions/new_name"
        @old_path = "#{@old_dir}/20100128-Unit_Trust_Deed.pdf"
        @new_path = "#{@new_dir}/20100128-Unit_Trust_Deed.pdf"
        @cat = @pdf.category
        Pdf.stub!(:find).and_return([@pdf])
      end
      
      context "new dir doesn't exist" do 
        before do 
          File.stub!(:exists?).with(@new_dir).and_return(false)
          File.stub!(:exists?).with(@old_dir).and_return(true)
          @cat.name = "new_name"
        end
        
        it "will rename the old directory" do
          File.should_receive(:rename).with(@old_dir, @new_dir)
          @cat.move_dir
        end
      end
      
      context "new dir does exist" do
        before do 
          File.stub!(:exists?).with(@new_dir).and_return(true)
          File.stub!(:exists?).with(@old_path).and_return(true)
          @cat.name = "new_name"
        end
        
        it "will move each pdf" do
          File.should_receive(:rename).with(@old_path, @new_path)
          @cat.move_dir
        end
        
        context "old directory has already been renamed" do
          before do 
            File.stub!(:exists?).with(@old_path).and_return(false)
            File.stub!(:exists?).with(@old_dir).and_return(false)            
          end
          
          it "should not rename the file" do
            File.should_not_receive(:rename).with(@old_path, @new_path)
            @cat.move_dir
          end
        end
      end
    end

    context "when it's a sub-category" do
      
    end
  end
  

end
