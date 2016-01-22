class PdfThumbnail

  def self.create_dir(pdf)
    store_dir = pdf.firm.store_dir
    thumbnail_dir = "#{store_dir}/.pdfcat_thumbnail"
    FileUtils.mkdir_p(thumbnail_dir) unless File.exists?(thumbnail_dir)
  end
end
