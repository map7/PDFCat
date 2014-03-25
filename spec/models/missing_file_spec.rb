require 'spec_helper'

describe MissingFile do

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
end
