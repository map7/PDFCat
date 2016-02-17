require 'spec_helper'
require 'fakefs/safe'

# Make the client & upload directories
def make_basedirs
  FileUtils.mkdir_p("/home/map7/pdfcat_test_clt")
  FileUtils.mkdir_p("/home/map7/pdfcat_test_upload")
end

# Make a category and add a sub category to it.
def make_sub(cat, subname)
  sub = Category.make(:name => subname, :firm_id => cat.firm_id)
  sub.move_to_child_of cat
  sub
end

# Make a category and sub category2
def make_cat_and_sub(catname, subname)
  cat = Category.make(name: catname)
  sub = make_sub(cat, subname)
  [cat, sub]
end

# Make a directory with one file
def make_dir_with_file(dir,file)
  FileUtils.mkdir_p(dir)
  FileUtils.touch("#{dir}/#{file}")
end

describe Category do

  context "with file operations" do 
    before do
      FakeFS.activate!
    end

    after do
      FakeFS.deactivate!      
    end

    describe "#move_dir" do 
      before do
        make_basedirs

        @pdf = Pdf.make
        @client_dir = "#{@pdf.firm.store_dir}/publishing solutions"
        @cat = @pdf.category
      end


      context "when changing the main category" do
        before do 
          make_dir_with_file("#{@client_dir}/general", "Unit_Trust-20100128.pdf") # Make the old directory
          @cat.name = "new_name" # Change the category name
        end
        
        context "new dir doesn't exist" do 
          it "will rename the old directory" do
            @cat.move_dir
            assert File.exists?("#{@client_dir}/new_name")
          end
        end

        context "new dir does exist" do
          it "will move each pdf" do
            FileUtils.mkdir_p("#{@client_dir}/#{@cat.name}")   # Make the new dir
            @cat.move_dir
            assert File.exists?("#{@client_dir}/#{@cat.name}/Unit_Trust-20100128.pdf")
          end
        end

        context "old directory has already been renamed" do
          it "should not rename the file" do
            FileUtils.mv("#{@client_dir}/general","#{@client_dir}/new_name") # Rename old to new move_dir.
            @cat.move_dir
            assert File.exists?("#{@client_dir}/#{@cat.name}/Unit_Trust-20100128.pdf")
          end
        end
      end                         # main cat

      context "when it's a sub-category" do
        before do
          @sub = make_sub(@cat, "sub") # current dir
          make_dir_with_file("#{@client_dir}/#{@cat.name.downcase}/#{@sub.name}","Unit_Trust-20100128.pdf")
          @pdf.update_attribute(:category_id, @sub.id) # Make sure pdf is part of the sub category
          @newsub = make_sub(@cat, "newsub")
        end

        context "new dir doesn't exist" do
          it "exists before the move" do
            assert File.exists?("#{@client_dir}/#{@cat.name.downcase}/#{@sub.name}/Unit_Trust-20100128.pdf")
          end
          
          it "will renames the old dir" do
            @sub.name = "newsub"
            @sub.move_dir
            assert File.exists?("#{@client_dir}/#{@cat.name.downcase}/#{@newsub.name}/Unit_Trust-20100128.pdf")
          end        
        end

        context "new dir does exist" do
          it "will move the pdf" do
            FileUtils.mkdir_p "#{@client_dir}/#{@cat.name.downcase}/#{@newsub.name}"
            @sub.name = "newsub"
            @sub.move_dir
            assert File.exists?("#{@client_dir}/#{@cat.name.downcase}/#{@newsub.name}/Unit_Trust-20100128.pdf")
          end
        end

        context "old dir has already been renamed" do
          it "should not rename the file" do
            FileUtils.mv("#{@client_dir}/#{@cat.name.downcase}/#{@sub.name}","#{@client_dir}/#{@cat.name.downcase}/other_dir")
            @sub.name = "newsub"
            @sub.move_dir
            assert File.exists?("#{@client_dir}/#{@cat.name.downcase}/other_dir/Unit_Trust-20100128.pdf")
          end
        end

        context "when moving a sub to a sub" do
          before do 
            @cat2 = Category.make(name: "Cat2")
          end

          it "should appear in the new sub directory" do
            @sub.parent = @cat2
            @sub.move_dir
            assert File.exists?("#{@client_dir}/#{@cat2.name.downcase}/#{@sub.name.downcase}/Unit_Trust-20100128.pdf")
          end
        end
      end # sub
    end
  end

  
  context "without file operations" do 
    let(:cat) {Category.make}
    
    before do 
      @sub = Category.make(:name => "Sub1", :firm_id => cat.firm_id)
      @sub.move_to_child_of cat
    end

    describe "#pdfs_total" do
      context "sub category has one pdf & main has one" do 
        it "returns two" do
          @sub.pdfs << Pdf.make
          cat.pdfs << Pdf.make
          cat.pdfs_total.should == 2
        end
      end

      context "sub category has one pdf" do 
        it "returns one" do
          @sub.pdfs << Pdf.make
          cat.pdfs_total.should == 1
        end
      end
      
      context "sub category has zero pdfs" do
        it "returns zero" do 
          cat.pdfs_total.should == 0
        end
      end
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

    describe "#parent_dir" do
      context "when main category" do
        it "should return the name in downcase" do 
          cat.parent_dir.should == nil
        end
      end

      context "when sub category" do
        it "should return parent/sub in downcase" do
          @sub.parent_dir.should == "general"
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

      context "when moving a main to sub" do
        before do
          cat2 = Category.make(:name => "mail")
          cat.parent_id = cat2.id
        end

        it "should set the prev category" do
          cat.prev_category_dir.should == "general"
          cat.category_dir.should == "mail/tax"
        end
      end

      context "when moving a sub to a main" do
        before do
          @sub.parent_id = nil
        end

        it "should set the prev category" do
          @sub.prev_category_dir.should == "general/sub1"
          @sub.category_dir.should == "new"
        end
      end

    end

    describe "#roots_without_self" do
      before do
        cat1=Category.make(name: "cat1", firm: cat.firm)
        cat2=Category.make(name: "cat2", firm: cat.firm)
      end

      context "when we have a new category" do
        it "returns all the roots" do
          new_cat = Category.new(firm: cat.firm)
          new_cat.roots_without_self.length.should == 3
        end          
      end

      context "when we have a category" do
        it "returns a list of cat1 & cat2 only" do
          cat.roots_without_self.length.should == 2
        end
      end
    end
  end
end
