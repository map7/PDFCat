namespace :pdfs do
  desc 'perform OCR using Abbyy FineReader 11.3'
  task :ocr => :environment do |t|
    Pdf.find(:all, :conditions => {:ocr => false, :missing_flag => false}, :order => "pdfdate DESC", :limit => 20).each do |pdf|
      puts "OCR #{pdf.full_path}"
      `abbyyocr --multiProcessingMode Parallel --recognitionProcessesCount 16 --useNotOnlyPhysicalCPUCores -if \"#{pdf.full_path}\" -f PDF -of \"#{pdf.full_path}\"`
      pdf.update_attribute(:ocr, true)
    end
  end
end
