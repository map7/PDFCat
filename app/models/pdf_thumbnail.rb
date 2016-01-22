class PdfThumbnail
  require 'rmagick'
  
  # Create a thumbnail of the first pdf page
  def self.make_thumbnail(original_pdf)
    pdf=Magick::ImageList.new(original_pdf.full_path)
    thumb=pdf.scale(180,250)
    thumb.write(original_pdf.thumbnail_full_path)
  end
  
  # Create the thumbnails directory
  def self.create_dir(pdf)
    store_dir = pdf.firm.store_dir
    thumbnail_dir = "#{store_dir}/.pdfcat_thumbnail"
    FileUtils.mkdir_p(thumbnail_dir) unless File.exists?(thumbnail_dir)
  end
end
