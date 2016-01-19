namespace :pdfs do
  desc 'set the ocr field to false for all pdfs with ocr = null'
  task :reset_ocr => :environment do |t|
    Pdf.find(:all, :conditions => "ocr IS NULL").each do |pdf|
      pdf.update_attribute(:ocr, false)
      puts pdf.pdfname
    end
  end
end
