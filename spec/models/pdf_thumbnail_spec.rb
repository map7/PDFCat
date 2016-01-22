require "spec_helper"

describe PdfThumbnail do
  let(:pdf) {Pdf.make}
  before do
    @thumbnail_dir = "/home/map7/pdfcat_test_clt/.pdfcat_thumbnail"
  end

  describe "#make_thumbnail" do
    it "creates a thumbnail" do
      pdf.update_attribute(:filename, "test.pdf")
      PdfThumbnail.make_thumbnail(pdf)
      File.exists?("#{@thumbnail_dir}/#{pdf.id}.png").should == true
    end
  end

  describe "#create_dir" do
    it "creates the thumbnail directory" do
      PdfThumbnail.create_dir(pdf)
      File.exists?(@thumbnail_dir).should == true
    end
  end
end
