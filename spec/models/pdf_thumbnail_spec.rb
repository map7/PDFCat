require "spec_helper"

describe PdfThumbnail do
  let(:pdf) {Pdf.make}

  describe "#make_thumbnail"

  describe "#create_dir" do
    it "creates the thumbnail directory" do
      PdfThumbnail.create_dir(pdf)
      thumbnail_dir = "/home/map7/pdfcat_test_clt/.pdfcat_thumbnail"
      File.exists?(thumbnail_dir).should == true
    end
  end
end
