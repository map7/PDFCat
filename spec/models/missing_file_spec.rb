require 'spec_helper'

describe MissingFile do

  # This needs a mockfs or something to properly mock the file system.
  # # Get all pdfs in firm's storage dir
  # describe "#get_pdfs_in_storage_dir" do
  #   it "returns a list of pdfs in that dir" do
  #     pdf = Pdf.make(:filename => "a.pdf")
  #     Find.stubs(:find).and_returns([pdf.filename, "b.pdf"])
  #     FileTest.stub(:file?).and_return(true)
  #     File.stub(:extname).and_return(".pdf")
  #
  #     result = MissingFile.get_pdfs_in_storage_dir(pdf.firm)
  #     result.should == ["a.pdf", "b.pdf"]
  #   end
  # end

  # Remove files from unallocated which exist in the DB
  describe "#remove_allocated" do
    describe "given two files one which exists in the DB and one which does not" do
      it "only displays the unallocated" do

        pdf = Pdf.make(:filename => "a.pdf")

        allocated =   pdf.fullpath(pdf.firm)
        unallocated = "/firm/path/b.pdf"
        files = [allocated, unallocated]

        result = MissingFile.remove_allocated(pdf.firm, files)
        result.should == [unallocated]
      end
    end
  end

  describe "#unallocated_files" do
    describe "with two files and one is allocated" do
      it "should only return one" do
        pdf = Pdf.make(:filename => "allocated.pdf")

        allocated =   pdf.fullpath(pdf.firm)
        unallocated = "/firm/path/b.pdf"
        files = [allocated, unallocated]

        MissingFile.stub!(:get_pdfs_in_storage_dir).and_return(files)

        result = MissingFile.unallocated_files(pdf.firm)
        result.should == [unallocated]
      end
    end
  end

end
