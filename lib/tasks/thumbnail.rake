namespace :pdfs do
  desc 'create thumbnail'
  task :thumbnail => :environment do |t|
    Pdf.find(:all, :conditions => {:missing_flag => false}, :order => "id DESC").each do |pdf|
      puts "Thumbnail id: #{pdf.id}-#{pdf.full_path}"
      PdfThumbnail.make_thumbnail(pdf)
    end
  end
end
