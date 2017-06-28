class PdfThumbnail
  require 'fileutils'
  THUMBNAIL_DIR="#{Rails.root}/public/images/thumbnails"
  
  # Create a thumbnail of the first pdf page
  def self.make_thumbnail(original_pdf)
    PdfThumbnail.create_dir(original_pdf)
    if File.exists?(original_pdf.full_path) && !File.exists?(original_pdf.thumbnail_full_path)
      self.update_thumbnail(original_pdf)
    end
  end

  def self.update_thumbnail(original_pdf)
    thumb = Poleica.new(original_pdf.full_path).to_png(width: 180, height: 250)

    if File.exists?(thumb) & !File.exists("#{THUMBNAIL_DIR}/#{original_pdf.id}.png")
      FileUtils.mv(thumb, "#{THUMBNAIL_DIR}/#{original_pdf.id}.png")      
    end
  end
  
  # Create the thumbnails directory
  def self.create_dir(pdf)
    FileUtils.mkdir_p(THUMBNAIL_DIR) unless File.exists?(THUMBNAIL_DIR)
  end
end
