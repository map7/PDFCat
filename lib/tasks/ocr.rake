namespace :pdfs do
  desc 'perform OCR using Abbyy FineReader 11.3'
  task :ocr => :environment do |t|
    Pdf.find(:all, :conditions => {:ocr => false, :missing_flag => false}, :order => "id DESC", :limit => 10).each do |pdf|
      puts "OCR id: #{pdf.id}-#{pdf.full_path}"
      pdf.ocr_file
    end
  end
end
