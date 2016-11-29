namespace :pdfs do
  desc 'perform OCR using Abbyy FineReader 11.3'
  task :ocr => :environment do |t|
    Pdf.find(:all, :conditions => {:ocr => false, :missing_flag => false}, :order => "id DESC", :limit => 10).each do |pdf|
      puts "OCR id: #{pdf.id}-#{pdf.full_path}"
      status = system("abbyyocr --multiProcessingMode Parallel --recognitionProcessesCount 32 --progressInformation --useNotOnlyPhysicalCPUCores -if \"#{pdf.full_path}\" -f PDF -of \"#{pdf.full_path}\"")
      pdf.update_attribute(:ocr, true) if status
    end
  end
end
