require 'spec_helper'

describe Pdf do
  let(:pdf) {Pdf.make}
  
  let(:filename)   {"Unit_Trust_Deed-20100128.pdf"}
  let(:store_dir)  {"/home/map7/pdfcat_test_clt"}
  let(:client_dir) {"#{store_dir}/publishing solutions"}
  let(:full_dir)   {"#{client_dir}/general"}
  let(:full_path)  {"#{full_dir}/#{filename}"}  

  before do 
    FileUtils.stub!(:chown).and_return(true)
  end

  describe "#thumbnail_full_path" do
    it "should equal /home/map7/pdfcat_test_clt/.pdfcat_thumbnail/<id>.png" do
      pdf.thumbnail_full_path.should == "/home/map7/pdfcat_test_clt/.pdfcat_thumbnail/#{pdf.id}.png"
    end    
  end

  describe "#total_pages" do
    context "Given two pdfs with 2 pages each" do
      it "returns a total of 2 pages" do
        pdf.stub(:full_path).and_return("#{full_dir}/test.pdf")
        pdfs = [pdf,pdf]
        Pdf.total_pages(pdfs).should == 2
      end
    end
  end

  describe "#yearly_pdfs" do
    context "Given two pdfs for a year" do
      it "returns all pdfs for that year only" do
        pdf2=Pdf.make
        pdf_out_of_range = Pdf.make(:pdfdate => Date.new(2000,01,01))
        pdfs = [pdf,pdf2]
        Pdf.all.count.should == 3
        Pdf.yearly_pdfs(pdf.pdfdate.year).count.should == 2
      end
    end
  end

  describe "#client_name" do
    context "Given a pdf which has a client" do 
      it "should return client name in downcase" do
        pdf.client_name.should == "publishing solutions"
      end
    end

    context "Given a pdf which doesn't have a client" do
      it "should return nil" do
        pdf.client = nil
        pdf.client_name.should == nil
      end
    end
  end
  
  describe "#category_name" do
    context "Given a pdf which has a category" do 
      it "should return category name in downcase" do
        pdf.category_name.should == "general"
      end
    end

    context "Given a pdf which doesn't have a category" do
      it "should return nil" do
        pdf.category = nil
        firm = Firm.make
        firm.categories << Category.make(:name => "foo")
        pdf.firm = firm
        
        pdf.category_name.should == "foo"
      end
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
    
    it "should return lowercase except filename" do
      pdf = Pdf.make(:filename => "Testing.pdf")
      pdf.full_path.should == "#{full_dir}/Testing.pdf"
    end

    context "pdf has no client" do
      it "returns dir with out client" do
        pdf = Pdf.make()
        pdf.update_attribute(:client_id, nil)
        pdf.full_path.should == "#{store_dir}/general/#{filename}"
      end
    end

    context "pdf has no category" do
      it "returns dir with out category" do
        pdf = Pdf.make()
        pdf.update_attribute(:category_id, nil)
        pdf.full_path.should == "#{client_dir}/#{filename}"
      end
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

  describe "#prev_full_dir" do
    context "when client changes" do
      it "should return previous dir" do
        pdf.client = Client.make(:name => "fred")
        pdf.prev_full_dir.should == full_dir
      end

      context "prev client doesn't exist anymore" do
        it "gets a previous dir without client" do
          client = Client.make(:name => "fred")
          pdf.client.delete # Remove previous client
          pdf.client = client
          pdf.prev_full_dir.should == store_dir
        end
      end
    end
    
    context "when category changes" do
      it "should return previous dir" do 
        pdf.category = Category.make(:name => "new")
        pdf.prev_full_dir.should == full_dir
      end

      context "prev category doesn't exist anymore" do
        it "gets a previous dir without category" do
          category = Category.make(:name => "tax")
          pdf.category.delete # Remove previous category
          pdf.category = category
          pdf.prev_full_dir.should == store_dir
        end
      end
    end
    
    context "when sub category changes" do
      before do 
        @sub_full_dir = "#{full_dir}/sub"
        @sub = Category.make(:name => "sub",
                             :parent_id=> pdf.category.id, :firm_id =>pdf.firm.id)
        @pdf = Pdf.make(:category_id => @sub.id, :firm_id => @sub.firm.id)
      end
      
      it "should return previous dir" do
        @pdf.category = Category.make(:name => "newsub",
                                      :parent_id => @sub.parent_id,:firm_id => @sub.firm.id)
        @pdf.prev_full_dir.should == @sub_full_dir
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
          pdf.prev_full_path.should == "mypath/Unit_Trust_Deed-20100128.pdf"
        end
      end
    
      context "but path has changed" do
        before do
          @pdf = Pdf.make(:path => "mypath")
          @pdf.path = "changed"
        end
        
        it "should trust the path variable" do
          @pdf.category = Category.make(:name => "new")          
          @pdf.prev_full_path.should == "mypath/Unit_Trust_Deed-20100128.pdf"
        end
      end
    end  
  end
  
  describe "#get_new_filename2" do
    it "should return new filename" do
      pdf.pdfname = "foobar"
      pdf.get_new_filename2.should == "foobar-20100128.pdf"
    end
  end
  
  describe "#move_uploaded_file" do 
    before do
      pdf.stub!(:md5calc2)
      FileUtils.stub!(:mv)
      File.stub!(:read).and_return(0)
      Digest::MD5.stub!(:hexdigest).and_return(0)
    end
    
    context "when new file" do
      it "should move the pdf" do 
        pdf.filename = "/path/to/uploaded file.pdf"
        FileUtils.should_receive(:mv).with(pdf.filename,pdf.new_full_path)
        pdf.move_uploaded_file
      end

      # it "should call md5calc2" do
      #   pdf.should_receive(:md5calc2)
      #   pdf.move_uploaded_file
      # end
    end
  end
  
  describe "#remove_prev_dir" do
    context "when main directory" do
      context "exists and is empty" do
        before do 
          File.stub!(:exists).with(pdf.prev_full_dir).and_return(true)
        end
      
        it "should remove the dir" do
          Dir.stub!(:entries).and_return(%w{. ..})
          FileUtils.should_receive(:rmdir).with(pdf.prev_full_dir).and_return(true)
          pdf.remove_prev_dir
        end
      end

      context "is full" do
        it "should not move dir" do
          Dir.stub!(:entries).and_return(%w{. .. test.pdf})
          FileUtils.should_not_receive(:rmdir)
          pdf.remove_prev_dir
        end
      end
    end
    
    context "when sub directory" do
      before do
        @sub = Category.make(:name => "sub",
                             :parent_id=> pdf.category.id, :firm_id => pdf.category.firm.id)
        @pdf = Pdf.make(:category_id => @sub.id, :firm_id => @sub.firm.id)
      end
      
      context "exists and is empty" do
        before do 
          @pdf.stub!(:directory_empty?).and_return(true)
        end

        it "should remove the dir" do
          FileUtils.should_receive(:rmdir).with(@pdf.prev_full_dir).and_return(true)
          @pdf.remove_prev_dir
        end
      end

      context "is full" do
        before do 
          @pdf.stub!(:directory_empty?).and_return(false)
        end

        it "should not move dir" do
          FileUtils.should_not_receive(:rmdir).with(@pdf.prev_full_dir).and_return(true)
          @pdf.remove_prev_dir
        end
      end
    end



  end
  
  describe "#move_file2" do
    before do 
      pdf.stub!(:md5calc2)
      Dir.stub!(:entries).and_return(%w{. .. test.pdf}) # Directory is full
    end
    
    context "when changing category" do
      let(:dest_dir){"#{client_dir}/#{@cat.name}"}
      
      before do
        @pdf = pdf
        @pdf.category = @cat = Category.make(:name => "new")
        FileUtils.stub!(:mv)

        @pdf.stub!(:prev_full_path_exists?).and_return(true)
        File.stub!(:exists).with("#{client_dir}/#{@cat.name}").and_return(true) #dest
        
        # Stub out mkdir
        FileUtils.stub!(:mkdir_p)

        # Don't worry about removing the old directory
        @pdf.stub!(:directory_empty?).and_return(false)
        File.stub!(:read).and_return(0)
        Digest::MD5.stub!(:hexdigest).and_return(0)
      end
      
      it "should move the pdf" do
        FileUtils.should_receive(:mv).with(full_path,
                                           "#{client_dir}/#{@cat.name}/#{filename}")
        @pdf.move_file2
      end

      context "where the new full dir doesn't exist" do 
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
          File.stub!(:read).and_return(0)
          Digest::MD5.stub!(:hexdigest).and_return(0)
        end

        context "dest dir doesn't exist" do 
          it "should create the destination directory" do
            File.should_receive(:exists?).with(dest_dir).and_return(false)
            FileUtils.should_receive(:mkdir_p)#.with([dest_dir])
            @pdf.move_file2
          end
        end

        context "dest dir does exist" do 
          before do
            File.stub!(:exists?).and_return(true)
            File.stub!(:read).and_return(0)
            Digest::MD5.stub!(:hexdigest).and_return(0)
          end
          
          it "should check the destination directory only" do
            File.should_receive(:exists?).with(dest_dir).and_return(true)
            FileUtils.should_not_receive(:mkdir_p)
            @pdf.move_file2
          end

          it "should update filename" do
            lambda do
              @pdf.pdfname="Testing filename"
              @pdf.move_file2              
            end.should change(@pdf, :filename).
              from("Unit_Trust_Deed-20100128.pdf").
              to("Testing_filename-20100128.pdf")
          end

          # it "should update md5" do
          #   MD5.stub!(:hexdigest).and_return("the_md5")
          #   lambda do
          #     @pdf.move_file2              
          #   end.should change(@pdf, :md5).
          #     from(nil).
          #     to("the_md5")
          # end
        end
        
        context "when pdf original path doesn't exist" do
          it "should not move file" do
            @pdf.stub!(:prev_full_path_exists?).and_return(false)
            @pdf.update_attribute(:path, "/path/does/not/exist")
            FileUtils.should_not_receive(:mv)
            @pdf.move_file2            
          end
        end
      end 
    end
  end
end
