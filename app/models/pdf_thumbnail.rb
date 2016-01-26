class PdfThumbnail
  require 'rmagick'
  
  # Create a thumbnail of the first pdf page
  def self.make_thumbnail(original_pdf)
    PdfThumbnail.create_dir(original_pdf)
    if File.exists?(original_pdf.full_path) && !File.exists?(original_pdf.thumbnail_full_path)
      begin
        pdf=Magick::ImageList.new(original_pdf.full_path)
        thumb=pdf.scale(180,250)
        thumb.write(original_pdf.thumbnail_full_path)
      rescue
        puts "** Issues with: #{original_pdf.full_path}"
      end
    end
  end
  
  # Create the thumbnails directory
  def self.create_dir(pdf)
    store_dir = pdf.firm.store_dir
    thumbnail_dir = "#{Rails.root}/public/images/thumbnails"
    FileUtils.mkdir_p(thumbnail_dir) unless File.exists?(thumbnail_dir)
  end
end
