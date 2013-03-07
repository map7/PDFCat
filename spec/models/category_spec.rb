require 'spec_helper'

describe Category do
  let(:cat) {Category.make}
  
  before do 
    @sub = Category.make(:name => "Sub1", :firm_id => cat.firm_id)
    @sub.move_to_child_of cat
  end
  
  describe "destroy" do
    context "with no pdfs attached" do
      it "deletes" do
        cat.destroy
        lambda { Category.find(cat.id) }.should raise_error(ActiveRecord::RecordNotFound)
      end
    end
    
    context "with pdfs attached" do
      before do
        cat.pdfs << Pdf.make
      end
      
      it "should not delete" do
        cat.destroy
        lambda { Category.find(cat.id) }.should_not raise_error(ActiveRecord::RecordNotFound)        
      end

      it "adds an error" do
        cat.destroy
        cat.errors.count.should == 1
      end
    end
  end

  describe "#sort_categories" do
    context "when saving" do
      context "a parent" do 
        it "should sort in alphabetical" do
          cat2=Category.make(:name => "Admin", :firm_id => cat.firm_id)
          Category.first.name.should == "Admin"          
        end      
      end

      context "a sub category" do
        it "should sort in alphabetical" do
          sub2= Category.make(:name =>"sub2", :firm_id => cat.firm_id, :parent_id => cat.id)
          sub= Category.make(:name =>"asub", :firm_id => cat.firm_id, :parent_id => cat.id)
          
          Category.all[1].name.should == "asub"
        end
      end
    end
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
    before do
      @pdf = Pdf.make
      @client_dir = "#{@pdf.firm.store_dir}/publishing solutions"
      @cat = @pdf.category
    end
    
    context "when it's a main category" do
      before do 
        Pdf.stub!(:find).and_return([@pdf])

        @old_dir = "#{@client_dir}/general"
        @new_dir = "#{@client_dir}/new_name"
        @old_path = "#{@old_dir}/Unit_Trust_Deed-20100128.pdf"
        @new_path = "#{@new_dir}/Unit_Trust_Deed-20100128.pdf"
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
      before do 
        @sub = Category.make(:sub)
        @sub.move_to_child_of @cat
        @subpdf = Pdf.make(:pdfname => "subpdf", :category_id => @sub.id)
        
        Pdf.stub!(:find).and_return([@subpdf])

        @old_dir = "#{@client_dir}/general/sub"
        @new_dir = "#{@client_dir}/general/new_sub"
        @old_path = "#{@old_dir}/Unit_Trust_Deed-20100128.pdf"
        @new_path = "#{@new_dir}/Unit_Trust_Deed-20100128.pdf"
      end
      
      context "new dir doesn't exist" do
        before do 
          File.stub!(:exists?).with(@new_dir).and_return(false)
          File.stub!(:exists?).with(@old_dir).and_return(true)
          @sub.name = "new_sub"
        end
        
        it "will rename the old directory" do
          File.should_receive(:rename).with(@old_dir, @new_dir)
          @sub.move_dir
        end        
      end
        
      context "new dir does exist" do
        before do 
          File.stub!(:exists?).with(@new_dir).and_return(true)
          File.stub!(:exists?).with(@old_path).and_return(true)
          @sub.name = "new_sub"
        end
        
        it "will move each pdf" do
          File.should_receive(:rename).with(@old_path, @new_path)
          @sub.move_dir
        end
        
        context "old directory has already been renamed" do
          before do 
            File.stub!(:exists?).with(@old_path).and_return(false)
            File.stub!(:exists?).with(@old_dir).and_return(false)            
          end
          
          it "should not rename the file" do
            File.should_not_receive(:rename).with(@old_path, @new_path)
            @sub.move_dir
          end          
        end
      end
    end
  end
end
