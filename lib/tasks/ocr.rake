namespace :pdfs do
  desc 'perform OCR using Abbyy FineReader 11.3'
  task :ocr => :environment do |t|
    limit = ENV['OCR'] || 10
    Pdf.find(:all, :conditions => {:ocr => false, :missing_flag => false}, :order => "id DESC", :limit => limit).each do |pdf|
      puts "OCR id: #{pdf.id}-#{pdf.full_path}"
      pdf.ocr_file
    end
  end
end
