namespace :pdfs do
  desc 'perform OCR on trust deeds using Abbyy FineReader 11.3'
  task :ocr_trust_deeds => :environment do |t|
    Category.find(:all, :conditions => "name LIKE '%trust%'").each do |cat|

      # Go through each trust deed pdf which exists and hasn't been ocr'd yet.
      cat.pdfs.find(:all, :conditions => {:ocr => false, :missing_flag => false}, :order => "pdfdate DESC").each do |pdf|

        puts "OCR #{pdf.full_path}"
        `abbyyocr --multiProcessingMode Parallel --recognitionProcessesCount 16 --useNotOnlyPhysicalCPUCores -if \"#{pdf.full_path}\" -f PDF -of \"#{pdf.full_path}\"`
        pdf.update_attribute(:ocr, true)
      end
    end
  end
end
